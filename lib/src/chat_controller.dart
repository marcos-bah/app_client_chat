import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:rx_notifier/rx_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatController {
  Socket socket;
  final String room;
  final String name;
  final listEvents = RxList<SocketEvent>([]);
  final textController = TextEditingController(text: '');
  final focusNode = FocusNode();
  final scrollController = ScrollController();

  ChatController(this.room, this.name) {
    _init();
  }

  void _init() {
    socket = io(
      API_URL,
      OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.connect();

    socket.onConnect(
      (_) {
        socket.emit(
          'enter_room',
          {
            'room': room,
            'name': name,
          },
        );
      },
    );

    socket.on('message', (json) {
      final event = SocketEvent.fromJson(json);
      listEvents.add(event);
    });
  }

  void send() {
    final event = SocketEvent(
      name: name,
      room: room,
      text: textController.text,
      type: SocketEventType.message,
    );
    listEvents.add(event);
    socket.emit('message', event.toJson());
    textController.clear();
    focusNode.requestFocus();
    scrollController.animateTo(scrollController.position.maxScrollExtent * 2,
        duration: const Duration(milliseconds: 2500), curve: Curves.easeOut);
  }

  void dispose() {
    socket.clearListeners();
    socket.dispose();
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
  }
}
