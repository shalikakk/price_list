import 'package:price_list/model/price_model.dart';

class Item {
  final String name;
  final String unit;
  final List<Price>  priceList;

  Item(this.name, this.unit, this.priceList);
}