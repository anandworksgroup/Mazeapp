/// SQLite schema. Everything the game remembers lives in these tables on the
/// device; there is no server copy.
class Schema {
  Schema._();

  static const version = 1;

  static const player = 'player';
  static const characters = 'characters';
  static const themes = 'themes';
  static const sizes = 'sizes';
  static const mazeHistory = 'maze_history';
  static const achievements = 'achievements';
  static const settings = 'settings';
  static const currentGame = 'current_game';

  /// Tables included in a backup file, in restore order.
  static const backupTables = [
    player,
    characters,
    themes,
    sizes,
    mazeHistory,
    achievements,
    settings,
    currentGame,
  ];

  static const create = <String>[
    '''
    CREATE TABLE $player (
      id TEXT PRIMARY KEY,
      created_at INTEGER NOT NULL,
      selected_character TEXT NOT NULL,
      selected_theme TEXT NOT NULL,
      selected_size TEXT NOT NULL,
      total_games INTEGER NOT NULL DEFAULT 0,
      total_failed INTEGER NOT NULL DEFAULT 0,
      total_play_time_ms INTEGER NOT NULL DEFAULT 0,
      current_streak INTEGER NOT NULL DEFAULT 0,
      longest_streak INTEGER NOT NULL DEFAULT 0,
      last_play_day TEXT,
      full_unlock INTEGER NOT NULL DEFAULT 0
    )''',
    '''
    CREATE TABLE $characters (
      character_id TEXT PRIMARY KEY,
      unlocked INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER
    )''',
    '''
    CREATE TABLE $themes (
      theme_id TEXT PRIMARY KEY,
      unlocked INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER
    )''',
    '''
    CREATE TABLE $sizes (
      size_id TEXT PRIMARY KEY,
      unlocked INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER
    )''',
    '''
    CREATE TABLE $mazeHistory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seed INTEGER NOT NULL,
      size TEXT NOT NULL,
      theme_id TEXT NOT NULL,
      character_id TEXT NOT NULL,
      mode TEXT NOT NULL,
      day_key TEXT,
      completed INTEGER NOT NULL,
      time_ms INTEGER NOT NULL,
      moves INTEGER NOT NULL,
      bumps INTEGER NOT NULL,
      stars INTEGER NOT NULL,
      created_at INTEGER NOT NULL
    )''',
    'CREATE INDEX idx_history_size ON $mazeHistory(size, completed)',
    '''
    CREATE TABLE $achievements (
      achievement_id TEXT PRIMARY KEY,
      unlocked INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER
    )''',
    '''
    CREATE TABLE $settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )''',
    // One row at most: the unfinished maze, stored as its seed plus where the
    // player stands, never the maze itself.
    '''
    CREATE TABLE $currentGame (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      seed INTEGER NOT NULL,
      size TEXT NOT NULL,
      theme_id TEXT NOT NULL,
      character_id TEXT NOT NULL,
      mode TEXT NOT NULL,
      day_key TEXT,
      pos_x INTEGER NOT NULL,
      pos_y INTEGER NOT NULL,
      moves INTEGER NOT NULL,
      bumps INTEGER NOT NULL,
      elapsed_ms INTEGER NOT NULL,
      trail TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    )''',
  ];
}
