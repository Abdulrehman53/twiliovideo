import 'dart:async';

import 'package:flutter/material.dart';
import "dart:math" as math;

import 'package:provider/provider.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:twiliovideo/twilio_provider.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  @override
  void initState() {
    // TODO: implement initState
    print("onit");
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _onVideoEnabledStreamController.close();
    //_onAudioEnabledStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Video'),
        // ),
        body: ChangeNotifierProvider(
            create: (context) => TwillioProvider()..connectToRoom(),
            child: Consumer<TwillioProvider>(builder: (context, twilio, child) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: [
                          FutureBuilder(
                            future: twilio.completer.future,
                            builder: (context, AsyncSnapshot<Room> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                      "error occurred while establishing connection"),
                                );
                              }
                              if (snapshot.hasData) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 80),
                                  // height: 600,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(
                                        twilio.isFrontCamera ? math.pi : 0),
                                    child: twilio.localVideoTrack!
                                        .widget(mirror: false),
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                          Positioned(
                            bottom: 100,
                            right: 10,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: twilio.remoteParticipantWidget,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Container(
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await twilio.switchCamera();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      padding: const EdgeInsets.all(10),
                                    ),
                                    child: Icon(Icons.switch_camera),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      twilio.toggleAudioEnabled();
                                      // _localAudioTrack!.enable(!_isAudioMuted);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      padding: const EdgeInsets.all(10),
                                      primary: twilio.isAudioMuted
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    child: Icon(twilio.isAudioMuted
                                        ? Icons.mic_off
                                        : Icons.mic),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // if (_isVideoMuted) {
                                      twilio.toggleVideoEnabled();

                                      // await _localVideoTrack!.enable(
                                      //   !_localVideoTrack!.isEnabled,
                                      // );
                                      // _onVideoEnabledStreamController
                                      //     .add(_localVideoTrack!.isEnabled);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      padding: const EdgeInsets.all(10),
                                      primary: twilio.isVideoMuted
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    child: Icon(twilio.isVideoMuted
                                        ? Icons.videocam_off
                                        : Icons.videocam),
                                  ),
                                  ClipOval(
                                    child: Material(
                                      color: Colors.red, // Button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.grey, // Splash color
                                        onTap: () => twilio.onHangup,
                                        child: SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            })));
  }
  /* Widget _buildParticipants(BuildContext context, Size size, ConferenceRoom conferenceRoom) {
    final children = <Widget>[];
    final length = conferenceRoom.participants.length;

    if (length <= 2) {
      _buildOverlayLayout(context, size, children);
      return Stack(children: children);
    }

    void buildInCols(bool removeLocalBeforeChunking, bool moveLastOfEachRowToNextRow, int columns) {
      _buildLayoutInGrid(
        context,
        size,
        children,
        removeLocalBeforeChunking: removeLocalBeforeChunking,
        moveLastOfEachRowToNextRow: moveLastOfEachRowToNextRow,
        columns: columns,
      );
    }

    if (length <= 3) {
      buildInCols(true, false, 1);
    } else if (length == 5) {
      buildInCols(false, true, 2);
    } else if (length <= 6 || length == 8) {
      buildInCols(false, false, 2);
    } else if (length == 7 || length == 9) {
      buildInCols(true, false, 2);
    } else if (length == 10) {
      buildInCols(false, true, 3);
    } else if (length == 13 || length == 16) {
      buildInCols(true, false, 3);
    } else if (length <= 18) {
      buildInCols(false, false, 3);
    }

    return Column(
      children: children,
    );
  }
 */
  /*  void _buildOverlayLayout(BuildContext context, Size size, List<Widget> children) {
    final conferenceRoom = _conferenceRoom;
    if (conferenceRoom == null) return;

    final participants = conferenceRoom.participants;
    if (participants.length == 1) {
      children.add(_buildNoiseBox());
    } else {
      final remoteParticipant = participants.firstWhereOrNull((ParticipantWidget participant) => participant.isRemote);
      if (remoteParticipant != null) {
        children.add(remoteParticipant);
      }
    }
 */
  /*   final localParticipant = participants.firstWhereOrNull((ParticipantWidget participant) => !participant.isRemote);
    if (localParticipant != null) {
      children.add(DraggablePublisher(
        key: Key('publisher'),
        availableScreenSize: size,
        onButtonBarVisible: _onButtonBarVisibleStreamController.stream,
        onButtonBarHeight: _onButtonBarHeightStreamController.stream,
        child: localParticipant,
      ));
    } */
}

  /* void _buildLayoutInGrid(
    BuildContext context,
    Size size,
    List<Widget> children, {
    bool removeLocalBeforeChunking = false,
    bool moveLastOfEachRowToNextRow = false,
    int columns = 2,
  }) {
    final conferenceRoom = _conferenceRoom;
    if (conferenceRoom == null) return;

    final participants = conferenceRoom.participants;
    ParticipantWidget? localParticipant;
    if (removeLocalBeforeChunking) {
      localParticipant = participants.firstWhereOrNull((ParticipantWidget participant) => !participant.isRemote);
      if (localParticipant != null) {
        participants.remove(localParticipant);
      }
    }
    final chunkedParticipants = chunk(array: participants, size: columns);
    if (localParticipant != null) {
      chunkedParticipants.last.add(localParticipant);
      participants.add(localParticipant);
    }

    if (moveLastOfEachRowToNextRow) {
      for (var i = 0; i < chunkedParticipants.length - 1; i++) {
        var participant = chunkedParticipants[i].removeLast();
        chunkedParticipants[i + 1].insert(0, participant);
      }
    }

    for (final participantChunk in chunkedParticipants) {
      final rowChildren = <Widget>[];
      for (final participant in participantChunk) {
        rowChildren.add(
          Container(
            width: size.width / participantChunk.length,
            height: size.height / chunkedParticipants.length,
            child: participant,
          ),
        );
      }
      children.add(
        Container(
          height: size.height / chunkedParticipants.length,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowChildren,
          ),
        ),
      );
    }
  }

  NoiseBox _buildNoiseBox() {
    return NoiseBox(
      density: NoiseBoxDensity.xLow,
      backgroundColor: Colors.grey.shade900,
      child: Center(
        child: Container(
          color: Colors.black54,
          width: double.infinity,
          height: 40,
          child: Center(
            child: Text(
              'Waiting for another participant to connect to the room...',
              key: Key('text-wait'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  List<List<T>> chunk<T>({required List<T> array, required int size}) {
    final result = <List<T>>[];
    if (array.isEmpty || size <= 0) {
      return result;
    }
    var first = 0;
    var last = size;
    final totalLoop = array.length % size == 0 ? array.length ~/ size : array.length ~/ size + 1;
    for (var i = 0; i < totalLoop; i++) {
      if (last > array.length) {
        result.add(array.sublist(first, array.length));
      } else {
        result.add(array.sublist(first, last));
      }
      first = last;
      last = last + size;
    }
    return result;
  } */

//}
