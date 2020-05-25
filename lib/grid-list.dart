// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:gallery/l10n/gallery_localizations.dart';
import 'package:http/http.dart' as http;

class _Photo {
  final String id;
  final String author;
  final String downloadUrl;
  final String thumbImage;

  _Photo({this.author, this.id, this.downloadUrl, this.thumbImage});

  factory _Photo.fromJson(Map<String, dynamic> json) {
    return _Photo(
      id: json['id'],
      author: json['author'],
      downloadUrl: json['download_url'],
      thumbImage: 'https://picsum.photos/id/'+ json['id'] + '/300/200',
    );
  }
}

class GridListDemo extends StatefulWidget {
  const GridListDemo({Key key}) : super(key: key);

  @override
  _GridList createState() => _GridList();
}

class _GridList extends State<GridListDemo> {

  Future fetchAlbum() async {
    final response =
        await http.get('https://picsum.photos/v2/list?page=1&limit=100');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return json.decode(response.body) as List;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  albumWidget() {
    return FutureBuilder(
      future: fetchAlbum(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            childAspectRatio: 1,
            children: snapshot.data.map<Widget>((photo) {
              print(photo);
              return _GridDemoPhotoItem(
                photo: _Photo.fromJson(photo)
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return LinearProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return albumWidget();
  }
}


/// Allow the text size to shrink to fit in the space
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

class _GridDemoPhotoItem extends StatelessWidget {
  _GridDemoPhotoItem({
    Key key,
    @required this.photo,
  }) : super(key: key);

  final _Photo photo;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Image.network(photo.thumbImage));

    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(photo.author),
          // subtitle: _GridTitleText(photo.subtitle),
        ),
      ),
      child: image,
    );
  }
}
