import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../domain/entities/repository.dart';

class RepositoryDetailsPage extends StatelessWidget {
  final Repository repository;

  const RepositoryDetailsPage({
    super.key,
    required this.repository,
  });

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Future<void> _launchUrl(String url) async {
    try {
      // Validate URL is not empty
      if (url.isEmpty) {
        Fluttertoast.showToast(
          msg: 'URL is empty',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Ensure URL has proper scheme
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final uri = Uri.parse(finalUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        
        Fluttertoast.showToast(
          msg: 'Opening in browser...',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        // Fallback: copy URL to clipboard
        await _copyUrlToClipboard(finalUrl);
      }
    } catch (e) {
      // Fallback: copy URL to clipboard on error
      String fallbackUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        fallbackUrl = 'https://$url';
      }
      await _copyUrlToClipboard(fallbackUrl);
    }
  }

  Future<void> _copyUrlToClipboard(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      Fluttertoast.showToast(
        msg: 'URL copied to clipboard: $url',
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Cannot open or copy URL',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: false,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dark mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ThemeChanged(value));
                      },
                      activeTrackColor: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository Name
            Text(
              repository.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            
            // Stars and Fork count
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(repository.stargazersCount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.call_split, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Fork: ${_formatNumber(repository.forksCount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Avatar and Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(repository.ownerAvatarUrl),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    repository.ownerName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launchUrl('https://github.com/${repository.ownerName}'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'github.com/${repository.ownerName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Description
            if (repository.description != null && repository.description!.isNotEmpty)
              Text(
                repository.description!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
            
            const SizedBox(height: 32),

            // GitHub URL Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Create fallback URL if htmlUrl is empty
                  String urlToOpen = repository.htmlUrl;
                  if (urlToOpen.isEmpty) {
                    urlToOpen = 'https://github.com/${repository.fullName}';
                  }
                  _launchUrl(urlToOpen);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('View on GitHub'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 