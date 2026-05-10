import 'package:dil_pickle_todo/providers/task_provider.dart';
import 'package:dil_pickle_todo/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/sources/task_remote_data_source.dart';


void main() {
  final remoteDataSource = TaskRemoteDataSource();
  final taskRepository = TaskRepositoryImpl(remoteDataSource: remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(repository: taskRepository),
        ),
      ],
      child: const DilPickleApp(),
    ),
  );
}

class DilPickleApp extends StatelessWidget {
  const DilPickleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dil Pickle To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Gaegu',
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const SplashScreen(),
    );
  }
}