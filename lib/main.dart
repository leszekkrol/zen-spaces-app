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
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIconColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey,
          hintStyle: TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
        ),
      ),
      home: MyHomePage(),
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
  List<AppInfo> _selectedApps = [];

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
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        await InstalledApps.startApp(packageName);
      }
    } catch (e) {
      print('Could not start app: $packageName');
    }
  }

  void _hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _addAppToHome(AppInfo app) {
    setState(() {
      _selectedApps.add(app);
    });
  }

  void _showAppSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                itemCount: _filteredApps?.length ?? 0,
                itemBuilder: (context, index) {
                  AppInfo app = _filteredApps![index];
                  return ListTile(
                    leading: app.icon != null
                        ? Image.memory(app.icon!)
                        : null,
                    title: Text(app.name),
                    onTap: () {
                      _addAppToHome(app);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => _hideKeyboard(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Text(
                'Zen Spaces',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _selectedApps.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedApps.length) {
                    return Center(
                      child: IconButton(
                        icon: Icon(Icons.add, size: 50),
                        onPressed: _showAppSelection,
                      ),
                    );
                  } else {
                    AppInfo app = _selectedApps[index];
                    return ListTile(
                      leading: app.icon != null
                          ? Image.memory(app.icon!, width: 50, height: 50)
                          : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                      ),
                      title: Text(app.name),
                      onTap: () => _startApp(app.packageName),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}