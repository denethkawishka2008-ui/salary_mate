import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MonthScreen extends StatefulWidget {
  final String monthName;

  const MonthScreen({super.key, required this.monthName});

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isCalendarVisible = false;

  final List<Map<String, dynamic>> _rows = [];

  final List<String> _clients = [
    'Green view',
    'Arabian reanches',
    'Oxford garden',
    'Goldan wood ',
    'Aya residents villa',
    'Imperial',
    'Silicon oasis',
    '+ Add New Client',
  ];

  @override
  void initState() {
    super.initState();
    _loadData(); // ඇප් එක ඕපන් වන විට දත්ත ලෝඩ් කරගනී
  }

  // SharedPreferences හරහා දත්ත Save කරගැනීම
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // TextEditingControllers වල ඇති Text අගයන් JSON format එකකට හරවා සේව් කරයි
    List<Map<String, String>> dataToSave = _rows.map((row) {
      return {
        'date': row['date'].toString(),
        'client': row['client']?.toString() ?? '',
        'hours': (row['hours'] as TextEditingController).text,
        'payment': (row['payment'] as TextEditingController).text,
      };
    }).toList();

    await prefs.setString('saved_rows_${widget.monthName}', jsonEncode(dataToSave));
  }

  // සේව් කළ දත්ත නැවත ඇප් එකට ලබා ගැනීම
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedDataStr = prefs.getString('saved_rows_${widget.monthName}');

    if (savedDataStr != null) {
      List<dynamic> decodedData = jsonDecode(savedDataStr);
      setState(() {
        _rows.clear();
        for (var item in decodedData) {
          _rows.add({
            'date': item['date'],
            'client': item['client'].isEmpty ? null : item['client'],
            'hours': TextEditingController(text: item['hours']),
            'payment': TextEditingController(text: item['payment']),
          });
        }
      });
    }
  }

  void _addRowWithDate(DateTime date) {
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    setState(() {
      _rows.add({
        'date': formattedDate,
        'client': null,
        'hours': TextEditingController(),
        'payment': TextEditingController(),
      });
    });
    _saveData(); // වෙනසක් වූ විට ඔටෝ සේව් වේ
  }

  void _showClientSummaryDialog() {
    Map<String, Map<String, double>> summary = _getClientSummary();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Client Summary'),
          content: summary.isEmpty
              ? const Text('No entries found yet.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.5),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Client',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Hours',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Payment',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          for (var entry in summary.entries)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(entry.key),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    entry.value['hours']!.toStringAsFixed(1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    entry.value['payment']!.toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Map<String, Map<String, double>> _getClientSummary() {
    Map<String, Map<String, double>> summary = {};

    for (var row in _rows) {
      String? client = row['client'];
      if (client == null || client == '+ Add New Client') continue;

      double hours = double.tryParse((row['hours'] as TextEditingController).text) ?? 0;
      double payment = double.tryParse((row['payment'] as TextEditingController).text) ?? 0;

      if (!summary.containsKey(client)) {
        summary[client] = {'hours': 0.0, 'payment': 0.0};
      }

      summary[client]!['hours'] = summary[client]!['hours']! + hours;
      summary[client]!['payment'] = summary[client]!['payment']! + payment;
    }

    return summary;
  }

  void _addRow() {
    setState(() {
      _rows.add({
        'date': 'Select Date',
        'client': null,
        'hours': TextEditingController(),
        'payment': TextEditingController(),
      });
    });
    _saveData();
  }

  Future<void> _selectDate(int index) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _rows[index]['date'] =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _saveData();
    }
  }

  void _showAddClientDialog(int index) {
    TextEditingController newClientController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Client'),
          content: TextField(
            controller: newClientController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newClientName = newClientController.text.trim();
                if (newClientName.isNotEmpty) {
                  setState(() {
                    _clients.insert(_clients.length - 1, newClientName);
                    _rows[index]['client'] = newClientName;
                  });
                  _saveData();
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.monthName} Details'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: Icon(
              _isCalendarVisible ? Icons.calendar_today : Icons.calendar_month,
            ),
            onPressed: () {
              setState(() {
                _isCalendarVisible = !_isCalendarVisible;
              });
            },
            tooltip: 'Toggle Calendar',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isCalendarVisible)
            Card(
              margin: const EdgeInsets.all(8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _addRowWithDate(selectedDay);
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
            ),

          const Divider(thickness: 2),

          // Status Bar with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.list_alt, size: 14, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Entries: ${_rows.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'Hours: ${_calculatetotalhours().toStringAsFixed(1)}h',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              const Icon(Icons.payments, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Pay: LKR ${_calculatetotalpay().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showClientSummaryDialog,
                    icon: const Icon(Icons.table_chart, size: 14),
                    label: const Text('Summary', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ListView with data entries
          Expanded(
            child: _rows.isEmpty
                ? Center(
                    child: Text(
                      _isCalendarVisible
                          ? 'Tap a date on the calendar above to add an entry.'
                          : 'Tap the calendar icon on top to pick a date, or use "Add Row".',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _rows.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _selectDate(index),
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                      ),
                                      label: Text(_rows[index]['date']),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _rows[index]['client'],
                                      hint: const Text('Select Client'),
                                      items: _clients.map((String client) {
                                        return DropdownMenuItem<String>(
                                          value: client,
                                          child: Text(client),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue == '+ Add New Client') {
                                          _showAddClientDialog(index);
                                        } else {
                                          setState(() {
                                            _rows[index]['client'] = newValue;
                                          });
                                          _saveData();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _rows[index]['hours'],
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {});
                                        _saveData();
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Hours',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _rows[index]['payment'],
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {});
                                        _saveData();
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Payment',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _rows.removeAt(index);
                                      });
                                      _saveData();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.amber.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Deneth software's",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "DK softwares",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "code-DK",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRow,
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add),
        label: const Text('Add Row'),
      ),
    );
  }

  double _calculatetotalpay() {
    double total = 0;
    for (var row in _rows) {
      double payment = double.tryParse((row['payment'] as TextEditingController).text) ?? 0;
      total += payment;
    }
    return total;
  }

  double _calculatetotalhours() {
    double total = 0;
    for (var row in _rows) {
      double hours = double.tryParse((row['hours'] as TextEditingController).text) ?? 0;
      total += hours;
    }
    return total;
  }
}