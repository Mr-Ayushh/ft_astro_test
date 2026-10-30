import 'package:flutter/material.dart';
import 'package:ftastro/features/journal/domain/index.dart';

extension TagStyle on EntryTag {
  IconData get icon => switch (this) {
        EntryTag.work => Icons.work_outline_rounded,
        EntryTag.family => Icons.home_outlined,
        EntryTag.friends => Icons.people_outline_rounded,
        EntryTag.exercise => Icons.directions_run_rounded,
        EntryTag.sleep => Icons.bedtime_outlined,
        EntryTag.reading => Icons.menu_book_rounded,
        EntryTag.nature => Icons.park_outlined,
        EntryTag.music => Icons.music_note_outlined,
        EntryTag.food => Icons.restaurant_outlined,
        EntryTag.selfCare => Icons.spa_outlined,
        EntryTag.study => Icons.school_outlined,
        EntryTag.travel => Icons.flight_takeoff_rounded,
      };
}
