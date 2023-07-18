import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:zenify/Animations/fade_animation.dart';
import 'package:zenify/components/player_buttons.dart';

import 'package:zenify/components/seekbar.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/navigation_state.dart';
import 'package:zenify/redux/states/song_state.dart';
import 'package:zenify/utils/database.dart';
import '../models/song_model.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final _zenifyData = Hive.box('zenifyData');
  ZenifyDatabase db = ZenifyDatabase();

  static final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  AudioPlayer audioPlayer = AudioPlayer();

  dynamic song = Song.songs[0];

  @override
  void initState() {
    if (_zenifyData.get('musicList') == null) {
      db.fetchMusicList();
    } else {
      db.loadMusicList();
    }

    if (_zenifyData.get("currentSongIndex") == null) {
      db.saveCurrentSongIndex();
    } else {
      db.getCurrentSongIndex();
    }

    if (_zenifyData.get("musicList") == null || db.musicList.isEmpty) {
      var uri = 'asset:///${song.url}';
      audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: [
            AudioSource.uri(
              Uri.parse(uri),
            ),
          ],
        ),
      );
    } else {
      song = db.musicList[db.currentSongIndex < 0
          ? 0
          : db.currentSongIndex > db.musicList.length - 1
              ? db.musicList.length - 1
              : db.currentSongIndex];
      audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: [
            AudioSource.uri(
              Uri.parse(song["uri"].toString()),
            ),
          ],
        ),
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<SeekBarData> get _seekBarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekBarData>(
        audioPlayer.positionStream,
        audioPlayer.durationStream,
        (
          Duration position,
          Duration? duration,
        ) {
          return SeekBarData(
            position,
            duration ?? Duration.zero,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: StoreConnector<NavigationState, int>(
          converter: (store) => store.state.tabIndex,
          builder: (context, int stateNavigationIndex) => Container(
            margin: const EdgeInsets.only(top: 20, left: 20),
            padding: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: HexColor("#e8e8e8").withOpacity(0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                  weight: 900,
                ),
                onPressed: () {
                  StoreProvider.of<NavigationState>(context).dispatch(
                    UpdateNavigationIndexAction(1),
                  );
                },
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: LiquidPullToRefresh(
        key: _refreshIndicatorKey,
        springAnimationDurationInMilliseconds: 300,
        height: 150,
        color: Colors.transparent,
        backgroundColor: HexColor("#102844"),
        borderWidth: 0,
        onRefresh: () async {
          db.getTasks();
          setState(() {});
          await Future.delayed(const Duration(seconds: 2));
          _refreshIndicatorKey.currentState?.show();
        },
        showChildOpacityTransition: true,
        child: FadeAnimation(
          1,
          -10,
          Stack(
            fit: StackFit.expand,
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, HexColor("#102844")],
                    tileMode: TileMode.mirror,
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.srcOver,
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor("#102844"),
                    image: const DecorationImage(
                        image: AssetImage("assets/Backgrounds/dark-bg.jpg"),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              StoreConnector<SongState, int>(
                  converter: (store) => store.state.currentSongIndex,
                  builder: (context, int currentSongIndex) {
                    if (db.musicList.isNotEmpty &&
                        db.musicList.length > currentSongIndex) {
                      audioPlayer.setAudioSource(
                        ConcatenatingAudioSource(
                          children: [
                            AudioSource.uri(
                              Uri.parse(db.musicList[currentSongIndex]["uri"]
                                  .toString()),
                            ),
                          ],
                        ),
                      );
                    }
                    return FadeAnimation(
                      2.5,
                      0,
                      _MusicPlayer(
                        song: db.musicList.isNotEmpty &&
                                db.musicList.length > currentSongIndex
                            ? db.musicList[currentSongIndex]
                            : song,
                        seekBarDataStream: _seekBarDataStream,
                        audioPlayer: audioPlayer,
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicPlayer extends StatelessWidget {
  const _MusicPlayer({
    Key? key,
    required this.song,
    required Stream<SeekBarData> seekBarDataStream,
    required this.audioPlayer,
  })  : _seekBarDataStream = seekBarDataStream,
        super(key: key);

  final dynamic song;
  final Stream<SeekBarData> _seekBarDataStream;
  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    audioPlayer.play();
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        StoreProvider.of<SongState>(context).dispatch(
          UpdateCurrentSongIndexAction(
            StoreProvider.of<SongState>(context).state.currentSongIndex + 1,
          ),
        );
        audioPlayer.play();
      }
    });
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 50.0,
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.width >
                  MediaQuery.of(context).size.height
              ? MediaQuery.of(context).size.height
              : MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                    )
                  : const SizedBox(),
              Text(
                song.runtimeType.toString() == "Song"
                    ? song.title
                    : song["title"],
                style: GoogleFonts.comfortaa(
                  textStyle: TextStyle(
                      color: HexColor("#e8e8e8").withOpacity(1),
                      fontSize: 25,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                song.runtimeType.toString() == "Song"
                    ? song.artist
                    : song["artist"] ?? "Unknown Artist",
                maxLines: 2,
                style: GoogleFonts.comfortaa(
                  textStyle: TextStyle(
                      color: HexColor("#e8e8e8").withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 30),
              StreamBuilder<SeekBarData>(
                stream: _seekBarDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    position: positionData?.position ?? Duration.zero,
                    duration: positionData?.duration ?? Duration.zero,
                    onChangeEnd: audioPlayer.seek,
                  );
                },
              ),
              PlayerButtons(audioPlayer: audioPlayer),
            ],
          ),
        ),
      ),
    );
  }
}
