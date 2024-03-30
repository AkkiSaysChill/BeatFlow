import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audioplayers/audioplayers.dart';

class AddSongFromYouTubeMusicScreen extends StatefulWidget {
  const AddSongFromYouTubeMusicScreen({Key? key}) : super(key: key);

  @override
  _AddSongFromYouTubeMusicScreenState createState() =>
      _AddSongFromYouTubeMusicScreenState();
}

class _AddSongFromYouTubeMusicScreenState
    extends State<AddSongFromYouTubeMusicScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YoutubeExplode _ytExplode = YoutubeExplode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Video> _searchResults = [];
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        _isPlaying = s == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ytExplode.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _searchSongs(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _searchResults = await _ytExplode.search.getVideos(query);
      _searchResults.retainWhere((video) =>
          video.title.toLowerCase().contains('music') ||
          video.description.toLowerCase().contains('music') ||
          video.title.toLowerCase().contains('song') ||
          video.title.toLowerCase().contains('tseries') ||
          video.description.toLowerCase().contains('composer') ||
          video.description.toLowerCase().contains('artist'));
    } catch (e) {
      print('Error searching for songs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playMusic(String videoUrl) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Fetching Audio Stream'),
              Text("this can take a while :)")
            ],
          ),
        );
      },
    );

    try {
      var videoId = _extractVideoId(videoUrl);
      var manifest =
          await _ytExplode.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.first;
      var directAudioUrl = audioStreamInfo.url.toString();
      await _audioPlayer.play(UrlSource(directAudioUrl));
    } catch (e) {
      print('Error playing music: $e');
    } finally {
      Navigator.of(context).pop();
    }
  }

  String _extractVideoId(String videoUrl) {
    var regExp = RegExp(
        r"(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([^&?\/\s\"'>]+)');
    var match = regExp.firstMatch(videoUrl);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      throw Exception('Invalid YouTube video URL');
    }
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 28, 28),
        title: const Text(
          'Search on YouTube Music',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 32, 28, 28),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for a song',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      onPressed: () {
                        _searchSongs(_searchController.text);
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          var video = _searchResults[index];
                          return ListTile(
                            title: Text(video.title),
                            textColor: Colors.white,
                            onTap: () {
                              try {
                                _playMusic(video.url);
                              } catch (e) {
                                print('Error playing music: $e');
                              }
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              color: const Color.fromARGB(255, 32, 28, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    onPressed: _playPause,
                  ),
                  Text(
                    '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
