import 'package:beatflow/screens/homescreen.dart';
import 'package:beatflow/screens/ytmusic.dart';
import 'package:beatflow/utis/musicScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Reference> files = [];
  List<Reference> filteredFiles = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listAllFiles();
  }

  Future<void> listAllFiles() async {
    Reference storageRef = FirebaseStorage.instance.ref().child("files");
    ListResult result = await storageRef.listAll();
    files = result.items;
    filteredFiles = List.from(files);
    setState(() {});
  }

  void handleSearch(String query) {
    filteredFiles = files
        .where((file) =>
            file.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  AudioFile convertReferenceToAudioFile(Reference reference) {
    return AudioFile(title: reference.name, url: '');
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: searchController,
          onChanged: (query) => handleSearch(query),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)), // Text color
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              handleSearch('');
            },
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSongFromYouTubeMusicScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 195, 210, 37), // Round label background color
                borderRadius: BorderRadius.circular(20), // Round label border radius
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Text(
                'Search on YTMusic',
                style: TextStyle(color: Colors.black), // Round label text color
              ),
            ),
          ),
        ],
      ),
      body: Container( // Wrap body with Container to set background color
        color: const Color.fromARGB(255, 32, 28, 28), // Set background color to black
        child: ListView.builder(
          itemCount: filteredFiles.length,
          itemBuilder: (context, index) {
            Reference file = filteredFiles[index];
            return ListTile(
              title: Text(file.name),
              textColor: Colors.white,
              onTap: () {
                AudioFile audioFile = convertReferenceToAudioFile(file);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicPlayerScreen(song: audioFile),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
