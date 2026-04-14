import 'package:flutter/material.dart';

import '../models/app_track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onDelete,
    this.leadingLabel,
  });

  final AppTrack track;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? leadingLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onTap: onTap,
      leading: track.artworkUrl == null
          ? CircleAvatar(
              child: Text(
                leadingLabel ?? track.title.characters.first.toUpperCase(),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                track.artworkUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.music_note)),
              ),
            ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(track.sourceType.name),
            visualDensity: VisualDensity.compact,
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}
