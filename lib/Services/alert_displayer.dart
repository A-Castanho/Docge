import 'package:flutter/material.dart';

Future <String> displayInputText(BuildContext context, String title) async {
  String input="ficheiro_compactado";

  TextEditingController inputcontroller = TextEditingController();

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: TextField(
          controller: inputcontroller,
          decoration: const InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Insira o nome para o ficheiro',
          )
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Sim');
            if(inputcontroller.text.trim().isNotEmpty){
              input = inputcontroller.text;
            }
          },
          child: const Text('Concluir', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
  return input;
}

Future displayWarning(BuildContext context, String title, String message) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('Ok', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}

Future<bool> displayChoice(BuildContext context, String title, String message) async {
  bool result = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            result = false;
            Navigator.pop(context, 'Não');
          },
          child: const Text('Não', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            result = true;
            Navigator.pop(context, 'Sim');
          },
          child: const Text('Sim', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
  print("we here");
  return result;
}