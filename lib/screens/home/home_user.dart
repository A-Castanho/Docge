import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:docge/Services/download/web_download_service.dart';
import 'package:docge/Services/firebase/storage.dart';
import 'package:docge/models/AppUser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Services/alert_displayer.dart';
import '../../Services/firebase/auth.dart';
import '../../Services/zipper.dart' as zipper;
import '../../Services/session_timer.dart';
import '../../shared/loading.dart';
import 'dart:collection';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'files_list_view.dart';
import 'package:universal_html/html.dart' as html;
import 'package:archive/archive.dart';
import 'dart:typed_data';

class FileCell{
  bool visTransfer = false;
  bool checked = false;
  double? downloadProgress;
  final Reference fileRef;
  final String name;
  final DateTime? timeCreated;
  FileCell({required this.fileRef, required this.name, required this.timeCreated});
}
class Month{
  final String name;
  final int year;
  final int monthId;

  bool checked = false;

  List<FileCell> files = List<FileCell>.empty(growable: true);
  Month({required this.year, required this.monthId, required this.name});
}

class HomeUser extends StatefulWidget {
  HomeUser({required this.user, Key? key}) : super(key: key);
  final AppUser user;

  @override
  State<HomeUser> createState() => _HomeUserState(user: user);
}

class _HomeUserState extends State<HomeUser> {
  _HomeUserState({required this.user});

  final AppUser user;

  bool loading = false;
  bool visCheckBoxes = false;
  String statusMessage = "";
  String selectionMotive = "";

  String? selectionText;

  late List<Month> listsByMonth = new List<Month>.empty(growable: true);
  late List<Reference> allUserFiles;

  final AuthService _auth = AuthService();
  final StorageService _storage = StorageService();


