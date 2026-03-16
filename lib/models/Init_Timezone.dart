import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initializeTimeZones() async {
  // Initialize the timezone database
  tz.initializeTimeZones();          // initialize timezone DB
  tz.setLocalLocation(tz.local);
}