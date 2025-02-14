
import java.util.Calendar;
PImage img;

//Used image guide https://processing.org/examples/loadingimages.html
//Used link guide https://processing.org/examples/embeddedlinks.html

void stop() {
  saveData();
  super.stop();
}


class Assignment {
  String title;
  String course;
  String dueDate;
  boolean completed;
  
  Assignment(String t, String c, String d) {
    title = t;
    course = c;
    dueDate = d;
    completed = false;
    
  }
}

void saveData() {
  JSONArray saveData = new JSONArray();
  for (Assignment a : assignments) {
    JSONObject assignmentJSON = new JSONObject();
    assignmentJSON.setString("title", a.title);
    assignmentJSON.setString("course", a.course);
    assignmentJSON.setString("dueDate", a.dueDate);
    assignmentJSON.setBoolean("completed", a.completed);
    saveData.append(assignmentJSON);
  }
  saveJSONArray(saveData, dataPath("assignments.json"));
}

void loadData() {
  try {
    JSONArray loadData = loadJSONArray(dataPath("assignments.json"));
    assignments.clear();
    for (int i = 0; i < loadData.size(); i++) {
      JSONObject a = loadData.getJSONObject(i);
      assignments.add(new Assignment(
        a.getString("title"),
        a.getString("course"),
        a.getString("dueDate")
      ));
      assignments.get(i).completed = a.getBoolean("completed");
    }
  } catch (Exception e) {
    println("No save file found, starting fresh");
  }
}


ArrayList<Assignment> assignments = new ArrayList<Assignment>();
int selected = 0;
String[] inputLabels = {"Assignment:", "Course:", "Due Date (MM/DD):"};
String[] inputs = {"", "", ""};
boolean showError = false;

void setup() {
  size(800, 600);
  textSize(16);
  fill(128, 0, 0);
  loadData();
  img = loadImage("https://static-00.iconduck.com/assets.00/calendar-small-icon-465x512-1wuvg4w9.png");
}


void draw() {
  background(240);
  drawInputForm();
  drawAssignmentList();
  if (img != null) {
    img.resize(80, 80);
    image(img, 450, 30);
  }
  if (showError) drawErrorMessage();
}




void drawInputForm() {
  fill(255);
  rect(20, 20, 760, 100);  
  fill(0);
  
  for (int i = 0; i < 3; i++) {
    textAlign(LEFT, BASELINE); 
    text(inputLabels[i], 40, 50 + i*30);
    
    
    fill(selected == i ? 200 : 255);
    rect(200, 30 + i*30, 200, 25);
    
    
    textAlign(LEFT, CENTER); 
    fill(0);
    text(inputs[i], 205, 45 + i*30); 
  }
  
  
  textAlign(CENTER, CENTER);
  fill(150, 255, 150);
  rect(600, 50, 80, 30);
  fill(0);
  text("Add", 640, 65);  
  textAlign(LEFT, BASELINE);  
}


int daysUntilDue(Assignment a){
  String[] monthDay = split(a.dueDate, '/');
  Calendar due = Calendar.getInstance();
  due.set(Calendar.MONTH, int(monthDay[0]) - 1);
  due.set(Calendar.DATE, int(monthDay[1]));
  due.set(Calendar.YEAR, year());
  Calendar now = Calendar.getInstance();
  long diff = due.getTimeInMillis() - now.getTimeInMillis();
  return int(diff / (1000 * 60 * 60 * 24));
}
void drawAssignmentList() {
  int y = 150;
  for (int i = 0; i < assignments.size(); i++) {
    Assignment a = assignments.get(i);
    fill(selected == i + 3 ? 200 : 255);
    rect(20, y, 760, 40);
    fill(a.completed ? 150 : 0);
    
    fill(255);
    rect(30, y+10, 20, 20);
    if (a.completed) {
      fill(0);
      text("✓", 35, y+25);
    }
    
    
    int days = daysUntilDue(a);
    
    if (days < 3){
      fill(255, 0, 0);
    }
    if (days >= 3 && days < 7){
      fill(128, 128, 0);
    }
    if (days >= 7){
      fill(0, 255, 0);
    }
    
    text(a.course, 60, y+25);
    text(a.title, 350, y+25);
    
    text(a.dueDate, 600, y+25);
    
    
    fill(255, 150, 150);
    rect(700, y+5, 70, 30);
    fill(0);
    text("Delete", 710, y+25);
    
    y += 50;
  }
}
void clearInput(){
  for (int i = 0; i < inputs.length; i++){
    inputs[i] = "";
  }
}
void mousePressed() {
  for (int i = 0; i < 3; i++) {
    float fieldY = 30 + i * 30; 
    if (mouseX > 200 && mouseX < 400 && 
        mouseY > fieldY && mouseY < fieldY + 25) { 
      if (selected < 3){
        selected = i;
      }
      
      return;
    }
  }
  if (img != null) {
    img.resize(80, 80);
    image(img, 450, 30);
  }
  if (mouseX > 450 && mouseX < 450 + 80 && mouseY > 30 && mouseY < 30 + 80){
    link("https://calendar.google.com/calendar/u/0/r");
    return;
  }
  if (mouseX > 600 && mouseX < 680 && mouseY > 50 && mouseY < 80) {
    boolean success = addAssignment();
    showError = !success;
    return;
}

  int listY = 150;
  for (int i = 0; i < assignments.size(); i++) {
    if (mouseX > 700 && mouseX < 770 && 
        mouseY > listY+5 && mouseY < listY+35) {
      assignments.remove(i);
      saveData();
      return;
    }

    if (mouseX > 30 && mouseX < 50 && 
        mouseY > listY+10 && mouseY < listY+30) {
      assignments.get(i).completed = !assignments.get(i).completed;
      return;
    }

    if (mouseX > 20 && mouseX < 780 && 
        mouseY > listY && mouseY < listY+40) {
      selected = i;
      return;
    }
    listY += 50;
  }
  selected = -1;
}


