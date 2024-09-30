import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/services/file_manager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FileManager _fileManager = FileManager();
  List<Book> _allBooks = [];
  int _totalBooksRead = 0;
  Duration _totalReadingTime = Duration.zero;
  List<ReadingData> _weeklyReadingData = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    List<Book> books = await _fileManager.getLibraryBooks();
    setState(() {
      _allBooks = books;
      _totalBooksRead = books.where((book) => book.status == ReadingStatus.completed).length;
      _totalReadingTime = books.fold(Duration.zero, (total, book) => total + book.totalReadingTime);
      _generateWeeklyReadingData();
    });
  }

  void _generateWeeklyReadingData() {
    _weeklyReadingData = List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      Duration duration = _allBooks.fold(Duration.zero, (total, book) {
        return total + book.readingSessions
            .where((session) => session.startTime.day == date.day && session.startTime.month == date.month)
            .fold(Duration.zero, (sessionTotal, session) => sessionTotal + session.duration);
      });
      return ReadingData(date, duration.inHours);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Reading Statistics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _buildStatisticTile('Total Books Read', _totalBooksRead.toString()),
            _buildStatisticTile('Total Reading Time', '${_totalReadingTime.inHours}h ${_totalReadingTime.inMinutes % 60}m'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Weekly Reading Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.days,
                  interval: 1,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Hours'),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                series: <ChartSeries>[
                  ColumnSeries<ReadingData, DateTime>(
                    dataSource: _weeklyReadingData,
                    xValueMapper: (ReadingData data, _) => data.date,
                    yValueMapper: (ReadingData data, _) => data.hours,
                    name: 'Reading Time',
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _buildSettingsTile('Dark Mode', Icons.brightness_4, _toggleDarkMode),
            _buildSettingsTile('Notifications', Icons.notifications, _toggleNotifications),
            _buildSettingsTile('Export Library', Icons.file_upload, _exportLibrary),
            _buildSettingsTile('Import Library', Icons.file_download, _importLibrary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _toggleDarkMode() {
    // TODO: Implement dark mode toggle using the LibraryModel
  }

  void _toggleNotifications() {
    // TODO: Implement notifications toggle
  }

  void _exportLibrary() {
    // TODO: Implement library export functionality
  }

  void _importLibrary() {
    // TODO: Implement library import functionality
  }
}

class ReadingData {
  final DateTime date;
  final int hours;

  ReadingData(this.date, this.hours);
}