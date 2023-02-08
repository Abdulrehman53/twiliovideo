import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:twiliovideo/twilioservice.dart';
import 'package:uuid/uuid.dart';

class TwillioProvider extends ChangeNotifier {
  bool isFrontCamera = true;
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  final Completer<Room> completer = Completer<Room>();
  Room? _room;
  CameraCapturer? _capturer;
  LocalVideoTrack? localVideoTrack;
  LocalAudioTrack? localAudioTrack;
  TwilioFunctionsService tfs = TwilioFunctionsService();
  Widget? remoteParticipantWidget;
  String? trackId;

  final StreamController<bool> _onAudioEnabledStreamController =
      StreamController<bool>.broadcast();
  late Stream<bool> onAudioEnabled;
  final StreamController<bool> _onVideoEnabledStreamController =
      StreamController<bool>.broadcast();
  late Stream<bool> onVideoEnabled;
  Future<void> switchCamera() async {
    print('ConferenceRoom.switchCamera()');
    if (_capturer != null) {
      final sources = await CameraSource.getSources();
      final source = sources.firstWhere((source) {
        if (_capturer!.source!.isFrontFacing) {
          return source.isBackFacing;
        }
        return source.isFrontFacing;
      });

      await _capturer!.switchCamera(source);
      isFrontCamera =!isFrontCamera;
      notifyListeners();
    }
  }

  Future<void> toggleVideoEnabled() async {
    final tracks = _room!.localParticipant?.localVideoTracks ?? [];
    final localVideoTrack = tracks.isEmpty ? null : tracks[0].localVideoTrack;
    if (localVideoTrack == null) {
      print(
          'ConferenceRoom.toggleVideoEnabled() => Track is not available yet!');
      return;
    }
    await localVideoTrack.enable(!localVideoTrack.isEnabled);
    _onVideoEnabledStreamController.add(localVideoTrack.isEnabled);
    isVideoMuted = !isVideoMuted;
    notifyListeners();
  }

  Future<void> toggleAudioEnabled() async {
    final tracks = _room!.localParticipant?.localAudioTracks ?? [];
    final localAudioTrack = tracks.isEmpty ? null : tracks[0].localAudioTrack;
    if (localAudioTrack == null) {
      print(
          'ConferenceRoom.toggleAudioEnabled() => Track is not available yet!');
      return;
    }
    await localAudioTrack.enable(!localAudioTrack.isEnabled);
    isAudioMuted = !isAudioMuted;
    notifyListeners();

    print(
        'ConferenceRoom.toggleAudioEnabled() => ${localAudioTrack.isEnabled}');
    _onAudioEnabledStreamController.add(localAudioTrack.isEnabled);
  }

  Future<Room?> connectToRoom() async {
    if (localVideoTrack == null && localVideoTrack == null) {
      try {
        EasyLoading.show(status: 'loading...');
        print("connect me to a room");
        final sources = await CameraSource.getSources();

        _capturer = CameraCapturer(
          sources.firstWhere((source) => source.isFrontFacing),
        );
        localVideoTrack = LocalVideoTrack(true, _capturer!);
        // var widget = localVideoTrack.widget();

        print(_capturer);
        trackId = const Uuid().v4();
        print(trackId);
        String accessKey = await tfs.createToken("test3");
        print(accessKey);
        var connectOptions = ConnectOptions(
          accessKey,
          roomName: "bo0tman",
          preferredAudioCodecs: [OpusCodec()],
          audioTracks: [LocalAudioTrack(true, 'audio_track-$trackId')],
          dataTracks: [
            LocalDataTrack(
              DataTrackOptions(name: 'data_track-$trackId'),
            )
          ],
          videoTracks: [LocalVideoTrack(true, _capturer!)],
          enableNetworkQuality: true,
          networkQualityConfiguration: NetworkQualityConfiguration(
            remote: NetworkQualityVerbosity.NETWORK_QUALITY_VERBOSITY_MINIMAL,
          ),
          enableDominantSpeaker: true,
        );
        print(connectOptions);
        _room = await TwilioProgrammableVideo.connect(connectOptions);
        print(_room);
        _room?.onConnected.listen(_onConnected);
        _room?.onConnectFailure.listen(_onConnectFailure);
        _room?.onParticipantConnected.listen(_onParticipantConnected);
        EasyLoading.dismiss();
      } catch (e) {
        print("we got error: ");
        print(e);
      }
    }

    return completer.future;
  }

  _onConnected(Room? room) {
    print("Connected to ${room?.name}");
    if (room != null) {
      if (room.remoteParticipants.isNotEmpty) {
        room.remoteParticipants.first.onVideoTrackSubscribed
            .listen(_remoteVideoTrack);
      }
      completer.complete(room);
    }
  }

  _remoteVideoTrack(RemoteVideoTrackSubscriptionEvent evt) {
    remoteParticipantWidget = evt.remoteVideoTrack.widget();
    notifyListeners();
  }

  _onConnectFailure(RoomConnectFailureEvent event) {
    print("Failed to connect to room ${event.room.name} ");
    print(event.exception.toString());
    completer.completeError(event.exception.toString());
  }

  _onParticipantConnected(RoomParticipantConnectedEvent roomEvent) {
    print("remote particiant has connected to the room");
    roomEvent.remoteParticipant.onVideoTrackSubscribed
        .listen(_remoteVideoTrack);
  }

  Future<void> onHangup(BuildContext context) async {
    print('onHangup');
    // await disconnect();
    print('ConferenceRoom.disconnect()');
    // await TwilioProgrammableVideo.disableAudioSettings();
    if (_room != null) await _room!.disconnect();
    Navigator.of(context).pop();
  }
}
