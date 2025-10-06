import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../services/file_services.dart';
import 'config_constatnts.dart';

final logger = Logger();
final uid = Uuid();
final playlistService = PlaylistFileService();
final db = Hive.box(SETTINGS_DB_KEY);