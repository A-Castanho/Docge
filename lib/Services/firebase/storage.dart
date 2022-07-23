import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:docge/Services/alert_displayer.dart';
import 'package:docge/Services/firebase/auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../models/AppUser.dart';



class StorageService{
  String status="";
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ListResult> getAllUserFiles(String userId) async{
    return FirebaseStorage.instance.ref("userFiles/$userId").listAll();
  }

  Future<String> uploadFilesToFirebase(List<File> platformFiles, String userId) async {
    try{
      List<Reference> dbFiles = (await getAllUserFiles(userId)).items;
      for(int i=0; i<platformFiles.length;i++){
        File file = platformFiles[i];
        String toStoreName = p.basename(file.path);

        status = "A enviar ${toStoreName} ($i/${platformFiles.length})";

        for(int i = 2; dbFiles.firstWhereOrNull((element) => element.name==toStoreName)!=null; i++){
          toStoreName = p.withoutExtension(toStoreName)+"($i)"+p.extension(toStoreName);
        }

        String storagePath = "userFiles/$userId/$toStoreName";
        //file.rename(newPath)

        final ref = _storage.ref().child(storagePath);
        await ref.putFile(file);
      }
      return "Ficheiros Enviados";
    }
    catch(e){
      return "Erro no envio de ficheiros. \nErro:${e.toString()}";
    }
  }

  Future<String> uploadBytesToFirebase(Uint8List file, String userId, String filesName) async {
    try{
      List<Reference> dbFiles = (await getAllUserFiles(userId)).items;

      for(int i = 2; dbFiles.firstWhereOrNull((element) => element.name==filesName)!=null; i++){
        filesName = p.withoutExtension(filesName)+"($i)"+p.extension(filesName);
      }

      String storagePath = "userFiles/$userId/$filesName";
      //file.rename(newPath)

      final ref = _storage.ref().child(storagePath);
      await ref.putData(file);
      return "Ficheiros enviados";
    }
    catch(e){
      return "Erro: ${e.toString()}";
    }
  }
  Future<String> deleteFromFirebase(String userId, String filesName) async {
    try{

      String storagePath = "userFiles/$userId/$filesName";

      await _storage.ref(storagePath).delete();
      return "Ficheiro ELIMINADO";
    }
    catch(e){
      return "Erro: ${e.toString()}";
    }
  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }
}