class Activity {

  // Class properties
  // Underscore makes them private
  String name;
  String duration;
  bool finished;
  String id;

  // Default constructor
  // this syntax means that it will accept a value and set it to this.name
//  Activity(this.name, this.duration, this.finished, this.id);
  Activity({this.name, this.duration, this.finished, this.id});

  getName() => this.name;
  setName(name) => this.name = name;

  getDuration() => this.duration;
  setDuration(duration) => this.duration = duration;

  getFinished() => this.finished;
  setFinished(finished) => this.finished = finished;

  getId() => this.id;
  setId(id) => this.id = id;

//
//  factory Activity.fromJson(Map<String, dynamic> json) {
//    return Activity(
//      json['name'],
//      json['duration'],
//      json['finished'],
//      json['_id'],
//    );
//  }

}