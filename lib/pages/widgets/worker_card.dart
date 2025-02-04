import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Widget buildWorkerCard(String workerName, String position) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container( decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),),
      child: ListTile(
        title: Text(workerName,),
        subtitle: Text(position,),
        trailing: Icon(Icons.person),
      ),
    ),
  );
}