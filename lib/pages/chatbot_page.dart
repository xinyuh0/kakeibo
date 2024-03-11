import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kkb/widgets/text_area.dart';
import 'package:kkb/model/statistic.dart';
import 'package:kkb/widgets/chat_bubble.dart';
import 'package:kkb/model/spending_record.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/services/chat_helper.dart';

// Predefined recommeded questions
final List<ChatHistoryData> recommendations = [
  ChatHistoryData(
    chatId: 0,
    content:
        'I want to adjust my current budget list, please give me a recommended budget list',
    displayContent: 'Give a recommended budget list',
    fromUser: true,
  ),
  ChatHistoryData(
    chatId: 0,
    content: 'How to improve my spendings based on my current spendings',
    displayContent: 'How to improve my spendings',
    fromUser: true,
  ),
];

final ChatHistoryData greeting = ChatHistoryData(
  chatId: 0,
  content:
      'Hi there, I\'m your Bugdet Assistant! 🤖 Ask me about your spendings, or get smart budgeting tips. Let\'s chat about your finances!',
  fromUser: false,
);

class PositionWrapper extends StatelessWidget {
  final Widget child;
  final bool fromUser;

  const PositionWrapper({
    super.key,
    required this.child,
    required this.fromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 320.0),
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ),
          child: child,
        ),
      ],
    );
  }
}

class ChatBotPage extends StatefulWidget {
  final List<Budget> budgets;
  final List<SpendingRecord> records;

  const ChatBotPage({
    super.key,
    required this.budgets,
    required this.records,
  });

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

// For easier implementation, the chat history won't be added to the database, it would be stored in page state.
// Therefore, the past conversation can not be restored.
class _ChatBotPageState extends State<ChatBotPage> {
  int chatId = 0;
  List<ChatHistoryData> chatHistoryData = [];

  // Animation control for rendering recommendations
  int numOfRecommendationDisplayed = 0;
  late Timer _timer;

  // Animation control for sending new msg
  final _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (numOfRecommendationDisplayed < recommendations.length) {
        setState(() {
          numOfRecommendationDisplayed++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _chat(ChatHistoryData data) async {
    setState(() {
      isLoading = true;
      chatHistoryData.add(data);
    });

    // Scroll in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    String res = await ChatHelper.chat(
      chatId,
      data.content,
      chatHistoryData,
      widget.budgets,
      widget.records,
    );

    final ChatHistoryData newRes = ChatHistoryData(
      chatId: chatId,
      fromUser: false,
      content: res,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
        chatHistoryData.add(newRes);
      });
    }
  }

  void handleConfirm(String msg) {
    // When the last request is pending, the send button of text area is disabled.
    // No need to judge if it is loading here.
    final ChatHistoryData newData = ChatHistoryData(
      chatId: chatId,
      fromUser: true,
      content: msg,
    );

    _chat(newData);
  }

  void handleClickRecommendation(ChatHistoryData data) {
    // Judge if it is loading.
    if (isLoading) {
      return;
    }

    final ChatHistoryData newData = ChatHistoryData(
      chatId: chatId,
      fromUser: true,
      content: data.content,
      displayContent: data.displayContent,
      show: true,
    );

    _chat(newData);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('✨Budget Assistant✨'),
      ),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverSafeArea(
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      // Render predefined content
                      // Greeting
                      PositionWrapper(
                        fromUser: greeting.fromUser,
                        child: ChatBubble(data: greeting),
                      ),
                      // Predefined recommendations
                      for (ChatHistoryData data in recommendations.sublist(
                          0, numOfRecommendationDisplayed))
                        PositionWrapper(
                          fromUser: data.fromUser,
                          child: AnimatedBubbleWrapper(
                            child: RecommendQuestionBubble(
                              data: data,
                              onTap: handleClickRecommendation,
                            ),
                          ),
                        ),
                      // Chat body
                      for (ChatHistoryData data in chatHistoryData
                          .where((element) => element.show)
                          .toList())
                        PositionWrapper(
                          fromUser: data.fromUser,
                          child: ChatBubble(data: data),
                        ),
                      // Loading
                      if (isLoading)
                        const PositionWrapper(
                          fromUser: false,
                          child: ChatBubbleLoading(),
                        ),
                      // Add some extra space so the chat history won't be hidden by the TextArea
                      const SizedBox(height: 240),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 12,
                left: 12,
                right: 12,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemGroupedBackground,
              ),
              child: MultiLineTextArea(
                handleConfirm: handleConfirm,
                boxDecoration: const BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                // Can not send msg when waiting for response from the model.
                disableConfirm: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
