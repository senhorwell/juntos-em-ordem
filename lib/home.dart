import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference todos;
  Future? todosFuture;

  final List<String> images = [
    'assets/pessoas/jheni.png',
    'assets/pessoas/well.png',
    'assets/pessoas/alice.png',
    'assets/pessoas/helena.png',
    'assets/pessoas/julia.png',
  ];
  late List<bool> selectedImages;

  List<ChecklistItem> items = [];

  String selectedValue = 'Jheni';
  String? textInput;

  @override
  void initState() {
    super.initState();
    selectedImages = List<bool>.filled(images.length, false);
    selectedImages[0] = true;
    todosFuture = getTodos("jheni");
  }

  getTodos(String nome) {
    todos = database.ref().child(nome);
    items = [];
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        setState(() {
          items.add(ChecklistItem(
              id: key,
              pessoa: nome,
              title: value["atividade"],
              isSelected: value["feito"] == 1 ? true : false));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefdfd7),
      body: FutureBuilder(
        future: todosFuture,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            String arquivo = images[index].split('/').last;
                            getTodos(arquivo.split('.').first);

                            setState(() {
                              selectedImages =
                                  List<bool>.filled(images.length, false);
                              selectedImages[index] = !selectedImages[index];
                              selectedValue =
                                  arquivo.split('.').first.toCapitalized();
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (selectedImages[index])
                                const CircleAvatar(
                                  radius: 100,
                                  backgroundColor: Color(0xffb5b4a3),
                                ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipOval(
                                    child: Image.asset(
                                      images[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            color: items[index].isSelected
                                ? const Color(0xffb5b4a3)
                                : Colors.white,
                            child: ListTile(
                              title: Text(items[index].title,
                                  style: TextStyle(
                                      color: items[index].isSelected
                                          ? Colors.white
                                          : Colors.black)),
                              onTap: () async {
                                setState(() {
                                  items[index].isSelected =
                                      !items[index].isSelected;
                                });
                                DatabaseReference ref = FirebaseDatabase
                                    .instance
                                    .ref(items[index].pessoa)
                                    .child(items[index].id);
                                await ref.update({
                                  "feito": items[index].isSelected ? 1 : 0,
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffaead98),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Color.fromARGB(255, 243, 229, 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                        child: Text(
                      selectedValue,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffaead98),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: TextField(
                        onChanged: (value) {
                          textInput = value;
                        },
                        decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Color(0xffaead98), width: 5.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: const Color(0xffaead98).withOpacity(0.5),
                                width: 5.0),
                          ),
                          hintText: 'Adicione a atividade',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (states) => const Color(0xffaead98),
                            ),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                          onPressed: () {
                            DatabaseReference ref = FirebaseDatabase.instance
                                .ref(selectedValue.toLowerCase())
                                .push();
                            ref.set({
                              "atividade": textInput,
                              "feito": 0,
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Enviar', style: TextStyle(color: Colors.white, fontSize: 20),),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ChecklistItem {
  String title;
  bool isSelected;
  String id;
  String pessoa;

  ChecklistItem(
      {required this.id,
      required this.title,
      required this.isSelected,
      required this.pessoa});
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
