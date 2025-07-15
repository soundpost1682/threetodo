class Todo {
  final int? id; // 데이터베이스 ID (null = 새로운 항목)
  final String title; // 할 일 제목
  final String category; // 카테고리 (성장, 운동, 공부, 자기관리)
  final String? icon; // 이모지 또는 아이콘
  final DateTime date; // 할 일 날짜
  final bool isCompleted; // 완료 여부

  Todo({
    this.id,
    required this.title,
    required this.category,
    this.icon,
    required this.date,
    this.isCompleted = false,
  });

  // 데이터베이스 작업을 위한 Map 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'icon': icon,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Map에서 Todo 객체 생성
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      icon: map['icon'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // 객체 복사본 생성 (상태 업데이트용)
  Todo copyWith({
    int? id,
    String? title,
    String? category,
    String? icon,
    DateTime? date,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
