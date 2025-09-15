import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSection(),
            _IntroductionSection(),
            _AboutSection(),
            _SessionsSection(),
            _ScienceSection(),
            _PracticeSection(),
            _StepsSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1574391884720-bbc3278cdc6e?w=800'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUCO',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Events', style: TextStyle(color: Colors.white)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'JOIN US AND\nFEEL FULLY',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('UPCOMING EVENTS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroductionSection extends StatelessWidget {
  const _IntroductionSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.lightGreen[100],
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUCO is a global ritual of movement, breathwork, cathartic live electronic music—designed to move you out of discouragement and into presence with joy.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'We invite you to rediscover full aliveness through the transformative power of ecstatic dance, breathwork, and healing sound frequencies.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('Get ticket for next event'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('Book a Private Experience',
                      style: TextStyle(color: Colors.black, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(Icons.spa, size: 80, color: Colors.blue[600]),
          const SizedBox(height: 32),
          Text(
            'Our name is more than just a label—\nit carries the essence of life itself.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'SUCO refers to the emotional juice that lives within all of us.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blue[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'For us, life is the most precious gift we could ever receive: a chance to experience a lifetime\'s worth of emotions, feelings, and deep cathartic moments that remind us what it means to be human.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsSection extends StatelessWidget {
  const _SessionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: const [
          Expanded(
            child: _SessionCard(
              title: 'SUCO\nSessions',
              description: 'Join our community gatherings for collective transformation and healing.',
              imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
              buttonText: 'Book Session',
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: _SessionCard(
              title: 'Private &\nTeam Rituals',
              description: 'Customized experiences for intimate groups and corporate teams.',
              imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
              buttonText: 'Learn More',
              isDark: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String buttonText;
  final bool isDark;

  const _SessionCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.buttonText,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        )),
                const SizedBox(height: 16),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScienceSection extends StatelessWidget {
  const _ScienceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue[700],
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Text('Disconnection is the real epidemic.',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Modern life has created unprecedented levels of isolation and disconnection. Through movement, breath, and sound, we reconnect to ourselves, each other, and the vital energy that flows through all life.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {},
            child: const Text('Discover The Science of SUCO',
                style: TextStyle(color: Colors.lightGreen, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}

class _PracticeSection extends StatelessWidget {
  const _PracticeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue[700],
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(right: 16),
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-${1500000000 + index}?w=200&h=200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text('(THE PRACTICE)',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 32),
          Text(
            'A 2-hour transformational experience combining movement, breathwork, and live electronic music.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Join Next Session'),
          ),
        ],
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.lightGreen[100],
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Text('The Journey',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 48),
          Row(
            children: const [
              Expanded(child: _StepCard('ARRIVAL', 'Ground yourself\nand set intention', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300')),
              SizedBox(width: 16),
              Expanded(child: _StepCard('ACTIVATION', 'Awaken your\nbody and energy', 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=300')),
              SizedBox(width: 16),
              Expanded(child: _StepCard('RELEASE', 'Let go of what\nno longer serves', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300')),
              SizedBox(width: 16),
              Expanded(child: _StepCard('EXPANSION', 'Integrate and\nembrace wholeness', 'https://images.unsplash.com/photo-1574391884720-bbc3278cdc6e?w=300')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const _StepCard(this.title, this.description, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4), textAlign: TextAlign.center),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue[900],
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Text('SUCO',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.business, color: Colors.white), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 32),
          Text('© 2024 SUCO. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
