import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';
  int _page = 0;

  final int _limit = 20;

  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _visible = false;

  List _posts = [];

  void _loadMore() async {
    if (_hasNextPage == true && _isFirstLoadRunning == false && _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        final res = await http.get(Uri.parse('$_baseUrl?_page=$_page&$_limit=$_limit'));
        final List fetchPosts = json.decode(res.body);
        if (fetchPosts.isNotEmpty) {
          setState(() {
            _posts.addAll(fetchPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res = await http.get(Uri.parse('$_baseUrl?_page=$_page&$_limit=$_limit'));
      print(res.body);
      setState(() {
        _posts = json.decode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }
    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  late ScrollController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firstLoad();
    _controller = ScrollController()
      ..addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your news',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: _isFirstLoadRunning
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _posts.length,
                  controller: _controller,
                  itemBuilder: (_, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(_posts[index]['title']),
                        subtitle: Text(_posts[index]['body']),
                      ),
                    );
                  })),
          if (_isLoadMoreRunning == true)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_hasNextPage == false)
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              color: Colors.amber,
              child: const Center(
                child: Text('You have fetched all of the content'),
              ),
            )
        ],
      ),
    );
  }


}