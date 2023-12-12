import 'package:flutter/foundation.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> cardList = [];

  Future<void> fetchCardData() async {
    // Aquí puedes realizar la lógica para obtener los datos de tu base de datos
    // y asignarlos a la lista cardList

    // Por ahora, utilizaremos datos ficticios
    cardList = [
      CardData(
        imageUrl: 'https://cdn.actronics.nl/image/opel-zafira-a.jpg',
        title: 'Título 1',
        stars: '4.9 Stars',
      ),
      CardData(
        imageUrl: 'https://cdn.actronics.nl/image/opel-zafira-a.jpg',
        title: 'Título 2',
        stars: '4.7 Stars',
      ),
      CardData(
        imageUrl: 'https://cdn.actronics.nl/image/opel-zafira-a.jpg',
        title: 'Título 3',
        stars: '4.5 Stars',
      ),
    ];

    notifyListeners();
  }
}

class CardData {
  final String imageUrl;
  final String title;
  final String stars;

  CardData({
    required this.imageUrl,
    required this.title,
    required this.stars,
  });
}
