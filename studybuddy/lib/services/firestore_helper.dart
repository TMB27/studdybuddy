class FirestoreHelper {
  static String collectionForFeatureType(String? featureType) {
    switch ((featureType ?? '').toLowerCase()) {
      case 'notes':
        return 'notes';
      case 'pyqs':
        return 'pyqs';
      case 'solved pyqs':
        return 'solved_pyqs';
      case 'shot notes':
        return 'shot_notes';
      default:
        return 'notes';
    }
  }

  static const List<String> years = [
    'First Year Engineering',
    'Second Year Engineering',
    'Third Year Engineering',
    'Fourth Year Engineering',
  ];

  static const List<String> featureTypes = [
    'Notes',
    'PYQs',
    'Solved PYQs',
    'Shot Notes',
  ];

  static const Map<String, Map<String, List<String>>> yearFeatureSubjects = {
    'First Year Engineering': {
      'notes': [
        'Engineering Mathematics 1',
        'Engineering Mathematics 2',
        'Engineering Physics',
        'Engineering Chemistry',
        'Engineering Mechanics',
        'Basic Electrical Engineering',
        'Basic Electronic Engineering',
        'Programming and Problem Solving',
      ],
      'pyqs': [
        'Engineering Mathematics 1',
        'Engineering Mathematics 2',
        'Engineering Physics',
        'Engineering Chemistry',
        'Engineering Mechanics',
        'Basic Electrical Engineering',
        'Engineering Graphics',
        'Environmental Studies',
      ],
      'solved pyqs': [
        'Engineering Mathematics 1',
        'Engineering Physics'
      ],
      'shot notes': [
        'Engineering Mechanics',
        'Programming and Problem Solving',
      ],
    },
    'Second Year Engineering': {
      'notes': [
        'Data Structures',
        'Discrete Mathematics',
        'Digital Logic Design',
      ],
      'pyqs': ['Data Structures', 'Discrete Mathematics'],
      'solved pyqs': ['Digital Logic Design'],
      'shot notes': ['Data Structures'],
    },
    'Third Year Engineering': {
      'notes': ['Operating Systems', 'Database Management Systems'],
      'pyqs': ['Operating Systems'],
      'solved pyqs': ['Database Management Systems'],
      'shot notes': ['Operating Systems'],
    },
    'Fourth Year Engineering': {
      'notes': ['Machine Learning', 'Artificial Intelligence'],
      'pyqs': ['Machine Learning'],
      'solved pyqs': ['Artificial Intelligence'],
      'shot notes': ['Machine Learning'],
    },
  };

  static List<String> subjectsFor(String year, String featureType) {
    final normalizedFeatureType = featureType.toLowerCase();
    return yearFeatureSubjects[year]?[normalizedFeatureType] ?? [];
  }
} 