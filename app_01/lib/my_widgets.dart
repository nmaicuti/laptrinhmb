import 'package:flutter/material.dart';
class MyStatelessWidget extends StatelessWidget {
   final String title;
   MyStatelessWidget({required this.title});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text(title),
       ),
       body: Center(
         child: Text(title),
       ),
     );
   }
}

// ====

class MyStatefulWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>{
  String title ="Hello, Nguyen Ngoc Mai";
  int count = 0;
  void _updateTitle(){
    setState(() {
      title = "Hello, Nguyen Ngoc Mai ${count++}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          Text(title),
          ElevatedButton(onPressed: _updateTitle, child: Text('Updated Title')),
        ],
      ),
    );
  }
}
