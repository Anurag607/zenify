class Song {
  final String title;
  final String artist;
  final String url;
  final String coverUrl;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.coverUrl,
  });

  static List<Song> songs = [
    Song(
      title: 'Glass',
      artist: 'Glass',
      url: 'assets/Music/glass.mp3',
      coverUrl: 'assets/Music/glass.jpg',
    ),
    Song(
      title: 'Illusions',
      artist: 'Illusions',
      url: 'assets/Music/illusions.mp3',
      coverUrl: 'assets/Music/illusions.jpg',
    ),
    Song(
      title: 'Pray',
      artist: 'Pray',
      url: 'assets/Music/pray.mp3',
      coverUrl: 'assets/Music/pray.jpg',
    )
  ];
}
