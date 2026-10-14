/// Route names used with MaterialApp's initialRoute / routes.
class AppRoutes {
  static const String posts = '/';
  static const String details = '/details';
  static const String favorites = '/favorites';
}

/// Hive box that stores saved posts (key = post id, value = Map).
const String favoritesBoxName = 'favoritesBox';

/// REST API endpoint.
const String postsUrl = 'https://jsonplaceholder.typicode.com/posts';
