
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference todos = database.ref().child("jheni");

  final List<String> images = [
    'assets/pessoas/jheni.png',
    'assets/pessoas/well.png',
    'assets/pessoas/alice.png',
    'assets/pessoas/helena.png',
    'assets/pessoas/julia.png',
  ];

  List<ChecklistItem> items = [];

  @override
  void initState() {
    getTodos('jheni');
    super.initState();
  }

  getTodos(String nome) {
    todos = database.ref().child(nome.toLowerCase());
    items = [];
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
          setState(() {
          items.add(ChecklistItem(title: value["atividade"]));
        });
      });
    });

    
  
  } 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      String arquivo = images[index].split('/').last;
                      getTodos(arquivo.split('.').first);
                    },
                    child: AspectRatio(
                      aspectRatio: 1, // Para manter a imagem quadrada
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
                  );
                },
              ),
            ),
            Column(
              children: [
                ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Card(
                      color: items[index].isSelected ? Colors.green : null,
                      child: ListTile(
                        title: Text('${items[index].title} ${index + 1}'),
                        onTap: () {
                          setState(() {
                            items[index].isSelected = !items[index].isSelected;
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String? selectedValue = 'Jheni';
              String? textInput;
              String? dateInput;
              return AlertDialog(
                title: const Text('Selecione uma pessoa'),
                content: Column(
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Selecione uma opção'),
                      value: selectedValue,
                      items: <String>[
                        'Jheni',
                        'Well',
                        'Alice',
                        'Helena',
                        'Julia'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                    ),
                    TextField(
                      onChanged: (value) {
                        textInput = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Adicione a atividade',
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) {
                        dateInput = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Periodico ou apenas hoje?',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Enviar'),
                    onPressed: () async {
                      DatabaseReference ref = FirebaseDatabase.instance.ref(selectedValue!.toLowerCase()).push();
                      await ref.set({
                        "atividade": textInput,
                        "feito": 0,
                        "periodico" : dateInput,
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ChecklistItem {
  String title;
  bool isSelected = false;

  ChecklistItem({required this.title});
}