  @override
  Widget build(BuildContext context) {
    SessionTimer sessionTimer = SessionTimer();

    sessionTimer.startTimer();

    return loading
        ? Loading(status: statusMessage)
        : Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
              onPressed: (){
                _auth.signOut();
                Navigator.maybePop(context);
              },
              icon: Icon(Icons.logout),
              label: Text(""),
          )
        ],
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text("Ficheiros de ${user.email}")
        ),
      ),

      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            child: ButtonBar(
              buttonHeight: 100,
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Column(
                    children: [
                      const Text("Reiniciar"),
                      const Icon(Icons.refresh),
                    ],
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                ),
                TextButton(
                  child: Column(
                    children: [
                      const Text("Enviar"),
                      const Icon(Icons.add),
                    ],
                  ),
                  onPressed: () {
                    UploadFile();
                  },
                ),
                TextButton(
                  child: Column(
                    children: [
                      const Text("Transferir"),
                      const Icon(Icons.download),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      selectionText = "Selecione os ficheiros a transferir";
                      selectionMotive = "download";
                      visCheckBoxes = !visCheckBoxes;
                    });
                  },
                ),

                TextButton(
                  child: Column(
                    children: [
                      const Text("Eliminar"),
                      const Icon(Icons.delete),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      selectionText = "Selecione os ficheiros a eliminar";
                      selectionMotive = "delete";
                      visCheckBoxes = !visCheckBoxes;
                    });
                  },
                ),
              ],
            ),

            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.8, 1],
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                )
            ),
          ),



          Visibility(
            visible: visCheckBoxes,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(selectionText??"",
                      style: TextStyle(fontSize: 18)),
                ),
                ColoredBox(color: Colors.black, child: Container(height: 1)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<ListResult>(
                future: _storage.getAllUserFiles(user.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<ListResult> snapshot) {
                  if (snapshot.hasData) {
                    //List<Reference> files = List<Reference>.empty(growable: true);
                    if (snapshot.data != null) {
                      if (loading) {
                        setState(() {
                          loading = false;
                          statusMessage = "";
                        });
                      }
                      allUserFiles = snapshot.data!.items;
                      if (allUserFiles.isEmpty) {
                        return const Center(
                            child: Text("Não existem ficheiros para mostrar")
                        );
                      }
                      return FutureBuilder<List<Month>>(
                        future: SeparateLists(allUserFiles),
                        builder: (BuildContext context, AsyncSnapshot<List<
                            Month>> snapshot) {
                          if (snapshot.hasData) {
                            if (loading) {
                              setState(() {
                                loading = false;
                                statusMessage = "";
                              });
                            }

                            if (listsByMonth.isEmpty || !areListsEquivelant(
                                listsByMonth, snapshot.data!)) {
                              listsByMonth = snapshot.data!;
                            }

                            //List of months
                            return ListView.builder(
                              itemCount: listsByMonth.length,
                              itemBuilder: (context, indexMonth) {
                                //TODO Fix check boxes
                                Month month = listsByMonth[indexMonth];
                                month.files.sort((a,b){
                                  return a.timeCreated!.compareTo(b.timeCreated!);
                                  }
                                );
                                month.files = month.files.reversed.toList();

                                return ExpansionTile(
                                  title: visCheckBoxes ? Row(
                                    children: [
                                      Text(month.name),
                                      Checkbox(
                                          value: listsByMonth[indexMonth]
                                              .checked,
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                listsByMonth[indexMonth]
                                                    .checked = value;
                                                for (var element in listsByMonth[indexMonth]
                                                    .files) {
                                                  element.checked = value;
                                                }
                                              });
                                            }
                                          }),
                                    ],
                                  ) : GestureDetector(child: Text(month.name),
                                    onLongPress: () {

                                    },),

                                  initiallyExpanded: true,
                                  children: [
                                    //List of the files uploaded in that month
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0),
                                      child: ListView.builder(
                                        key: new Key("list_${month.name}"),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: month.files.length,
                                        itemBuilder: (context, indexFile) {
                                          FileCell fileCell = month
                                              .files[indexFile];
                                          bool fileOpened;
                                          bool downloadThisFile;
                                          return ListTile(
                                            onTap: () async =>{
                                              await openFile(indexFile,fileCell.fileRef, indexMonth),
                                              if(fileCell.downloadProgress!=null){
                                                setState(() =>
                                                listsByMonth[indexMonth]
                                                    .files[indexFile]
                                                    .downloadProgress = null),
                                              }
                                            },
                                            title: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text("${fileCell.name}"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(left: 8.0),
                                                  child: Text(DateFormat(
                                                      'dd-MM-yyyy – kk:mm')
                                                      .format(
                                                      fileCell.timeCreated!)),
                                                ),
                                              ],
                                            ),
                                            trailing: visCheckBoxes ? Checkbox(
                                              value: month.files[indexFile]
                                                  .checked,
                                              onChanged: (value) =>
                                              {
                                                if(value != null)
                                                  setState(() =>
                                                  listsByMonth[indexMonth]
                                                      .files[indexFile]
                                                      .checked = value),
                                              },
                                            ) : null,

                                            subtitle: fileCell
                                                .downloadProgress != null
                                                ? LinearProgressIndicator(
                                              valueColor: const AlwaysStoppedAnimation<
                                                  Color>(Colors.greenAccent),
                                              value: fileCell.downloadProgress,
                                            ) : null,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          }
                          return Loading(status: "A carregar os ficheiros");
                        },
                      );
                    }
                    else {
                      setState(() {
                        statusMessage = "A carregar os ficheiros";
                        loading = true;
                      });
                      //setState(()=> loading = true);
                      return Stack();
                    }
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Ocorreu um erro a carregar os ficheiros"));
                  }
                  else {
                    return Stack();
                  }
                }
            ),
          ),

        ],
      ),

      floatingActionButton: visCheckBoxes ? FloatingActionButton(
        onPressed: () {
          if(selectionMotive=="download"){
            downloadCheckedFiles();
          }
          else{
            deleteCheckedFiles();
          }
        },
        child: (selectionMotive=="download")? const Icon(Icons.download) : const Icon(Icons.delete) ,
      ) : null,
    );
  }

  Future<FilePickerResult?> PickFilesToUpload() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: "Selecione os ficheiros", allowMultiple: !kIsWeb);
    return result;
  }


  Future<void> UploadFile() async {
    String uploadOutcome;
      FilePickerResult? result = await PickFilesToUpload();
      if (result == null) {
        return;
      } else {
        //Showing the files names to the user
        String filenames = result.files.map((e) => e.name).join(",\n");
        filenames.substring(0, filenames.length - 2);

        bool confirmacao = await displayChoice(
            context, "Enviar os seguintes ficheiros?", filenames);

        print("confirmacao: " + confirmacao.toString());
        if (confirmacao) {
          String id = (await _auth.user.first)!.uid;

          try {
            if(!kIsWeb){
              List<File> filesList = result.files.map((e) => File(e.path!)).toList();
              filesList = await tryCompactFiles(filesList);

              statusMessage = "A enviar ficheiros";
              setState(() => loading = true);

              uploadOutcome = await _storage.uploadFilesToFirebase(filesList, id);
            }
            else{
              uploadOutcome = await _storage.uploadBytesToFirebase(result.files.first.bytes!, id, result.files.first.name);
            }
            displayWarning(context, "Envio dos ficheiros", uploadOutcome);
            statusMessage = "";
            setState(() => loading = false);
          } catch (e) {
            await displayWarning(context, "Erro", e.toString());
          }
        }
    }
  }


  Future<List<File>> tryCompactFiles(List<File> filesList) async {
    if (filesList.length > 1) {
      bool compactApproval = await displayChoice(context, "Enviar ficheiros",
          "Agrupar os ficheiros a enviar num ficheiro compactado?");

      if (compactApproval) {
        String zipName = await displayInputText(
            context, "Nome do ficheiro a compactar");

        final tempDir = await getTemporaryDirectory();
        String zipPath = zipper.createZip(
            tempDir, zipName.trim().replaceAll(".", ""), filesList);

        filesList.clear();
        filesList.add(File(zipPath));
      }
    }
    return filesList;
  }

  Future<List<File>> tryCompactData(List<File> filesList) async {



/*
    ZipFileEncoder zipFileEncoder = ZipFileEncoder();
    Archive archive = Archive();
    ArchiveFile archiveFiles = ArchiveFile.stream(
      filenames[0].toString(),
      files[0].lengthInBytes,
      files[0],
    );*/


    if (filesList.length > 1) {
      bool compactApproval = await displayChoice(context, "Enviar ficheiros",
          "Agrupar os ficheiros a enviar num ficheiro compactado?");

      if (compactApproval) {
        String zipName = await displayInputText(
            context, "Nome do ficheiro a compactar");

        final tempDir = await getTemporaryDirectory();
        String zipPath = zipper.createZip(
            tempDir, zipName.trim().replaceAll(".", ""), filesList);

        filesList.clear();
        filesList.add(File(zipPath));
      }
    }
    return filesList;
  }

  Future<List<Month>> SeparateLists(List<Reference> files) async {
    List<Month> lists = List<Month>.empty(growable: true);

    //Storing each file into its category
    try {
      await Future.forEach(files, (Reference file) async {
        FullMetadata fileMetadata = await file.getMetadata();

        String monthName = getMonthName(fileMetadata.timeCreated!);

        FileCell fileCell = FileCell(fileRef: file,
            name: fileMetadata.name,
            timeCreated: fileMetadata.timeCreated);

        //if(lists.)
        if (lists.firstWhereOrNull((m) => m.name == monthName) == null) {
          lists.add(Month(name: monthName,
              monthId: fileMetadata.timeCreated!.month,
              year: fileMetadata.timeCreated!.year));
        }
        lists
            .firstWhere((element) => element.name == monthName)
            .files
            .add(fileCell);
      });
    } catch (e) {
      print("Erro: " + e.toString());
    }
    return lists;
  }
  Future<void> openFile(int indexFile, Reference fileRef, int indexMonth) async {
    if(kIsWeb){
      final url = await fileRef.getDownloadURL();
      WebDownloadService().download(url: url, fileName: fileRef.name);
    }
    else{
      var dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/docge/${fileRef.name}";
      if(!await File(path).exists()){
        bool downloadThisFile = await displayChoice(context, "Ficheiro: ${fileRef.name}", "Deseja transferir e abrir o ficheiro?");
        if(downloadThisFile){
          await downloadFile(indexFile, fileRef, indexMonth);
        }
      }
      await OpenFile.open(path);
    }
  }

  String getMonthName(DateTime timeCreated) {
    int monthNumber = timeCreated.month;
    int year = timeCreated.year;
    switch (monthNumber) {
      case DateTime.january :
        return "Janeiro $year";
      case DateTime.february :
        return "Fevereiro $year";
      case DateTime.march :
        return "Março $year";
      case DateTime.april :
        return "Abril $year";
      case DateTime.may :
        return "Maio $year";
      case DateTime.june :
        return "Junho $year";
      case DateTime.july :
        return "Julho $year";
      case DateTime.august :
        return "Agosto $year";
      case DateTime.september :
        return "Setembro $year";
      case DateTime.october :
        return "Outubro $year";
      case DateTime.november :
        return "Novembro $year";
      case DateTime.december :
        return "Dezembro $year";
      default :
        return "Erro";
    }
  }

  Future downloadFile(int indexFile, Reference fileRef, int indexMonth) async {
    final url = await fileRef.getDownloadURL();

    // DownloadService downloadService =
    // kIsWeb ? WebDownloadService() : MobileDownloadService();
    // await downloadService.download(url: url);

    if (kIsWeb) {
      WebDownloadService().download(url: url, fileName: fileRef.name);
      //html.AnchorElement anchorElement;
      //anchorElement.click();
    }
    else {
      var dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/docge/${fileRef.name}";


      await Dio().download(
          url,
          path,
          onReceiveProgress: (received, total) {
            double progress = received / total;
            setState(() {
              listsByMonth[indexMonth].files[indexFile].downloadProgress =
                  progress;
            });
          }
      );

      await ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: GestureDetector(
              child: Text("Ficheiro transferido: \n${fileRef.name}"),
              onTap: () =>
              {
                 openFile(indexFile, fileRef, indexMonth)
              }
          )
          )
      );
      //showWarning(context, "Transferência", "Ficheiro transferido: \n${fileRef.name}");
    }
  }

  Future deleteFile(Reference fileRef) async {
    await _storage.deleteFromFirebase(user.uid, fileRef.name);
  }

  Future downloadCheckedFiles() async {
    if(visCheckBoxes){
      setState(() {
        visCheckBoxes = false;
      });
    }
    bool toZip = false;

    for (int monthIndex = 0; monthIndex < listsByMonth.length; monthIndex++) {
      for (int fileIndex = 0; fileIndex <
          listsByMonth[monthIndex].files.length; fileIndex++) {
        FileCell cell = listsByMonth[monthIndex].files[fileIndex];
        if (cell.checked) {
          await downloadFile(fileIndex, cell.fileRef, monthIndex);
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos os ficheiros foram transferidos"))
    );
    //showWarning(context, "Transferência", "Ficheiro transferido: \n${fileRef.name}");
  }

  Future deleteCheckedFiles() async {
    if(visCheckBoxes){
      setState(() {
        visCheckBoxes = false;
      });
    }

    for (int monthIndex = 0; monthIndex < listsByMonth.length; monthIndex++) {
      for (int fileIndex = 0; fileIndex <
          listsByMonth[monthIndex].files.length; fileIndex++) {
        FileCell cell = listsByMonth[monthIndex].files[fileIndex];
        if (cell.checked) {
          await deleteFile(cell.fileRef);
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos os ficheiros foram eliminados"))
    );
    setState(() {});
  }

  bool areListsEquivelant(List<Month> firstList, List<Month> secondList) {
    //Check if the lenght of the lists of months is the same
    if (firstList.length == secondList.length) {
      //Checks each month
      for (var firstListMonth in firstList) {
        //Check if each month exists in both lists
        Month? secondListMonth = secondList.firstWhereOrNull((
            secondListMonth) => secondListMonth.name == firstListMonth.name);
        if (secondListMonth != null) {
          //Check if the lenght of the list of files in both lists of months is the same
          if (firstListMonth.files.length == secondListMonth.files.length) {
            for (var firstListFile in firstListMonth.files) {
              FileCell? secondListFile = secondListMonth.files
                  .firstWhereOrNull((element) =>
              element.name == firstListFile.name);
              if (secondListFile != null) {
                if (secondListFile.fileRef != firstListFile.fileRef) {
                  return false;
                }
              } else {
                return false;
              }
            }
          }
          else {
            return false;
          }
        } else {
          return false;
        }
      }
    }
    return true;
  }
}