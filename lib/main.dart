import 'package:flutter/material.dart';

import 'month_screen.dart';

void main() {
  runApp(const SalaryMateApp());
}

class SalaryMateApp extends StatelessWidget {
  const SalaryMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salary Mate',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color.fromARGB(255, 236, 234, 127), //
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Text(
              'Salary Mate 💰',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    blurRadius: _glowAnimation.value,
                  ),
                  const Shadow(
                    color: Colors.yellow,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 5, 93, 235),
        elevation: 6.0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                const Text(
                  'Hello, ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 59, 24, 255),
                  ),
                ),
                const Text(
                  'Amali ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 48, 48, 47),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: -0.4, end: 0.4),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  builder: (context, val, child) {
                    return Transform.rotate(
                      angle: val,
                      child: const Text('👋', style: TextStyle(fontSize: 26)),
                    );
                  },
                  onEnd: () {},
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: months.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 60)),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Card(
                    color: const Color.fromARGB(255, 8, 91, 225),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: index % 2 == 0
                            ? const Color.fromARGB(
                                255,
                                3,
                                37,
                                227,
                              ).withOpacity(0.4)
                            : Colors.yellow.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.cyan.shade100
                              : Colors.yellow.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: index % 2 == 0
                              ? const Color.fromARGB(255, 2, 70, 73)
                              : Colors.yellow.shade900,
                        ),
                      ),
                      title: Text(
                        months[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.cyanAccent,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MonthScreen(monthName: months[index]),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
