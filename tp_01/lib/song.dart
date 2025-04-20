// import 'package:flutter/material.dart';


// class SongScreen extends StatelessWidget {
//   const SongScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[900],
//       appBar: AppBar(
//         title: const Text('Song'),
//         backgroundColor: Colors.blue[900],
//       ),
//       body: const Center(
//         child: Text('Song Page', style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart'; // Optional for better audio handling

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey),
        ),
      ),
      home: const NowPlayingScreen(),
    );
  }
}

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;
  final List<Song> _songs = [
    Song(
      title: 'Surah Alkawtar',
      artist: 'Meshari Al Afasi',
      image: 'assets/image.jpg',
      audio: 'assets/108.mp3',
    ),
    Song(
      title: 'Surah alfalaq',
      artist: 'Meshari Al Afasi',
      image: 'assets/image02.jpg',
      audio: 'assets/113.mp3',
    ),
    Song(
      title: 'Surah Annass',
      artist: 'ArMeshari Al Afasi',
      image: 'assets/image03.jpg',
      audio: 'assets/114.mp3',
    ),
  ];
  int _currentSongIndex = 0;
  bool _isPlaying = false;
  final Set<String> _favorites = {}; // Set to store favorite songs
  bool _isFavorite = false; // Track if the current song is favorited
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animationController.repeat(period: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();

    // Initialize audio player
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _loadSong(_songs[_currentSongIndex].audio);
      _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _loadSong(String audioPath) async {
    try {
      await _audioPlayer.setAsset(audioPath);
    } catch (e) {
      debugPrint('Error loading song: $e');
    }
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _playNext() {
    if (_currentSongIndex < _songs.length - 1) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }
    _loadSong(_songs[_currentSongIndex].audio);
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
      _isFavorite = _favorites.contains(_songs[_currentSongIndex].title);
    });
  }

  void _playPrevious() {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex = _songs.length - 1;
    }
    _loadSong(_songs[_currentSongIndex].audio);
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
      _isFavorite = _favorites.contains(_songs[_currentSongIndex].title);
    });
  }

  void _toggleFavorite() {
    setState(() {
      final currentSongTitle = _songs[_currentSongIndex].title;
      if (_isFavorite) {
        _favorites.remove(currentSongTitle); // Remove from favorites
      } else {
        _favorites.add(currentSongTitle); // Add to favorites
      }
      _isFavorite = !_isFavorite; // Toggle favorite status
    });
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  void dispose() {
    // Stop playback when the screen is disposed
    _audioPlayer.stop(); // Ensure the audio stops
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _songs[_currentSongIndex];
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        body: Row(
          children: [
            // Left Fragment: Song Details
            Visibility(
              visible: _showDetails,
              child: Expanded(
                flex: 2,
                child: Container(
                  color: Colors.blue[800],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details:',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Title: ${currentSong.title}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Artist: ${currentSong.artist}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Duration: ${_formatDuration(_audioPlayer.duration)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Right Fragment: Main Interface
            Expanded(
              flex: 3,
              child: _buildMainInterface(currentSong),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: _buildPortraitLayout(currentSong),
      );
    }
  }

  Widget _buildMainInterface(Song song) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top navigation icons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavIcon(
                        icon: Icons.favorite_border,
                        label: 'Favorites',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoritesScreen(
                                favorites: _favorites,
                                onRemoveFavorite: (String songTitle) {
                                  setState(() {
                                    _favorites.remove(songTitle);
                                    if (songTitle == _songs[_currentSongIndex].title) {
                                      _isFavorite = false;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _NavIcon(
                        icon: Icons.music_note,
                        label: 'Song',
                        onTap: () {},
                      ),
                      _NavIcon(
                        icon: Icons.queue_music,
                        label: 'All Songs',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Album art
                Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeIn,
                    ),
                    child: RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(song.image),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Song title and artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _toggleDetails,
                            child: Text(
                              '${song.title} | ${song.artist}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: _toggleFavorite,
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FavoritesScreen(
                                    favorites: _favorites,
                                    onRemoveFavorite: (String songTitle) {
                                      setState(() {
                                        _favorites.remove(songTitle);
                                        if (songTitle == _songs[_currentSongIndex].title) {
                                          _isFavorite = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: _playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _playPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(Song song) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top navigation icons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavIcon(
                        icon: Icons.favorite_border,
                        label: 'Favorites',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoritesScreen(
                                favorites: _favorites,
                                onRemoveFavorite: (String songTitle) {
                                  setState(() {
                                    _favorites.remove(songTitle);
                                    if (songTitle == _songs[_currentSongIndex].title) {
                                      _isFavorite = false;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _NavIcon(
                        icon: Icons.music_note,
                        label: 'Song',
                        onTap: () {},
                      ),
                      _NavIcon(
                        icon: Icons.queue_music,
                        label: 'All Songs',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Album art
                Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeIn,
                    ),
                    child: RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(song.image),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Song title and artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _toggleDetails,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${song.title} | ${song.artist}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleFavorite,
                              onLongPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritesScreen(
                                      favorites: _favorites,
                                      onRemoveFavorite: (String songTitle) {
                                        setState(() {
                                          _favorites.remove(songTitle);
                                          if (songTitle == _songs[_currentSongIndex].title) {
                                            _isFavorite = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Show song details if toggled
                      if (_showDetails) _buildSongDetails(song),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: _playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _playPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongDetails(Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Details:',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Title: ${song.title}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            'Artist: ${song.artist}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            'Duration: ${_formatDuration(_audioPlayer.duration)}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class Song {
  final String title;
  final String artist;
  final String image;
  final String audio;

  Song({
    required this.title,
    required this.artist,
    required this.image,
    required this.audio,
  });
}

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;
  final Function(String) onRemoveFavorite;

  const FavoritesScreen({
    required this.favorites,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final song = favorites.toList()[index];
          return ListTile(
            title: Text(
              song,
              style: const TextStyle(color: Colors.white),
            ),
            onLongPress: () {
              onRemoveFavorite(song); // Remove the song from favorites
            },
          );
        },
      ),
    );
  }
}