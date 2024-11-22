import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitores',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MonitorListView(),
    );
  }
}

class MonitorListView extends StatefulWidget {
  const MonitorListView({super.key});

  @override
  State<MonitorListView> createState() => _MonitorListViewState();
}

class _MonitorListViewState extends State<MonitorListView> {
  List<dynamic> monitores = [];

  @override
  void initState() {
    super.initState();
    fetchMonitores();
  }

  Future<void> fetchMonitores() async {
    final response = await http.get(Uri.parse('http://localhost:3000/monitores'));
    if (response.statusCode == 200) {
      setState(() {
        monitores = json.decode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar monitores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Monitores')),
      body: monitores.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : PageView.builder(
            itemCount: monitores.length,
            itemBuilder: (context, index) {
              final monitor = monitores[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonitorDetailView(monitorId: monitor['id']),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: monitor['avatar'] != null && monitor['avatar'].isNotEmpty
                            ? NetworkImage(monitor['avatar'])
                            : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        monitor['nome'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

class MonitorDetailView extends StatefulWidget {
  final int monitorId;

  const MonitorDetailView({required this.monitorId, super.key});

  @override
  State<MonitorDetailView> createState() => _MonitorDetailViewState();
}

class _MonitorDetailViewState extends State<MonitorDetailView> {
  Map<String, dynamic>? monitor;

  @override
  void initState() {
    super.initState();
    fetchMonitorDetails();
  }

  Future<void> fetchMonitorDetails() async {
    final response = await http.get(Uri.parse('http://localhost:3000/monitores/${widget.monitorId}'));
    if (response.statusCode == 200) {
      setState(() {
        monitor = json.decode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar detalhes do monitor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Monitor')),
      body: monitor == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: monitor!['avatar'] != null && monitor!['avatar'].isNotEmpty
                          ? NetworkImage(monitor!['avatar'])
                          : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      monitor!['nome'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Horários de Monitoria:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...monitor!['horarios'].map<Widget>((horario) {
                    return Text(
                      horario,
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
