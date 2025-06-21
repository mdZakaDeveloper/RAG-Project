import 'package:flutter/material.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => PromptScreenState();
}

class PromptScreenState extends State<PromptScreen> {
  TextEditingController _userQuery = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 50, left: 25, right: 25),
            child: TextField(
              controller: _userQuery,
              autofocus: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Ask something...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: false, // ❌ No background color
              ),
            )),
      ),
    );
  }
}
