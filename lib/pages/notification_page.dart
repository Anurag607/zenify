import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const route = '/notification';

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as dynamic;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Material(
              elevation: 2,
              shadowColor: HexColor("#fefefe"),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor("#f6f8fe"),
                ),
                child: ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.notifications, size: 40),
                  title: Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(
                      message?.notification.title! ?? "No Title",
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      message?.notification.body! ?? "No Body",
                      style: const TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
