import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/firebaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otherprofile.dart';

var loginUser = FirebaseAuth.instance.currentUser;

class ChatScreen extends StatefulWidget {
  final String name;
  final String email;
  final String lastname;
  ChatScreen(@required this.name, @required this.email, @required this.lastname);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Service service = Service();
  final storeMessage = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  TextEditingController msg = TextEditingController();

  getCurrentUser() {
    final user = auth.currentUser;
    if (user != null) {
      loginUser = user;
      print(loginUser!.email.toString());
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                service.signOut(context);
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.remove("email");
              },
              icon: Icon(Icons.logout)),
        ],
        title: ListTile(
          leading: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> OtherProfile(widget.email),),);
            },
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                  'https://www.pngitem.com/pimgs/m/272-2720607_this-icon-for-gender-neutral-user-circle-hd.png'),
            ),
          ),
          title: Text("${widget.name} ${widget.lastname} "),
          subtitle: Text("SFE"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Displaying mesagges
            Container(
              
                child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    reverse: true,
                    child: ShowMessages())),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.blue, width: 0.2))),
                    child: TextField(
                      controller: msg,
                      decoration: InputDecoration(
                        hintText: "Enter the Message...",
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (msg.text.isNotEmpty) {
                        //var name= FirebaseFirestore.instance.collection('Messages').doc(loginUser!.email.toString()).snapshots();

                        storeMessage.collection('Messages').doc().set({
                          "messages": msg.text.trim(),
                          "user": loginUser!.email.toString(),
                          "time": DateTime.now(),
                          "name": loginUser!.email,
                          "to": widget.email,
                        });
                        msg.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send_outlined,
                      color: Colors.teal,
                    )),
              ],
            ),
          ],
        ),

      ),
    );
  }
}

class ShowMessages extends StatelessWidget {
  const ShowMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date2 = DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Messages")
          . orderBy('time')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
            // reverse: true,
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            primary: true,
            physics: ScrollPhysics(),
            itemBuilder: (context, i) {
              QueryDocumentSnapshot x = snapshot.data!.docs[i];
              return ListTile(
                title: Column(
                  crossAxisAlignment: loginUser!.email == x["user"]
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: loginUser!.email == x["user"]
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.amber.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15)
                      ),


                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          [
                        Text(x["messages"]),
                            SizedBox(
                              height: 5,
                            ),
                            Text(x['user'],
                            style: TextStyle(fontSize: 13, color: Colors.green)),
                            Text("${
                                (((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays/365)>1)? "${((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays)/365} Years Ago"
                                : (((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays/365)==1)? "${((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays)/365} Year Ago"
                                : (((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays/30)>1)? "${((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays)/30} Months Ago"
                                : (((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays/30)==1)? "${((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays)/30} Month Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays>1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inDays)} Days Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays==1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inDays)} Day Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inHours>1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inHours)} Hours Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inHours==1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inHours)} Hour Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inMinutes>1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inMinutes)} Minutes Ago"
                                : ((DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inMinutes==1)? "${(DateTime.now().difference(((x['time'] as Timestamp).toDate())).inMinutes)} Minute Ago"
                                    : "Just Now"

                            }",
                                style: TextStyle(fontSize: 13, color: Colors.green)),
                          ],
                      ),
                    ),
                    //(DateTime.now().difference(((x['time'] as Timestamp).toDate()))).inDays
                  ],
                ),
              );
            });
      },
    );
  }
}
