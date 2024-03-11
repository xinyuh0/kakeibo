class UserProfile {
  var _budget = 10000;

  UserProfile(int budget) {
    _budget = budget;
  }

  UserProfile.fromJson(Map<String, dynamic> json)
      : _budget = json['budget'] as int;

  Map<String, dynamic> toJson() => {
        'budget': _budget,
      };

  int get budget {
    return _budget;
  }

  void setBudget(int newBudget) {
    _budget = newBudget;
  }
}
