import 'package:beatflow/screens/search.dart';
import 'package:beatflow/screens/settings.dart';
import 'package:beatflow/utis/musicScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyMusicApp());
}

class AudioFile {
  final String title;
  final String url;

  AudioFile({
    required this.title,
    required this.url,
  });
}

class MyMusicApp extends StatelessWidget {
  const MyMusicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeatFlow',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AudioFile> audioFiles = [];
  bool isLoading = false;
  bool isError = false;

  Future<void> fetchAudioFiles() async {
    setState(() {
      isLoading = true;
    });

    List<AudioFile> updatedAudioFiles = [];

    try {
      Reference storageRef = FirebaseStorage.instance.ref().child("files");
      ListResult result = await storageRef.listAll();

      for (Reference item in result.items) {
        updatedAudioFiles.add(
          AudioFile(
            title: item.name,
            url: await item.getDownloadURL(),
          ),
        );
      }

      setState(() {
        audioFiles = updatedAudioFiles;
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print('Error fetching audio files from Firebase Storage: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAudioFiles();
  }

  Future<void> _onRefresh() async {
    await fetchAudioFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'BeatFlow',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const settingScreen()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Text(
                    'Error fetching audio files',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : audioFiles.isEmpty
                  ? Center(
                      child: Text(
                        'No audio files available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: audioFiles.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MusicPlayerScreen(song: audioFiles[index]),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.grey[900],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.music_note_outlined, size: 40, color: Colors.white),
                                    SizedBox(height: 8),
                                    Text(
                                      audioFiles[index].title.length > 20
                                          ? "${audioFiles[index].title.substring(0, 20)}..."
                                          : audioFiles[index].title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}
