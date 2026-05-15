import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topik_go/app/theme/app_colors.dart';
import 'package:topik_go/core/network/api_error_message.dart';
import 'package:topik_go/features/explanation_video/data/explanation_video_repository.dart';

class ExplanationVideoListPage extends ConsumerWidget {
  const ExplanationVideoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedVideosProvider);
    final allAsync = ref.watch(explanationVideosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('문제 해설 영상')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recommendedVideosProvider);
          ref.invalidate(explanationVideosProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('추천 해설 영상', Icons.star_outline),
            const SizedBox(height: 12),
            recommendedAsync.when(
              data: (videos) => _VideoHorizontalList(videos: videos),
              loading: () => const _LoadingPlaceholder(height: 180),
              error: (err, _) => _ErrorCard(message: apiErrorMessage(err)),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('전체 영상 목록', Icons.video_library_outlined),
            const SizedBox(height: 12),
            allAsync.when(
              data: (videos) => _VideoVerticalList(videos: videos),
              loading: () => const _LoadingPlaceholder(height: 400),
              error: (err, _) => _ErrorCard(message: apiErrorMessage(err)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.mintDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _VideoHorizontalList extends StatelessWidget {
  const _VideoHorizontalList({required this.videos});
  final List<ExplanationVideo> videos;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const _EmptyCard(message: '추천 영상이 없습니다.');

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _VideoCard(
          video: videos[index],
          width: 280,
        ),
      ),
    );
  }
}

class _VideoVerticalList extends StatelessWidget {
  const _VideoVerticalList({required this.videos});
  final List<ExplanationVideo> videos;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const _EmptyCard(message: '영상 목록이 비어있습니다.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _VideoListItem(video: videos[index]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.width});
  final ExplanationVideo video;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Open Video Player
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: video.thumbnailUrl != null
                    ? Image.network(video.thumbnailUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.play_circle_outline, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDuration(video.durationSeconds)} · 조회수 ${video.viewCount}회',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

class _VideoListItem extends StatelessWidget {
  const _VideoListItem({required this.video});
  final ExplanationVideo video;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 68,
              child: video.thumbnailUrl != null
                  ? Image.network(video.thumbnailUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '조회수 ${video.viewCount}회',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(message, style: const TextStyle(color: Colors.grey))),
    );
  }
}
