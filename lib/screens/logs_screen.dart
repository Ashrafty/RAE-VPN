import 'package:flutter/material.dart';
import 'package:rae_vpn/services/v2ray_service.dart';
import 'package:rae_vpn/v2ray_service.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Logs'),
        backgroundColor: const Color(0xFF05363F),
      ),
      body: StreamBuilder<List<String>>(
        stream: V2RayService().logsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    snapshot.data![index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No logs available'));
          }
        },
      ),
    );
  }
}