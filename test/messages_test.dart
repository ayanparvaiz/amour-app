import 'package:amour_app/app/core/localization/app_translations.dart';
import 'package:amour_app/app/data/models/message_model.dart';
import 'package:amour_app/app/modules/chat/chat_view.dart';
import 'package:amour_app/app/modules/messages/messages_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: AppTranslations.french,
      fallbackLocale: AppTranslations.french,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

void main() {
  group('models', () {
    test('a message knows whose it is', () {
      const message = MessageModel(
        id: 'm1',
        senderId: 'me',
        receiverId: 'them',
        text: 'Bonjour',
      );
      expect(message.isMine('me'), isTrue);
      expect(message.isMine('them'), isFalse);
    });

    test('reads the id under either key the server uses', () {
      // The REST response carries _id; the socket copy is re-encoded by us.
      expect(MessageModel.fromJson({'_id': 'a', 'text': 'x'}).id, 'a');
      expect(MessageModel.fromJson({'id': 'b', 'text': 'x'}).id, 'b');
    });

    test('a chat row falls back to a question mark for a blank name', () {
      expect(const ChatModel(userId: 'u', userName: '  ').initial, '?');
      expect(const ChatModel(userId: 'u', userName: 'Léa').initial, 'L');
    });

    test('copyWith moves the preview without losing the person', () {
      const chat = ChatModel(
        userId: 'u',
        userName: 'Léa',
        userPhoto: 'data:x',
        userLocation: 'Lyon',
      );
      final updated = chat.copyWith(lastMessage: 'Salut');

      expect(updated.lastMessage, 'Salut');
      expect(updated.userName, 'Léa');
      expect(updated.userPhoto, 'data:x');
      expect(updated.userLocation, 'Lyon');
    });
  });

  group('timestamps', () {
    final now = DateTime(2026, 9, 14, 15, 30);

    test('today shows the clock', () {
      expect(formatChatTime(DateTime(2026, 9, 14, 9, 5), now: now), '09:05');
    });

    test('earlier this week shows the weekday', () {
      // 10 September 2026 is a Thursday.
      expect(formatChatTime(DateTime(2026, 9, 10, 9, 5), now: now), 'jeu.');
    });

    test('older than a week shows the date', () {
      expect(formatChatTime(DateTime(2026, 8, 30, 9, 5), now: now), '30/08');
    });

    test('the day divider spells out an older date in full', () {
      expect(formatMessageDay(DateTime(2026, 8, 30), now: now), '30/08/2026');
    });

    // "Hier" and "Aujourd'hui" come from the dictionary, which is only loaded
    // once GetMaterialApp is built — so those two branches are checked in the
    // widget test below rather than here.
  });

  group('bubbles', () {
    const mine = MessageModel(
      id: 'm1',
      senderId: 'me',
      receiverId: 'them',
      text: 'Bonjour, comment allez-vous ?',
    );

    testWidgets('a pending message says so instead of showing a time',
        (tester) async {
      const pending = MessageModel(
        id: 'p1',
        senderId: 'me',
        receiverId: 'them',
        text: 'En route',
        pending: true,
      );

      await _pump(tester, const MessageBubble(message: pending, mine: true));

      expect(find.text('Envoi...'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long message wraps instead of overflowing', (tester) async {
      const long = MessageModel(
        id: 'm2',
        senderId: 'them',
        receiverId: 'me',
        text: 'Bonjour ! Je voulais vous dire que votre profil est vraiment '
            'très intéressant et que j\'aimerais beaucoup en savoir plus sur '
            'vos voyages et vos passions.',
      );

      await _pump(
        tester,
        const SingleChildScrollView(
          child: MessageBubble(message: long, mine: false),
        ),
        size: const Size(320, 844),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a day divider only when asked', (tester) async {
      await _pump(tester, const MessageBubble(message: mine, mine: true));
      expect(find.text("Aujourd'hui"), findsNothing);

      await _pump(
        tester,
        const MessageBubble(
            message: mine, mine: true, daySeparator: "Aujourd'hui"),
      );
      expect(find.text("Aujourd'hui"), findsOneWidget);
    });
  });

  group('conversation row', () {
    testWidgets('marks who is online', (tester) async {
      const chat = ChatModel(
        userId: 'u',
        userName: 'Marie-Christine Delacroix',
        lastMessage: 'À bientôt !',
      );

      await _pump(tester, const ChatRow(chat: chat, online: true));

      expect(find.text('Marie-Christine Delacroix'), findsOneWidget);
      expect(find.text('À bientôt !'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('says "Hier" for a message from yesterday', (tester) async {
      final chat = ChatModel(
        userId: 'u',
        userName: 'Léa',
        lastMessage: 'Bonne nuit',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      );

      await _pump(tester, ChatRow(chat: chat, online: false));
      expect(find.text('Hier'), findsOneWidget);
    });

    testWidgets('a long name and message fit a narrow screen', (tester) async {
      const chat = ChatModel(
        userId: 'u',
        userName: 'Marie-Christine Delacroix-Beaumont',
        lastMessage: 'Bonjour, je voulais vous dire que votre profil est '
            'vraiment très intéressant.',
      );

      await _pump(tester, const ChatRow(chat: chat, online: false),
          size: const Size(320, 844));

      expect(tester.takeException(), isNull);
    });
  });
}
