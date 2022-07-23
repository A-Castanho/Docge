import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

String createZip(Directory zipDirectory, String fileName, List<File> files) {

  var encoder = ZipFileEncoder();

  encoder.create(zipDirectory.path + '/$fileName.zip');
  for (var element in files) {
    encoder.addFile(element);
  }

  encoder.close();
  return encoder.zipPath;
}