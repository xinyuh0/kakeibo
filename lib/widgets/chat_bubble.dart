import 'package:flutter/cupertino.dart';
import 'package:kkb/model/statistic.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubbleLoading extends StatelessWidget {
  const ChatBubbleLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          CupertinoActivityIndicator(),
          SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatHistoryData data;

  const ChatBubble({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            data.fromUser ? CupertinoColors.activeBlue : CupertinoColors.white,
        borderRadius: data.fromUser
            ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
                topRight: Radius.circular(2),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
      ),
      padding: const EdgeInsets.all(12),
      child: MarkdownBody(
        data: data.displayContent,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            // To make rendered font look similar to the system font
            letterSpacing: -0.3,
            fontSize: 18,
            color:
                data.fromUser ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ),
    );
  }
}

typedef HandleTapRecommendationFunction = Function(ChatHistoryData);

class RecommendQuestionBubble extends StatelessWidget {
  final ChatHistoryData data;
  final HandleTapRecommendationFunction onTap;

  const RecommendQuestionBubble({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(data);
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(
            color: CupertinoColors.activeBlue,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: MarkdownBody(
          data: data.displayContent,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(
              color: CupertinoColors.activeBlue,
              // To make rendered font look similar to the system font
              letterSpacing: -0.3,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBubbleWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedBubbleWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedBubbleWrapper> createState() => _AnimatedBubbleWrapperState();
}

class _AnimatedBubbleWrapperState extends State<AnimatedBubbleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween(
      begin: const Offset(0.0, 0.1),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
