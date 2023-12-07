import 'package:flutter/material.dart';
import 'package:price_list/model/item_model.dart';
import 'package:price_list/model/price_model.dart';
import 'package:price_list/model/sale_type.dart';

class RetailItemPage extends StatelessWidget {

  final List<Item> itemList;
  const RetailItemPage({super.key, required this.itemList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

      itemCount: itemList.length,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Item item = itemList[index];
        return listItemBuilder(item);
      },
    );
  }

  Widget listItemBuilder(Item item){
    String itemName = item.name.toLowerCase();
    return Card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [ShaderMask(shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [Colors.transparent, Colors.black],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ).createShader(bounds);
            },blendMode: BlendMode.dstIn,child: ClipRRect( borderRadius: BorderRadius.circular(20),child: SizedBox(height:150,width: double.infinity,child: Image.asset('assets/$itemName.jpg',fit: BoxFit.cover)))),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(item.name,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0,top: 4),
                child: Text("("+item.unit+")",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              ),
            ],
          )]),
           
          setTableWidget(item)
        ],
      ),
    );
  }

  Widget setTableWidget(Item item){
    return DataTable(
        columnSpacing: 40,         columns: const <DataColumn>[
          DataColumn(
            label: Expanded(
              child: Text(
                'Name',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),

          DataColumn(
            label: Expanded(
              child: Text(
                'Yesterday',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Today',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                '',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
        rows: getDataRow(item)
    );
  }

  List<DataRow> getDataRow(Item item){
    List<DataRow> dataRowList = [];

    for (var element in item.priceList) {
      if(element.saleType == SaleType.retail.name) {
        DataRow dataRow = DataRow(cells: getDataCell(element, item.unit));
        dataRowList.add(dataRow);
      }
    }
    return dataRowList;
  }

  List<DataCell> getDataCell(Price price, String unitCode){
    List<DataCell> dataCellList = [];
     TextStyle textStyle = TextStyle(fontSize: 15);
    print(price.saleType.toString());

      DataCell marketCell = DataCell(Text(price.market,style: textStyle,));
      DataCell yesterdayPriceCell = DataCell(Text(price.yesterdayPrice,style: textStyle,));
      DataCell todayPriceCell = DataCell(Text(price.todayPrice,style: textStyle,));

      DataCell indicator = DataCell(getArrow(
          double.parse(price.yesterdayPrice), double.parse(price.todayPrice)));
      dataCellList.add(marketCell);
      dataCellList.add(yesterdayPriceCell);
      dataCellList.add(todayPriceCell);
      dataCellList.add(indicator);

    return dataCellList;
  }

  Widget getArrow(double yesPrice,double todayPrice){
    if(yesPrice>todayPrice)
      return Icon(Icons.download,color: Colors.green);
    else if (yesPrice<todayPrice)
      return Icon(Icons.upload,color: Colors.red);
    else
      return Container();
  }
}
