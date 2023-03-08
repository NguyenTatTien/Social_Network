import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';



import 'receiver_row_view.dart';
import '../Models/ChatMessagesModel.dart';
import 'global_members.dart';
import 'sender_row_view.dart';
import 'package:logging/logging.dart';
var url =
    'https://i.pinimg.com/736x/fd/6e/04/fd6e04548095d7f767917f344a904ff1.jpg';
var urlTwo =
    'https://sguru.org/wp-content/uploads/2017/03/cute-n-stylish-boys-fb-dp-2016.jpg';
class MyChatUI extends StatefulWidget {
  const MyChatUI({Key? key}) : super(key: key);

  @override
  MyChatUIState createState() => MyChatUIState();
}

class MyChatUIState extends State<MyChatUI> {

  var controller = TextEditingController();
  var scrollController = ScrollController();
  var message = '';
final hubProtLogger = Logger("SignalR - hub");
// If youn want to also to log out transport messages:
final transportProtLogger = Logger("SignalR - transport");

// The location of the SignalR Server.
final serverUrl = "http://10.0.2.2:5078/chathub";
final connectionOptions = HttpConnectionOptions;
// ignore: unnecessary_new

    @override
  void initState() {
   createSignalRConnection();
    // TODO: implement initState
    super.initState();
    
  }
  createSignalRConnection() async{
    final httpOptions = HttpConnectionOptions(logger: transportProtLogger);
    connection = HubConnectionBuilder().withUrl(serverUrl, options: httpOptions).configureLogging(hubProtLogger).build();
   
    await connection.start()?.catchError((onError)=>{
        // ignore: avoid_print
        print(onError)
     });
    // ignore: unrelated_type_equality_checks
    if(connection.state == HubConnectionState.Connected){
      print("connected");
    }
    else{
      print("not connect");
    }
    connection.on("displayStatus", (data) {
     // chats.add(data[0]);
      print(data);
      setState(() {
        chatModelList.add(ChatModel(data as String, true));
      }); 
    });
  }
  late HubConnection connection; 
    void animateList() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    Future.delayed(const Duration(milliseconds: 100), (){
        if(scrollController.offset != scrollController.position.maxScrollExtent) {
          animateList();
        }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F3),
      appBar:  AppBar(
        elevation: 12,
        titleSpacing: 10,
        backgroundColor:  mainColor,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
        ),
        leadingWidth: 20,
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(url),
          ),
          title: const Text(
            'Usama XD',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'online',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.videocam_rounded),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: chatModelList.length,
                itemBuilder: (context, index) => chatModelList.elementAt(index).isMee
                    ? SenderRowView(index: index,)
                    : ReceiverRowView(index: index),
              )),
          Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0,left: 8),
                  child: Icon(Icons.emoji_emotions_outlined, color: mainColor,),
                ),
                Expanded(
                  child: TextFormField(
                  maxLines: 6,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  controller: controller,
                  onFieldSubmitted: (value) {
                    controller.text = value;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8),
                      border: InputBorder.none,
                      focusColor: Colors.white,
                      hintText: 'Type a message',
                  ),
                ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, right: 10),
                  child: Transform.rotate(
                    angle: 45,
                    child: const Icon(
                      Icons.attachment_outlined,
                      color: mainColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                     if(connection.state == HubConnectionState.Connected)
                          // ignore: curly_braces_in_flow_control_structures
                          connection.invoke("Message",args: <Object>["flutter"]).catchError((onError)=>{
        // ignore: avoid_print
                              print(onError)
                          });
                      else
                          print("not connect!");
                    setState(() {
                      
                      chatModelList;
                      animateList();
                      controller.clear();
                    });
                  },
                  onLongPress: () {
                    
                    setState(() {
                      
                      chatModelList.add(ChatModel(controller.text, false));
                      animateList();
                      controller.clear();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 8, right: 8),
                    child: CircleAvatar(
                      backgroundColor: mainColor,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}