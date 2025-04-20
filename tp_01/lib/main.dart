import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

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

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  final Set<String> _favorites = {};
  bool _isFavorite = false;
  bool _showDetails = false;
  Duration? _currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animationController.repeat(period: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Save current position before pausing
      _currentPosition = _audioPlayer.position;
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      // Resume from saved position if available
      if (_currentPosition != null) {
        await _audioPlayer.seek(_currentPosition!);
      }
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _initAudioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadSong(_songs[_currentSongIndex].audio);
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _loadSong(String audioPath) async {
    try {
      await _audioPlayer.setAsset(audioPath);
      if (_currentPosition != null) {
        await _audioPlayer.seek(_currentPosition);
      }
    } catch (e) {
      debugPrint('Error loading song: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading audio')),
      );
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

  void _playNext() async {
    if (_currentSongIndex < _songs.length - 1) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }
    _currentPosition = null;
    await _loadSong(_songs[_currentSongIndex].audio);
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
      _checkIfFavorite();
    });
  }

  void _playPrevious() async {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex = _songs.length - 1;
    }
    _currentPosition = null;
    await _loadSong(_songs[_currentSongIndex].audio);
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
      _checkIfFavorite();
    });
  }

  void _toggleFavorite() {
    setState(() {
      final currentSongTitle = _songs[_currentSongIndex].title;
      if (_isFavorite) {
        _favorites.remove(currentSongTitle);
      } else {
        _favorites.add(currentSongTitle);
      }
      _isFavorite = !_isFavorite;
    });
  }

  void _checkIfFavorite() {
    setState(() {
      _isFavorite = _favorites.contains(_songs[_currentSongIndex].title);
    });
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _songs[_currentSongIndex];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: isLandscape
          ? _buildLandscapeLayout(currentSong)
          : _buildPortraitLayout(currentSong),
    );
  }

  Widget _buildLandscapeLayout(Song song) {
    return Row(
      children: [
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
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildMainInterface(song),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(Song song) {
    return _buildMainInterface(song);
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
                                songs: _songs,
                                onRemoveFavorite: (String songTitle) {
                                  setState(() {
                                    _favorites.remove(songTitle);
                                    if (songTitle ==
                                        _songs[_currentSongIndex].title) {
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
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleFavorite,
                              onLongPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritesScreen(
                                      favorites: _favorites,
                                      songs: _songs,
                                      onRemoveFavorite: (String songTitle) {
                                        setState(() {
                                          _favorites.remove(songTitle);
                                          if (songTitle ==
                                              _songs[_currentSongIndex].title) {
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
                      if (_showDetails) _buildSongDetails(song),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
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

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;
  final List<Song> songs;
  final Function(String) onRemoveFavorite;

  const FavoritesScreen({
    required this.favorites,
    required this.songs,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteSongs =
        songs.where((song) => favorites.contains(song.title)).toList();

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
