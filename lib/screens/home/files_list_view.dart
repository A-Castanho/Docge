import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../Services/firebase/storage.dart';
import '../../models/AppUser.dart';
import '../../shared/loading.dart';

class FilesListView extends StatefulWidget {
  const FilesListView({required this.user,Key? key}) : super(key: key);
  final AppUser user;

  @override
  State<FilesListView> createState() => _FilesListViewState(user: user);
}

class _FilesListViewState extends State<FilesListView> {

  _FilesListViewState({required this.user});
  final AppUser user;

  final StorageService _storage = StorageService();


  bool loading = false;
  String status = "";

  late Future<ListResult> futureFiles = _storage.getAllUserFiles(user.uid);
  Map<int, double> downloadProgress = {};

  Map<String, bool> listsChecked = {};
  Map<String, List<bool>> itemsChecked = {};

  @override
  Widget build(BuildContext context) {
    return loading? Loading(status: status) : FutureBuilder<ListResult>(
        future: _storage.getAllUserFiles(user.uid),
        builder: (BuildContext context,AsyncSnapshot<ListResult> snapshot) {
          if (snapshot.hasData ) {
             //List<Reference> files = List<Reference>.empty(growable: true);
              if(snapshot.data!=null){
                List<Reference> files = snapshot.data!.items;

                final listsByMonthFuture = SeparateLists(files);

                return FutureBuilder<Map<String, List<FullMetadata>>>(
                  future: listsByMonthFuture,
                  builder: (context, snapshot) {
                    final listsByMonth = snapshot.data?? <String, List<FullMetadata>>{};
                    //List of months
                    return ListView.builder(
                      itemCount: listsByMonth.length,
                      itemBuilder: (context, index) {
                        String month = listsByMonth.keys.elementAt(index);
                        if(itemsChecked[month]==null) {
                          itemsChecked[month] = List<bool>.filled(listsByMonth[month]!.length, false);
                        }

                        return ExpansionTile(
                          title: Text(month),

                          leading: Checkbox(
                            value: listsChecked[month]??false,
                            onChanged: (checked){
                              setState(() => listsChecked[month]=checked??false);
                              itemsChecked[month]!.setAll(0, List.filled(listsByMonth[month]!.length, checked??false));
                              setState(() => itemsChecked=itemsChecked);

                              for (var f in itemsChecked[month]!) {
                                setState(() =>(f = checked??false));
                              }
                            },
                          ),
                          initiallyExpanded: true,
                          children: [
                            //List of the files uploaded in that month
                            Padding(
                              padding: const EdgeInsets.only(left:10.0),
                              child: ListView.builder(
                                key: Key("list_${month}"),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: listsByMonth[month]!.length,
                                itemBuilder: (context, index) {

                                  final Reference fileRef = files.firstWhere((
                                      element) =>
                                  element.name == listsByMonth[month]![index].name);
                                  double? progress = downloadProgress[files.indexOf(
                                      fileRef)];

                                  return ListTile(
                                    title: Text(
                                        "${listsByMonth[month]![index].name}"),

                                    leading: Checkbox(
                                      value: itemsChecked[month]![index],
                                      onChanged: (checked)=>{
                                        setState(()=>itemsChecked[month]![index]=checked??false),
                                      },
                                    ),

                                    // trailing: IconButton(
                                    //   icon: Icon(Icons.download),
                                    //   onPressed: () {
                                    //     double? progress = downloadProgress[files
                                    //         .indexOf(
                                    //         fileRef)];
                                    //     downloadFile(index, fileRef);
                                    //   },
                                    // ),
                                    //
                                    // subtitle: progress != null
                                    //     ? LinearProgressIndicator(
                                    //   valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                    //   value: progress,
                                    // ): null,
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              }
              else{
                status = "A carregar os ficheiros";
                //setState(()=> loading = true);
                return Loading(status: status);
              }

          } else if (snapshot.hasError) {
          return const Center(
          child: Text("Não foram detetados nenhuns dados"));
          }
          else {
            status = "A carregar os ficheiros";
            //setState(()=> loading = true);
            return Loading(status: status);
          }
        }
      );
  }


  Future<Map<String,List<FullMetadata>>> SeparateLists(List<Reference> files) async {

    //The map with the name of the month and the list of files
    Map<String,List<FullMetadata>> lists = Map<String,List<FullMetadata>>();

    //Storing each file into its category
    await Future.forEach(files,(Reference file) async {
      FullMetadata fileMetadata = await file.getMetadata();

      String monthName = getMonthName(fileMetadata.timeCreated!);


      if(!lists.containsKey(monthName)){
        lists[monthName] = List<FullMetadata>.empty(growable: true);
      }
      List<FullMetadata> list = lists[monthName]!;


      list.add(fileMetadata);
      lists.update(monthName, (value) => list);

    });




    return lists;
  }

  String getMonthName(DateTime timeCreated) {
    int monthNumber = timeCreated.month;
    int year = timeCreated.year;
    switch(monthNumber){
      case DateTime.january : return "Janeiro $year";
      case DateTime.february : return "Fevereiro $year";
      case DateTime.march : return "Março $year";
      case DateTime.april : return "Abril $year";
      case DateTime.may : return "Maio $year";
      case DateTime.june : return "Junho $year";
      case DateTime.july : return "Julho $year";
      case DateTime.august : return "Agosto $year";
      case DateTime.september : return "Setembro $year";
      case DateTime.october : return "Outubro $year";
      case DateTime.november : return "Novembro $year";
      case DateTime.december : return "Dezembro $year";
      default : return "Erro";
    }
  }

  Future downloadFile(int index, Reference fileRef) async{
    final url = await fileRef.getDownloadURL();

    //App's temporary directory
    final tempDir = await getTemporaryDirectory();
    final path = "${tempDir.path}/${fileRef.name}";
    await Dio().download(
        url,
        path,
        onReceiveProgress: (received,total){
          double progress = received / total;
          setState(() {
            downloadProgress[index] = progress;
          });
        }
    );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ficheiro transferido: \n${fileRef.name}"))
    );
    //showWarning(context, "Transferência", "Ficheiro transferido: \n${fileRef.name}");
  }
}

