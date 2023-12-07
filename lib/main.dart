import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:price_list/model/item_model.dart';
import 'package:price_list/model/market_list.dart';
import 'package:price_list/model/price_model.dart';
import 'package:price_list/model/sale_type.dart';
import 'package:price_list/retails_page.dart';
import 'package:price_list/wholesale_page.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController mycontroller = TextEditingController();

List<String> itemNameList = ["Beans","Carrot","Cabbage","Tomato","Brinjal","Pumpkin","Snake gourd","Green Chilli"];
List<Item> itemList = [];
  Future<void> _extractAllText() async {
    //Load the existing PDF document.
    PdfDocument document =
    PdfDocument(
        inputBytes: await _readDocumentData('price_report_20231130.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    String text = extractor.extractText();

    //Display the text.
    _showResult(text);
  }

  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text("Price List"),
          bottom: const TabBar(
            tabs: [
              Tab(child: Text("Retail"),),
              Tab(child: Text("Wholesale"),),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            RetailItemPage(itemList: itemList),
            WholesaleItemPage(itemList: itemList),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _extractAllText,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Widget listItemBuilder(Item item){
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 150,
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(15) // Adjust the radius as needed
                ),
                child: Image.asset('assets/beans.jpg'),
              ),
              Text(item.name),
              Text(item.unit),
            ],
          ),
            setTableWidget(item)
        ],
      ),
    );
  }

  Widget setTableWidget(Item item){
    return DataTable(
      columns: const <DataColumn>[
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
              'Yest',
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
              'indicator',
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

    item.priceList.forEach((element) {

      DataRow dataRow = DataRow(cells: getDataCell(element,item.unit));
      dataRowList.add(dataRow);
    });
    return dataRowList;
  }

  List<DataCell> getDataCell(Price price, String unitCode){
    List<DataCell> dataCellList = [];


      DataCell marketCell = DataCell(Text(price.market));
      DataCell yesterdayPriceCell = DataCell(Text(price.yesterdayPrice));
      DataCell todayPriceCell = DataCell(Text(price.todayPrice));      
      
      DataCell indicator = DataCell(getArrow(double.parse(price.yesterdayPrice), double.parse(price.todayPrice)));
      dataCellList.add(marketCell);
      dataCellList.add(yesterdayPriceCell);
      dataCellList.add(todayPriceCell);
    dataCellList.add(indicator);


    print("sssss");
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

  void _showResult(String text) {
    text = text.replaceAll("\n", "");
    List<String> text1 = text.split("Today");
    // String text2  = text1.last.replaceAll(new RegExp("[ \n\t\r\f]"), '*');
    // mycontroller.text = text2.replaceAll("************", ' ');
    String text2  = text1.last.replaceAll(new RegExp("\r        "), '');
    String text3  = text2.replaceAll(new RegExp(" \r"), '');
    String text4  = text3.replaceAll(new RegExp("\r"), ' ');
    text4  = text4.replaceAll(new RegExp(","), '');
    //String text5 = text4.split(" ");
    for(String ele in itemNameList){
      String text5 =  text4.split(ele).last;
      List<String> text6 =  text5.split(" ");
      text6.removeAt(0);
      List<Price> priceList = [
       Price(Market.Pettah.name, SaleType.wholesale.name,  text6[1], text6[2]),
      Price(Market.Dambulla.name, SaleType.wholesale.name,  text6[3], text6[4]),
       Price(Market.Pettah.name, SaleType.retail.name,  text6[5], text6[6]),
      Price(Market.Dambulla.name, SaleType.retail.name,  text6[7], text6[8]),
      Price(Market.Narahenpita.name, SaleType.retail.name,  text6[9], text6[10])];


      // for(int i = 2;i<=11;i++){
      //   priceList.add(text6[i]);
      // }
      //
      //
      // SaleType.values.forEach((saleType) {
      //   if(saleType == "wholesale"){
      //     Market.values.forEach((market) {
      //       if(market.toString() == "Pettah"){
      //
      //       }
      //     });
      //     Price price = Price(name.toString(), priceType, unit, yesterdayPrice, todayPrice)
      //   }
      // });
      Item item = Item(ele, text6[0], priceList);
      itemList.add(item);
      setState(() {

      });
      print(itemList);
    }
    mycontroller.text = text4.split("Carrot").first;



    FocusManager.instance.primaryFocus?.unfocus();
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Extracted text'),
//             content: Scrollbar(
//               child: SingleChildScrollView(
//                 child: Text(text1.last),
//                 physics: BouncingScrollPhysics(
//                     parent: AlwaysScrollableScrollPhysics()),
//               ),
//             ),
//             actions: [
//               ElevatedButton(
//                 child: Text('Close'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         });
//   }
  }
}
