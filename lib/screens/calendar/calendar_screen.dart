import 'package:flutter/material.dart';
import 'package:tmapp/config/app_theme.dart';
import 'package:tmapp/widgets/theme_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDayIndex = 1; // Tuesday (index 1)

  final List<Map<String, String>> _weekDays = [
    {'day': 'Mo', 'date': '3'},
    {'day': 'Tu', 'date': '4'},
    {'day': 'We', 'date': '5'},
    {'day': 'Th', 'date': '6'},
    {'day': 'Fr', 'date': '7'},
    {'day': 'Sa', 'date': '8'},
    {'day': 'Su', 'date': '9'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.textPrimary,
                  ),
                  Text(
                    'Oct, 2020',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  ThemeWidgets.addTaskButton(
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Calendar week view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDays.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> day = entry.value;
                  bool isSelected = _selectedDayIndex == index;
                  bool isToday = index == 1; // Tuesday is today
                  
                  return ThemeWidgets.calendarDay(
                    day: day['day']!,
                    date: day['date']!,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Tasks section
            ThemeWidgets.sectionHeader(title: 'Tasks'),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ThemeWidgets.taskCard(
                    title: 'Design Changes',
                    subtitle: '2 Days ago',
                    icon: Icons.description,
                    onTap: () {},
                    onMoreTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        onTap: (index) {},
      ),
    );
  }
} 