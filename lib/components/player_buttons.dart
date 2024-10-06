import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zenify/redux/actions.dart';
import 'package:zenify/redux/states/song_state.dart';
import 'package:zenify/utils/database.dart';

class PlayerButtons extends StatelessWidget {
  final AudioPlayer audioPlayer;

  PlayerButtons({
    super.key,
    required this.audioPlayer,
  });

  final ZenifyDatabase db = ZenifyDatabase();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<SongState, int>(
        converter: (store) => store.state.currentSongIndex,
        builder: (context, int currentSongIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<SequenceState?>(
                stream: audioPlayer.sequenceStateStream,
                builder: (context, index) {
                  return IconButton(
                    onPressed: () {
                      if (audioPlayer.hasPrevious) audioPlayer.seekToPrevious();
                      StoreProvider.of<SongState>(context).dispatch(
                        UpdateCurrentSongIndexAction(
                          StoreProvider.of<SongState>(context)
                                  .state
                                  .currentSongIndex -
                              1,
                        ),
                      );
                      db.updateCurrentSongIndexFromValue(currentSongIndex);
                      audioPlayer.play();
                    },
                    iconSize: 45,
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final playerState = snapshot.data;
                    final processingState = playerState!.processingState;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        width: 64.0,
                        height: 64.0,
                        margin: const EdgeInsets.all(10.0),
                        child: const CircularProgressIndicator(),
                      );
                    } else if (!audioPlayer.playing) {
                      return IconButton(
                        onPressed:
                            (!audioPlayer.playing) ? audioPlayer.play : null,
                        iconSize: 75,
                        icon: const Icon(
                          Icons.play_circle,
                          color: Colors.white,
                        ),
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(
                          Icons.pause_circle,
                          color: Colors.white,
                        ),
                        iconSize: 75.0,
                        onPressed:
                            (audioPlayer.playing) ? audioPlayer.pause : null,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(
                          Icons.replay_circle_filled_outlined,
                          color: Colors.white,
                        ),
                        iconSize: 75.0,
                        onPressed: () => audioPlayer.seek(
                          Duration.zero,
                          index: audioPlayer.effectiveIndices!.first,
                        ),
                      );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: audioPlayer.sequenceStateStream,
                builder: (context, index) {
                  return IconButton(
                    onPressed: () {
                      if (audioPlayer.hasNext) {
                        audioPlayer.seekToNext();
                      }
                      StoreProvider.of<SongState>(context).dispatch(
                        UpdateCurrentSongIndexAction(
                          StoreProvider.of<SongState>(context)
                                  .state
                                  .currentSongIndex +
                              1,
                        ),
                      );
                      db.updateCurrentSongIndexFromValue(currentSongIndex);
                      audioPlayer.play();
                    },
                    iconSize: 45,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          );
        });
  }
}
