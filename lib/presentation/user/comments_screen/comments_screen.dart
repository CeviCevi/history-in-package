import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/comment_model.dart';
import 'package:pytl_backup/data/models/user_model/mock/user_model_mock.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/comment_service.dart';
import 'package:pytl_backup/domain/services/user_service.dart';

class CommentsScreen extends StatefulWidget {
  final int objectId;
  final String email;

  const CommentsScreen({
    super.key,
    required this.email,
    required this.objectId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentService.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedComments = await _commentService.getCommentsByObjectId(
        widget.objectId,
      );

      setState(() {
        _comments = fetchedComments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось загрузить комментарии: $e';
        _isLoading = false;
      });
    }
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = CommentModel(
      creatorEmail: widget.email,
      objectId: widget.objectId,
      content: text,
    );

    _commentController.clear();
    try {
      final createdComment = await _commentService.createComment(newComment);

      setState(() {
        _comments.add(createdComment);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при отправке комментария: $e';
      });
      _commentController.text = text;
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final CommentModel commentToDelete = _comments[index];
    setState(() {
      _comments.removeAt(index);
    });

    try {
      await _commentService.deleteComment(commentId);
    } catch (e) {
      setState(() {
        _comments.insert(index, commentToDelete);
        _errorMessage = 'Не удалось удалить комментарий: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Обсуждение (${_comments.length})"),
        backgroundColor: Colors.white,
        elevation: 1.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchComments,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Text("Пока нет комментариев. Будьте первыми!"),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[_comments.length - 1 - index];
        return _CommentBubble(
          comment: comment,
          emailUserInSystem: widget.email,
          onDelete: _deleteComment,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Написать комментарий...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addComment,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: primaryRed,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  final String emailUserInSystem;
  final Function(int) onDelete;

  final UserService _userService = UserService();

  _CommentBubble({
    required this.comment,
    required this.emailUserInSystem,
    required this.onDelete,
  });

  Future<UserModel> _loadCurrentUserData() async {
    try {
      return await _userService.getUserByEmail(comment.creatorEmail);
    } catch (e) {
      debugPrint('Ошибка загрузки данных текущего пользователя: $e');
      return userModelMock;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить комментарий?'),
          content: const Text(
            'Вы уверены, что хотите удалить этот комментарий? Это действие нельзя отменить.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (comment.id != null) {
                  onDelete(comment.id!);
                }
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = comment.creatorEmail == emailUserInSystem;

    Widget commentContent = FutureBuilder<UserModel>(
      future: _loadCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 30,
            width: 30,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? primaryRed : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data?.login ?? "snapshot.data!.email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isMe ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: 16,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${comment.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (isMe) {
      return GestureDetector(
        onLongPress: () => _showDeleteConfirmationDialog(context),
        child: Align(alignment: Alignment.centerRight, child: commentContent),
      );
    } else {
      return Align(alignment: Alignment.centerLeft, child: commentContent);
    }
  }
}
