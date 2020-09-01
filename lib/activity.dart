class Activity {
  String name;
  String duration;
  bool finished;
  String id;

  Activity({this.name, this.duration, this.finished, this.id});

  getName() => this.name;
  setName(name) => this.name = name;

  getDuration() => this.duration;
  setDuration(duration) => this.duration = duration;

  getFinished() => this.finished;
  setFinished(finished) => this.finished = finished;

  getId() => this.id;
  setId(id) => this.id = id;


}