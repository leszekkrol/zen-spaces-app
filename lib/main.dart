import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen Spaces',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppInfo>? _installedApps;
  List<AppInfo>? _filteredApps;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInstalledApps() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true, '');
    setState(() {
      _installedApps = apps;
      _filteredApps = apps;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredApps = _installedApps?.where((app) {
        return app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _startApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
    } catch (e) {
      print('Could not start app: $packageName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _installedApps == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: _filteredApps?.length ?? 0,
              itemBuilder: (context, index) {
                AppInfo app = _filteredApps![index];
                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!)
                      : null,
                  title: Text(app.name),
                  subtitle: Text(app.packageName),
                  onTap: () => _startApp(app.packageName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}