import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final _urlController = TextEditingController();
  final _classNameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  // Method to extract YouTube video ID from URL
  String getVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    } else if (uri != null && uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    }
    return '';
  }

  // Method to generate YouTube thumbnail URL
  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  void _addVideo() async {
    if (_urlController.text.isNotEmpty && _classNameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('class').add({
        'url': _urlController.text,
        'user': user!.email ?? 'default user',
        'className': _classNameController.text,
      });
      _urlController.clear();
      _classNameController.clear();
    }
  }

  void _launchURL(String url) async {
    print("url launched");
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add YouTube Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'YouTube URL'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Class Name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addVideo,
              child: Text('Add Video'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('class').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      String videoId = getVideoId(doc['url']);
                      String thumbnailUrl = getThumbnailUrl(videoId);
                      return GestureDetector(
                        onTap: () => _launchURL(doc['url']),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['className'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text('Added by: ${doc['user']}'),
                                SizedBox(height: 10),
                                CachedNetworkImage(
                                  imageUrl: thumbnailUrl,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
