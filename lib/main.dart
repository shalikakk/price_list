import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio _dio = Dio();
  double _progress = 0;
  bool _downloading = false;
  late String _pdfPath;

  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';


  List<String> itemNameList = ["Beans","Carrot","Cabbage","Tomato","Brinjal","Pumpkin","Snake gourd","Green Chilli"];
  List<Item> itemList = [];
  Future<void> _extractAllText(File file) async {
    //Load the existing PDF document.
    PdfDocument document =
    PdfDocument(
        inputBytes: await _readDocumentData(file));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    String text = extractor.extractText();

    //Display the text.
    _showResult(text);
  }

  Future<List<int>> _readDocumentData(File file) async {
    final  data = await file.readAsBytes();
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }


  @override
  void initState() {
    super.initState();
  }



  Future<bool> saveFile(String url, String fileName) async {
    try {
      //if (await _requestPermission(Permission.storage)) {
        Directory? directory;
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/PDF_Download";
        directory = Directory(newPath);

        File saveFile = File(directory.path + "/$fileName");

          print(saveFile.path);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          await Dio().download(
            url,
            saveFile.path,
          );
        }
      //}
      return true;
    } catch (e) {
      return false;
    }
  }



  Future download(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) { return status! < 500; }
        ),
      );
      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await file.close();

      // Here, you're catching an error and printing it. For production
      // apps, you should display the warning to the user and give them a
      // way to restart the download.
    } catch (e) {
      print(e);
    }
  }

  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString = '✅ File has finished downloading. Try opening the file.';
        didDownloadPDF = true;
      } else {
        progressString = 'Download progress: ' + (progress * 100).toStringAsFixed(0) + '% done.';
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Download'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_downloading)
              Text('Downloading... ${(100 * _progress).toStringAsFixed(2)}%'),
            ElevatedButton(
                onPressed: () async {

                    if (Platform.isIOS || Platform.isAndroid) {
                      bool status = await Permission.storage.isGranted;

                      if (!status) await Permission.storage.request();
                    }




                  // String path = await FileSaver.instance.saveFile(
                  //     name:  "File",
                  //     //link:  linkController.text,
                  //     bytes: Uint8List.fromList(excel.encode()!),
                  //     ext: '.pdf',
                  //
                  //     ///extController.text,
                  //     mimeType: MimeType.pdf);
                  //print(path);
                },
                child: const Text("Save File")),

            TextButton(
              // Here, you download and store the PDF file in the temporary
              // directory.
              
              onPressed: didDownloadPDF ? null : () async {
                var tempDir = await getTemporaryDirectory();
                download(Dio(), "https://www.cbsl.gov.lk/sites/default/files/cbslweb_documents/statistics/pricerpt/price_report_20231208.pdf", tempDir.path + "/TETSTTT.pdf");
              },
              child: Text('Download a PDF file'),
            ),
            Text(
              progressString,
            ),
            TextButton(
              // Disable the button if no PDF is downloaded yet. Once the
              // PDF file is downloaded, you can then open it using PSPDFKit.
              // onPressed: !didDownloadPDF ? null : () async {
              //   var tempDir = await getTemporaryDirectory();
              //   _extractAllText(tempDir.path+"/TETSTTT.pdf");
              //   ///data/data/com.shalika.price_list/cache/TETSTTT.pdf
              //   print(tempDir.path + "/TETSTTT");
              // },
              onPressed: () async {
                const url =
                    "http://www.africau.edu/images/default/sample.pdf";
                final file = await loadPdfFromNetwork(url);
                _extractAllText(file);
              },
              child: Text('Open the downloaded file using PSPDFKit'),
            ),
          ],
        ),
      ),
    );
    // return DefaultTabController(
    //   length: 2,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       backgroundColor: Theme
    //           .of(context)
    //           .colorScheme
    //           .inversePrimary,
    //       title: Text("Price List"),
    //       bottom: const TabBar(
    //         tabs: [
    //           Tab(child: Text("Retail"),),
    //           Tab(child: Text("Wholesale"),),
    //         ],
    //       ),
    //     ),
    //     body:  TabBarView(
    //       children: [
    //         RetailItemPage(itemList: itemList),
    //         WholesaleItemPage(itemList: itemList),
    //       ],
    //     ),
    //     floatingActionButton: FloatingActionButton(
    //       onPressed: _extractAllText,
    //       tooltip: 'Increment',
    //       child: const Icon(Icons.add),
    //     ), // This trailing comma makes auto-formatting nicer for build methods.
    //   ),
    // );
  }

  Future<File> loadPdfFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return _storeFile(url, bytes);
  }

  Future<File> _storeFile(String url, List<int> bytes) async {

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/price.pdf');
    await file.writeAsBytes(bytes, flush: true);

      print('$file');
    return file;
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
