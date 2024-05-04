import 'package:juntos_em_ordem/database/firebase.dart';

class ChecklistItem {
  String title;
  bool isSelected;
  String id;
  String pessoa;
  int ponto;
  int prioridade;
  FirebaseLocalDatabase firebase = FirebaseLocalDatabase();

  ChecklistItem(
      {required this.id,
      required this.title,
      required this.isSelected,
      required this.ponto,
      required this.pessoa,
      required this.prioridade});

  saveChecklistItem() async {
    firebase.save(ChecklistItem(
        id: "",
        title: title,
        isSelected: isSelected,
        ponto: ponto,
        pessoa: pessoa,
        prioridade: prioridade));
  }
}
