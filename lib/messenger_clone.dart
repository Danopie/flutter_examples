import 'dart:ui';

import 'package:flutter/material.dart';

class MessengerClone extends StatefulWidget {
  @override
  _MessengerCloneState createState() => _MessengerCloneState();
}

class _MessengerCloneState extends State<MessengerClone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: _buildChatMessages()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  _buildChatMessages() {
    return ListView.builder(
      padding: EdgeInsets.only(
          bottom: kActionHeight + MediaQuery.of(context).padding.bottom),
      scrollDirection: Axis.vertical,
      reverse: true,
      itemBuilder: (context, index) => ListTile(
        title: Text("$index"),
      ),
    );
  }

  static const kActionHeight = 56.0;

  _buildActions() {
    return ClipRect(
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        height: kActionHeight,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Row(
            children: [
              Container(
                width: 8,
              ),
              Icon(
                Icons.add_circle,
                color: Colors.blue,
              ),
              Container(
                width: 4,
              ),
              Icon(
                Icons.camera_alt,
                color: Colors.blue,
              ),
              Container(
                width: 4,
              ),
              Icon(
                Icons.photo,
                color: Colors.blue,
              ),
              Container(
                width: 4,
              ),
              Icon(
                Icons.mic,
                color: Colors.blue,
              ),
              Expanded(
                child: _buildTextField(),
              ),
              Icon(
                Icons.forward,
                color: Colors.blue,
              ),
              Container(
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() => Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        height: kActionHeight - 24,
        child: TextField(
          style: TextStyle(
            fontSize: 12,
          ),
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.only(top: 12, bottom: 6, left: 16, right: 16),
              hintText: "Aa",
              fillColor: Colors.grey[200],
              focusColor: Colors.grey,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              )),
        ),
      );
}
