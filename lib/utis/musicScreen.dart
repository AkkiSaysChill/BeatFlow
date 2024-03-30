import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:beatflow/screens/homescreen.dart';
import 'package:beatflow/utis/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class MusicPlayerScreen extends StatefulWidget {
  final AudioFile song;

  const MusicPlayerScreen({Key? key, required this.song}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool isPlaying = true;
  Duration currentPosition = const Duration();
  Duration totalDuration = Duration.zero; // Initialize with placeholder
  final player = AudioPlayer();
  Uint8List? albumArt;

  @override
  void initState() {

    super.initState();

    if (isPlaying) {
      playMusic();
    }

    // Track audio position changes
    player.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    // Track player state changes
    player.onPositionChanged.listen((Duration duration) {
      setState(() {
        currentPosition = duration;
      });
    });

    player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          currentPosition = const Duration(seconds: 0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    @override
  void initState() {
    super.initState();
    playMusic(); // Call playMusic() function when screen is first initialized
  }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Now Playing",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                hexStringToColor("353935"),
                hexStringToColor("1B1212"),
                hexStringToColor("1B1212"),
                hexStringToColor("1B1212"),
                hexStringToColor("1B1212"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 149, 100, 100), // Placeholder color
                  borderRadius: BorderRadius.circular(12),
                  image: albumArt != null
                    ? DecorationImage(
                        image: MemoryImage(albumArt!),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: albumArt != null
                  ? null
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 48, // Adjust the size as needed
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Album art not available',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                      widget.song.title.length > 20 ? "${widget.song.title.substring(0, 20)}..." : widget.song.title,
                      textAlign: TextAlign.center, // Align text to the center
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            buildProgressIndicator(),
            const SizedBox(height: 20),
            MusicControls(
              isPlaying: isPlaying,
              onPlayPause: () {
                setState(() {
                  isPlaying = !isPlaying;
                  if (isPlaying) {
                    print("playing");
                    playMusic();
                  } else {
                    print("Staap");
                    stopMusic();
                  }
                });
              },
              
              onSkipPrevious: () {
                print("huehue");
              },
              onSkipNext: () {
                print("Ulta huehue");
              },
            ),
          ],
        ),
      ),
      
    );
    
  }

  Widget buildProgressIndicator() {
    
    if (totalDuration == Duration.zero) {
      return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10), // Adjust the spacing as needed
        Text(
          'Getting data from our server',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
      
    } else {
      return Slider(
        thumbColor: Colors.white,
        activeColor: Colors.white,
        inactiveColor: const Color.fromARGB(255, 0, 0, 0),
        value: currentPosition.inSeconds.toDouble(),
        min: 0.0,
        max: totalDuration.inSeconds.toDouble(),
        onChanged: (double value) {
          player.seek(Duration(seconds: value.toInt()));
        },
      );
    }
  }

  Future<void> playMusic() async {
    try {
      final hehe = widget.song.title;
      
      Reference storageReference = FirebaseStorage.instance.ref().child("files/$hehe");
      // Obtain the download URL
      final String downloadUrl = await storageReference.getDownloadURL();
      final metadata = await MetadataRetriever.fromFile(File(downloadUrl));
      albumArt = metadata.albumArt;

      print(metadata);
      print(albumArt);

      if (isPlaying) {
        // If not playing, start playing
        await player.play(UrlSource(downloadUrl));
        setState(() {
          isPlaying = true;
        });
        print("Playing");
      }

      print("Firebase Storage URL: $downloadUrl");
    } catch (e) {
      print("Error playing/pausing music: $e");
    }
  }

  void stopMusic() async {
    await player.pause(); // Stop the playback
    setState(() {
      isPlaying = false;
    });
    print("Stopped");
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}

class MusicControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;

  const MusicControls({
    Key? key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: onSkipPrevious,
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: onPlayPause,
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: onSkipNext,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
