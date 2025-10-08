import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteButton extends StatefulWidget {
  final String contentType;
  final String contentId;

  const FavoriteButton({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final supabase = Supabase.instance.client;
  bool _isFavorite = false;
  bool _loading = true;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final res = await supabase
          .from('favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', widget.contentType)
          .eq('content_id', widget.contentId)
          .maybeSingle();

      setState(() {
        _isFavorite = res != null;
        _favoriteId = res?['id'];
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking favorite: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 👇 Si el ID no es válido, no hace nada
    if (widget.contentId == 'unknown' || widget.contentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot favorite: missing content ID'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      if (_isFavorite) {
        if (_favoriteId != null) {
          await supabase.from('favorites').delete().eq('id', _favoriteId!);
        }
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites 💔'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        final res = await supabase.from('favorites').insert({
          'user_id': user.id,
          'content_type': widget.contentType,
          'content_id': widget.contentId,
        }).select('id').maybeSingle();

        setState(() {
          _isFavorite = true;
          _favoriteId = res?['id'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites ❤️'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.redAccent : Colors.white70,
        size: 28, // un poco más grande
      ),
      onPressed: _toggleFavorite,
    );
  }
}
