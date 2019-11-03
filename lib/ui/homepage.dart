import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import  'package:transparent_image/transparent_image.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  String searchTerm;
  int offset = 0;

  Future<Map> _getGifs() async{
    Response response;

    if (searchTerm == null){
      response = await Dio().get('https://api.giphy.com/v1/gifs/trending?api_key=QqlLOSG4m5xi5dBdfxNZqqp2Bav8J5DZ&limit=25&rating=G');
    }
    else response = await Dio().get('https://api.giphy.com/v1/gifs/search?api_key=QqlLOSG4m5xi5dBdfxNZqqp2Bav8J5DZ&q=$searchTerm&limit=25&offset=$offset&rating=G&lang=en');

    return response.data;
  }

  _getItensCount(List data) => searchTerm == null ? data.length : data.length + 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGifs().then(print);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() => searchTerm = text);
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      );
                      break;
                    default:
                      return _buildGifsTable(context, snapshot);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGifsTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
      ),
      itemCount: _getItensCount(snapshot.data['data']),
      itemBuilder: (context, index){
        if (searchTerm == null || index < snapshot.data['data'].length){
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: snapshot.data['data'][index]['images']['fixed_height']['url'],
              placeholder: kTransparentImage,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data['data'][index])
              ));
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        }
        else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add, color: Colors.white,),
                Text('Carregar mais...', style: TextStyle(color: Colors.white, fontSize: 22), textAlign: TextAlign.center)
              ],
            ),
            onTap: (){
              setState(() => offset += 25);
            },
          );
        }
      },
    );
  }
}