import 'category.dart';

class PieChartIndicatorData {
  const PieChartIndicatorData({
    required this.category,
    required this.amount,
    required this.ratio,
  });

  final Category category;
  final int amount;
  final double ratio;
}

class TrendData {
  const TrendData({
    required this.category,
    required this.ratio,
    required this.diff,
    required this.isNew,
  });

  final Category category;
  final double ratio;
  final int diff;
  final bool isNew;
}

class ChatHistoryData {
  ChatHistoryData({
    required this.chatId,
    // Used for sending to the server as prompt
    required this.content,
    required this.fromUser,
    // Whether to show in the chat stream
    this.show = true,
    this.time,
    // Content for display, equals to `content` by default
    String? displayContent,
  }) : displayContent = displayContent ?? content;

  final int chatId;
  final String content;
  final bool fromUser;
  final String displayContent;
  final bool show;

  DateTime? time;
}
