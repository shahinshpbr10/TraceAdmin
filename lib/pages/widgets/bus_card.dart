import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Widget buildBusCard(String busName, String route, String number) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green)),
      child: ListTile(
        title: Text(
          busName,
      
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route, ),
            Text(
              number,
             
            ),
          ],
        ),
        trailing: Image(
          image: AssetImage('assets/Images/busone.png'),
          width: 50,
        ),
      ),
    ),
  );
}