boolean addAssignment() {
  
  boolean isValid = !inputs[0].equals("") && !inputs[1].equals("") && inputs[2].matches("\\d{2}/\\d{2}");
                   
  if (!isValid) {
    showError = true;
    return false;
  }
  
  assignments.add(new Assignment(inputs[0], inputs[1], inputs[2]));
  saveData();
  selected = assignments.size() + 3 - 1;
  clearInput(); 
  
  return true;
}

void removeNewLines(){
  for (int i = 0; i < inputs.length; i++){
    inputs[i] = inputs[i].replaceAll("\n", "");
    inputs[i] = inputs[i].replaceAll("\t", "");
  }
}
void keyPressed() {
  
  if (key == BACKSPACE && selected >= 3){
      assignments.remove(selected - 3);
      saveData();
  }
  if (key == DELETE){
    int k = assignments.size();
    int i = 0;
    while (i < k){
      print(assignments);
      if (assignments.get(i).completed == true){
        assignments.remove(i);
        k--;
        i--;
      }
      i++;
    saveData();
    }
  }
  if (selected >= 0 && selected <= 2) {
    if (key == BACKSPACE) {
      inputs[selected] = inputs[selected].length() > 0 ? inputs[selected].substring(0, inputs[selected].length()-1) : "";
    
    } else if (key != CODED && key != TAB && key != ENTER) {
      inputs[selected] += key;
    }
    
  }
  
  if (key == TAB) {
    
    int totalFocusable = 3 + assignments.size();
    selected = (selected + 1) % totalFocusable;
    
  }
  
  if (key == CODED){
    if (keyCode == DOWN){
      int totalFocusable = 3 + assignments.size();
      selected = (selected + 1) % totalFocusable;
    }
    
    if (keyCode == UP){
      if (selected == 0){
        selected = assignments.size() + 2;
      } else {
        int totalFocusable = 3 + assignments.size();
        selected = (selected - 1) % totalFocusable;
      }
      
      
    }
  }
  
  
  if (key == 'c'){
    if (selected >= 3){
      if (assignments.get(selected - 3).completed == true){
        assignments.get(selected - 3).completed = false;
      } else {
        assignments.get(selected - 3).completed = true;
      }
      saveData();
    }
    
    
  }
  
  if (key == ENTER) {
    removeNewLines();
    if (showError) {
      showError = false;
    } else {
      
      boolean success = addAssignment();
      showError = !success;
      
      
    }
  }
  
  if (selected > 2){
    if (key == 'x'){
      link("https://calendar.google.com/calendar/u/0/r");
    }
    
    if (key == 's') {
      assignments.sort((a1, a2) -> {
          
          int completedCompare = Boolean.compare(a1.completed, a2.completed);
          if (completedCompare != 0) {
              return completedCompare;
          }
          
          
          String[] d1 = a1.dueDate.split("/");
          String[] d2 = a2.dueDate.split("/");
          int monthCompare = Integer.compare(
              Integer.parseInt(d1[0]), 
              Integer.parseInt(d2[0])
          );
          return (monthCompare != 0) 
              ? monthCompare 
              : Integer.compare(Integer.parseInt(d1[1]), Integer.parseInt(d2[1]));
      });
    }
  
  }
  
}


void drawErrorMessage() {
  fill(255, 200, 200);
  rect(width/2-150, height/2-25, 300, 50);
  fill(255, 0, 0);
  text("Invalid input! Check all fields", width/2-140, height/2);
}
