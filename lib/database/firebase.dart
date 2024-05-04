import 'package:firebase_database/firebase_database.dart';

import '../models/checklist_item.dart';

class FirebaseLocalDatabase {
  FirebaseLocalDatabase() {
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);

    selectedImages = List<bool>.filled(images.length, false);
    selectedImages[0] = true;
  }
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference todos;
  List<ChecklistItem> items = [];
  late List<bool> selectedImages;
  late List<int> selectedPoints = [0, 0, 0, 0, 0];
  String selectedValue = 'Jheni';

  final List<String> images = [
    'assets/pessoas/jheni.png',
    'assets/pessoas/well.png',
    'assets/pessoas/alice.png',
    'assets/pessoas/helena.png',
    'assets/pessoas/julia.png',
  ];

  save(ChecklistItem checklistItem) async {
    DatabaseReference ref = database.ref(checklistItem.pessoa).push();
    await ref.set({
      "atividade": checklistItem.title,
      "ponto": checklistItem.ponto,
      "feito": 0,
      "prioridade": checklistItem.prioridade,
    });
  }

  List<ChecklistItem> read(String nome) {
    todos = database.ref().child(nome.toLowerCase());
    items = [];
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        items.add(ChecklistItem(
            id: key,
            pessoa: nome,
            title: value["atividade"],
            ponto: int.parse(value["ponto"].toString()),
            isSelected: value["feito"] == 1 ? true : false,
            prioridade: value["prioridade"]));
      });
    });
    getPoints(nome);
    return items;
  }

  String getPoints(String nome) {
    todos = database.ref().child(nome.toLowerCase());
    items = [];
    selectedPoints[images.indexOf('assets/pessoas/$nome.png')] = 0;
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        if (value["feito"] == 1) {
          selectedPoints[images.indexOf('assets/pessoas/$nome.png')] +=
              int.parse(value["ponto"].toString());
        }
      });
    });

    return selectedPoints[images.indexOf('assets/pessoas/$nome.png')]
        .toString();
  }

  getTodos(String nome) {
    todos = database.ref().child(nome.toLowerCase());
    items = [];
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        items.add(ChecklistItem(
            id: key,
            pessoa: nome,
            title: value["atividade"],
            ponto: int.parse(value["ponto"].toString()),
            isSelected: value["feito"] == 1 ? true : false,
            prioridade: value["prioridade"]));
      });
    });
  }

  update(ChecklistItem item) async {
    DatabaseReference ref = database.ref(item.pessoa).child(item.id);
    await ref.update({
      "feito": item.isSelected ? 1 : 0,
    });
  }

  delete(ChecklistItem item) async {
    DatabaseReference ref = database.ref(item.pessoa).child(item.id);
    await ref.remove();
  }
}
