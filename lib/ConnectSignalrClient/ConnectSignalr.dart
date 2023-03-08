import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:signalr_netcore/signalr_client.dart';






class ConnectSignalr extends StatefulWidget {
  const ConnectSignalr({super.key});

  @override
  State<ConnectSignalr> createState() => _ConnectSignalrState();
}

class _ConnectSignalrState extends State<ConnectSignalr> {
  @override
  void initState() {
    super.initState();
    
    createSignalRConnection();
  }

  Future<void> createSignalRConnection() async {
    connection = HubConnectionBuilder().withUrl("http://10.0.2.2:8085").build();
   
    await connection.start();
    connection.invoke("displayStatus");
    connection.on("Message", (data) {
     // chats.add(data[0]);
      setState(() {}); 
    });
  }
  late HubConnection connection; 
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}