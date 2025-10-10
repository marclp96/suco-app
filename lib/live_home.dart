import 'package:flutter/material.dart';
import 'package:suco_app/team_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nav.dart';
import 'today_page.dart';
import 'journey_page.dart';
import 'profile.dart';
import 'team_list.dart';
import 'app_drawer.dart';

class LiveHomePage extends StatefulWidget {
  const LiveHomePage({super.key});

  @override
  State<LiveHomePage> createState() => _LiveHomePageState();
}

class _LiveHomePageState extends State<LiveHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 3; // Live

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const TodayPage();
        break;
      case 1:
        nextPage = const TeamListPage();
        break;
      case 2:
        nextPage = const JourneyPage();
        break;
      case 3:
        nextPage = const LiveHomePage();
        break;
      default:
        nextPage = const TodayPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 👈 necesario para abrir el Drawer
      backgroundColor: const Color(0xFF1A1A1A),
      drawer: const AppDrawer(), // 👈 Drawer real
      body: FutureBuilder<List>(
        future: Supabase.instance.client.from('events').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(
              child: Text("No events found",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final parsedEvents = events.map((e) {
            final event = Map<String, dynamic>.from(e);
            event['parsedDate'] = DateTime.parse(event['date']).toLocal();
            return event;
          }).toList();

          final Map<String, bool> eventDays = {};
          for (final e in parsedEvents) {
            final date = e['parsedDate'] as DateTime;
            final key =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            eventDays[key] = true;
          }

          parsedEvents.sort(
              (a, b) => (a['parsedDate'] as DateTime).compareTo(b['parsedDate']));

          final now = DateTime.now();
          final upcoming = parsedEvents
              .where((e) => (e['parsedDate'] as DateTime).isAfter(now))
              .toList();
          Map<String, dynamic>? nextEvent =
              upcoming.isNotEmpty ? upcoming.first : null;

          return ListView(
            children: [
              _buildHeader(),
              if (nextEvent != null)
                _buildHeroCard(nextEvent)
              else
                _buildNoEventCard(),
              _buildCalendar(eventDays),
              _buildUpcomingEvents(parsedEvents),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
      floatingActionButton: AppCenterFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ✅ HEADER dinámico con saludo por hora + nombre del usuario de Supabase
  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final supabase = Supabase.instance.client;

    return FutureBuilder(
      future: supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user!.id)
          .maybeSingle(),
      builder: (context, snapshot) {
        String greeting = _getGreeting();
        String name = 'there';

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data as Map<String, dynamic>?;
          if (data != null && data['full_name'] != null) {
            name = data['full_name'];
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$name ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const Text('👋', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer(); // 👈 abre el Drawer
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Función auxiliar para saludo según hora
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  /// 🌟 HERO CARD
  Widget _buildHeroCard(Map<String, dynamic> event) {
    final date = event['parsedDate'] as DateTime;
    final formatted = DateFormat("dd MMM, HH:mm").format(date);
    final location = event['location_address'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/sucolive.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event['title'] ?? "Untitled",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    formatted,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoEventCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF333333),
      ),
      child: const Center(
        child: Text(
          "No upcoming events",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  /// 📅 CALENDARIO
  Widget _buildCalendar(Map<String, bool> eventDays) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int startWeekday = firstDayOfMonth.weekday;
    if (startWeekday == 7) startWeekday = 0;

    List<TableRow> rows = [];
    rows.add(_buildWeekRow(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"],
        header: true, eventDays: eventDays));

    List<String> currentWeek = List.filled(7, " ");
    int dayCounter = 1;

    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 7; j++) {
        int cellIndex = i * 7 + j;
        if (cellIndex >= startWeekday && dayCounter <= daysInMonth) {
          currentWeek[j] = dayCounter.toString();
          dayCounter++;
        } else {
          currentWeek[j] = " ";
        }
      }
      rows.add(_buildWeekRow(List.from(currentWeek),
          month: now.month, year: now.year, eventDays: eventDays));
      if (dayCounter > daysInMonth) break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: Colors.white70),
              Text(
                "${_monthName(now.month)} ${now.year}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Table(children: rows),
        ],
      ),
    );
  }

  TableRow _buildWeekRow(List<String> days,
      {bool header = false,
      int? month,
      int? year,
      Map<String, bool>? eventDays}) {
    return TableRow(
      children: days.map((day) {
        bool isEventDay = false;
        bool isToday = false;

        if (!header && day.trim().isNotEmpty) {
          final d = int.tryParse(day);
          if (d != null && month != null && year != null) {
            final key =
                "${year}-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}";
            isEventDay = eventDays?[key] ?? false;

            final today = DateTime.now();
            isToday = (today.year == year &&
                today.month == month &&
                today.day == d);
          }
        }

        return Container(
          margin: const EdgeInsets.all(4),
          height: 36,
          decoration: BoxDecoration(
            color: header
                ? Colors.transparent
                : isToday
                    ? Colors.greenAccent.withOpacity(0.3)
                    : isEventDay
                        ? const Color(0xFFCBFBC7)
                        : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: header
                    ? Colors.greenAccent
                    : isEventDay
                        ? Colors.black
                        : Colors.white70,
                fontWeight: header ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  /// 📋 UPCOMING EVENTS
  Widget _buildUpcomingEvents(List<Map<String, dynamic>> events) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: events.map((event) {
              final date = event['parsedDate'] as DateTime;
              final formatted = DateFormat("dd MMM, HH:mm").format(date);
              final location = event['location_address'] ?? "";
              final ticketLink = event['ticket_link'];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event,
                            color: Colors.greenAccent[400], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? "Untitled",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatted,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              if (location.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  location,
                                  style:
                                      const TextStyle(color: Colors.white54),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (ticketLink != null && ticketLink.toString().isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final url = Uri.parse(ticketLink);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Text("BOOK"),
                        ),
                      )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
