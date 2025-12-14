import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:path_provider/path_provider.dart';

mixin DioCacheManager {
  static Directory? tempDirectory;

  Future<DioCacheInterceptor> getCacheInterceptor({
    CachePolicy cachePolicy = CachePolicy.refreshForceCache,
  }) async {
    tempDirectory ??= await getTemporaryDirectory();
    final cacheOptions = CacheOptions(
      // A default store is required for interceptor.
      store: FileCacheStore(tempDirectory!.path),

      // Default.
      policy: cachePolicy,
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 3),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: false,
    );

    return DioCacheInterceptor(options: cacheOptions);
  }
}
