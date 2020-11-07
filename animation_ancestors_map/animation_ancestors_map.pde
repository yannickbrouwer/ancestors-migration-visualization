/*

Ancestor Migration Animation by Yannick Brouwer 2019
 
 Attribution:
 Based on TransitFlow created by Will Geary: https://github.com/transitland/transitland-processing-animation
 Juan Francisco Saldarriaga's workshop on Processing: https://github.com/juanfrans-courses/DataScienceSocietyWorkshop
 Till Nagel's Unfolding Maps library: http://unfoldingmaps.org/
 Rasmus Andersson's Inter font: https://rsms.me/inter/
 
 Controls
 'Spacebar' is pause and play
 'k' is add a keyframe, it adds the current position and zoomlevel of your screen.
 's' is save keyframes, next time you open the sketch it will load these externally from keyframes.txt
 + and - zoom in and out
 Cursors keys, move around the map
 
 Lef mouse click on map: drag map
 Left mouse on click on timeline: scroblle timeline
 Right mouse click on timeline: delete nearby keyframe
 Scroll mouse zoom in and out
 */

////// Libraries ///////

// Import Java utilities
import java.util.concurrent.TimeUnit;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.FileWriter;
import java.io.*;

// Import Unfolding Maps
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;
UnfoldingMap map;

// Basemap providers
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
AbstractMapProvider provider4;
AbstractMapProvider provider5;
AbstractMapProvider provider6;
AbstractMapProvider provider7;
AbstractMapProvider provider8;
AbstractMapProvider provider9;
AbstractMapProvider provider0;
AbstractMapProvider providerq;
AbstractMapProvider providerw;
AbstractMapProvider providere;
AbstractMapProvider providerr;
AbstractMapProvider providert;
AbstractMapProvider providery;
AbstractMapProvider provideru;
AbstractMapProvider provideri;

String provider1Attrib;
String provider2Attrib;
String provider3Attrib;
String provider4Attrib;
String provider5Attrib;
String provider6Attrib;
String provider7Attrib;
String provider8Attrib;
String provider9Attrib;
String provider0Attrib;
String providerqAttrib;
String providerwAttrib;
String providereAttrib;
String providerrAttrib;
String providertAttrib;
String provideryAttrib;
String provideruAttrib;

String attrib;
Float attribWidth;


////// Files ///////
String directoryName = "${DIRECTORY_NAME}";
String date = "${DATE}";
String inputFile = "../data/ancestors_randomized.csv"; // This dataset is completely randomized so don't worry if it looks different to the video that I made.

FileWriter fw;
BufferedWriter bw;


////// Settings ///////
int totalFrames = 1410; // Original animation covers 470 years, so each year covers 3 frames (3*470=1410) in the animation.

// Center of the location and zoomlevel at start of the animation. 
// You could save a keyframe and then open keyframes.txt to find the coordinates and keyframe to enter here or you can find the lat and long for any location online using https://www.latlong.net/
Location center = new Location(47.841984, 2.2001846);
Integer zoom_start = 5;

//Date Format
String date_format = "dd/MM/yyyy";
String date_display = "yyyy";
String day_format = "EEEE";
String time_format = "h:mm a";

// define date format of raw data
SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd");

////// Variables ///////
ArrayList<Trips> trips = new ArrayList<Trips>();
ArrayList<String> sex_color = new ArrayList<String>();

long totalDays;
Table tripTable;


// Keyframes
// This is a list that holds all the current keyframes. On start imports keyframes from keyframes.txt, it holds any changes made to keyframes by the user and by pressing 'S' the latest state is saved to keyframes.txt 
StringList allKeyFrames = new StringList();
ArrayList<keyFrame> keyframes =new ArrayList<keyFrame>();

int keyframeIndex;
int indicator;
int currentLocation = 0;
int prevNearest = 10000;

ScreenPosition startPos;
ScreenPosition endPos;
Location startLocation;
Location endLocation;
Date minDate;
Date maxDate;
Date startDate;
Date endDate;
Date thisStartDate;
Date thisEndDate;

////// UI ///////

// Determine the size of the UI on the bottom of the screen.
int boxX = 0;
int boxY = 960;
int boxW = 960;
int boxH = 60;

// Left and right X coordinate of the timeline
int tlA = 60;
int tlB = 896;

PFont fontInter;
Integer screenfillalpha = 210;
PImage pointer;

boolean pause = false;
boolean endAnimation = false;
PImage playImg;
PImage pauseImg;
PImage replayImg;

Float firstLat;
Float firstLon;
color c;

int counterFrames = 0;




void setup() {

  // Determine the resolution and displaydensity. This was created one a high density display. 
  // Therefore the 960*600 becomes 1920*1200. If I record that for a video and remove the UI on the bottom I end up with a Full HD video (1920*1080)
  // If you get an error, replace displayDensity() with 1 for normal density or 2 for high density displays.
  pixelDensity(displayDensity());
  size(960, 1020, P3D);


  // Load image assets for the interface
  playImg = loadImage("assets/play.png");
  pauseImg = loadImage("assets/pause.png");
  replayImg = loadImage("assets/replay.png");
  pointer = loadImage("assets/label.png");

  // Import keyframes from external textfile and save them in the allKeyFrames list
  String[] lines = loadStrings("data/keyframes.txt");

  for (int i = 0; i < lines.length; i++) {
    println(lines[i]);
    allKeyFrames.append(lines[i]);

    String[] list = split(lines[i], ',');

    keyframes.add(new keyFrame(int(trim(list[0])), float(trim(list[1])), float(trim(list[2])), int(trim(list[3]))));
  }

  // Mapproviders
  provider1 = new StamenMapProvider.TonerLite();
  provider2 = new StamenMapProvider.TonerBackground();
  provider3 = new CartoDB.Positron();
  provider4 = new Microsoft.AerialProvider();
  provider5 = new OpenStreetMap.OpenStreetMapProvider();
  provider6 = new OpenStreetMap.OSMGrayProvider();
  provider7 = new EsriProvider.WorldStreetMap();
  provider8 = new EsriProvider.DeLorme();
  provider9 = new EsriProvider.WorldShadedRelief();
  provider0 = new EsriProvider.NatGeoWorldMap();
  providerq = new EsriProvider.OceanBasemap();
  providerw = new EsriProvider.WorldGrayCanvas();
  providere = new EsriProvider.WorldPhysical();
  providerr = new EsriProvider.WorldStreetMap();
  providert = new EsriProvider.WorldTerrain();
  providery = new EsriProvider.WorldTopoMap();
  provideru = new Google.GoogleMapProvider();

  provider1Attrib = "Stamen Design";
  provider2Attrib = "Stamen Design";
  provider3Attrib = "Carto";
  provider4Attrib = "Bing Maps";
  provider5Attrib = "OpenStreetMap";
  provider6Attrib = "OpenStreetMap";
  provider7Attrib = "ESRI";
  provider8Attrib = "ESRI";
  provider9Attrib = "ESRI";
  provider0Attrib = "ESRI";
  providerqAttrib = "ESRI";
  providerwAttrib = "ESRI";
  providereAttrib = "ESRI";
  providerrAttrib = "ESRI";
  providertAttrib = "ESRI";
  provideryAttrib = "ESRI";
  provideruAttrib = "Google Maps";

  smooth();

  loadData();

  // Choose the default mapprovider
  map = new UnfoldingMap(this, "provider3", 0, 0, width, boxY);
  MapUtils.createDefaultEventDispatcher(this, map);

  // Tweening makes transitions between locations and zoomlevels smooth
  map.setTweening(true);

  // Start at zoomlevel and location as determined in variable at the top of this file.
  map.zoomAndPanTo(zoom_start, center);

  attrib = "Basemap by " + provider3Attrib;
  attribWidth = textWidth(attrib);

  // Font
  fontInter  = loadFont("Inter-Medium-48.vlw");
}

float h_offset;

void loadData() {

  // Handles importing the dataset
  tripTable = loadTable(inputFile, "header");
  println(str(tripTable.getRowCount()) + " records loaded...");

  // Calculate min start time and max end time (start time must be sorted ascending)
  String first = tripTable.getString(0, "start_time");
  String last = tripTable.getString(tripTable.getRowCount()-1, "end_time");

  println("Min departure time: ", first);
  println("Max departure time: ", last);

  try {
    minDate = myDateFormat.parse(first); //first date
    maxDate = myDateFormat.parse(last); //latest date
    totalDays = TimeUnit.MILLISECONDS.toDays(maxDate.getTime() - minDate.getTime()); //difference between the first and last day in the dataset, used for animation
  }
  catch (Exception e) {
    println("Unable to parse date stamp");
  }
  println("Min starttime:", minDate, ". In epoch:", minDate.getTime()/1000);
  println("Max starttime:", maxDate, ". In epoch:", maxDate.getTime()/1000);
  println("Total days in dataset:", totalDays);
  println("Total frames:", totalFrames);

  firstLat = tripTable.getFloat(0, "start_lat");
  firstLon = tripTable.getFloat(0, "start_lon");

  for (TableRow row : tripTable.rows()) {
    String sex = row.getString("sex");
    sex_color.add(sex);

    int tripduration = row.getInt("duration_in_days");
    int duration = round(map(tripduration, 0, totalDays, 0, totalFrames));

    try {
      thisStartDate = myDateFormat.parse(row.getString("start_time"));
      thisEndDate = myDateFormat.parse(row.getString("end_time"));
    }
    catch (Exception e) {
      println("Unable to parse destination");
    }

    int startFrame = floor(map(thisStartDate.getTime(), minDate.getTime(), maxDate.getTime(), 0, totalFrames));
    int endFrame = floor(map(thisEndDate.getTime(), minDate.getTime(), maxDate.getTime(), 0, totalFrames));

    float startLat = row.getFloat("start_lat");
    float startLon = row.getFloat("start_lon");
    float endLat = row.getFloat("end_lat");
    float endLon = row.getFloat("end_lon");
    startLocation = new Location(startLat, startLon);
    endLocation = new Location(endLat, endLon);
    trips.add(new Trips(duration, startFrame, endFrame, startLocation, endLocation));
  }
}


void draw() {
  if (pause) {
  } else {
    // This is the timer for the animations, when this number increase the animation moves forward.
    counterFrames++;
  }

  map.draw();
  noStroke();

  // Make the basemap a bit darker to increase contrast
  fill(0, screenfillalpha);
  rect(0, 0, width, height);

  // Handle time
  float epoch_float = map(counterFrames, 0, totalFrames, int(minDate.getTime()/1000000), int(maxDate.getTime()/1000000));
  int epoch = int(epoch_float);

  String date = new java.text.SimpleDateFormat(date_display).format(new java.util.Date(epoch * 1000000L));
  //  String day = new java.text.SimpleDateFormat(day_format).format(new java.util.Date(epoch * 1000000L));
  //  String time = new java.text.SimpleDateFormat(time_format).format(new java.util.Date(epoch * 1000000L));


  // Enables scrubbing through the timeline using the mouse
  if (mouseX>60&&mouseX<(boxX+boxW)&&mouseY>boxY&&mouseY<boxY+boxH) {
    float mouseCursor = map(mouseX, tlA, tlB, 0, totalFrames);
    if (mousePressed && ( mouseButton == LEFT)) {
      counterFrames = int(mouseCursor);
    }
  }

  // Draw people
  noStroke();
  for (int i=0; i < trips.size(); i++) {

    Trips trip = trips.get(i);
    String sex = sex_color.get(i);

    switch(sex) {
    case "M":
      c = color(0, 191, 255);
      break;
    case "F":
      c = color(250, 128, 114);
      break;
    }
    fill(c, 180);
    trip.plotMove();
  }

  //Draw Controls & Timeline
  fill(40);
  rect(boxX, boxY, boxX+boxW, boxY+boxH);
  strokeWeight(1);
  stroke(50);
  line(boxX, boxY, boxX+boxW, boxY);
  float cursor = map(counterFrames, 0, totalFrames, tlA, tlB);
  strokeWeight(2);
  stroke(160);
  line(tlA, boxY+(boxH/2), tlB, boxY+(boxH/2));
  stroke(200);
  line(cursor, boxY+(boxH/2)-10, cursor, boxY+(boxH/2)+10);

  fill(160, 255);
  textFont(fontInter);
  textSize(12);
  textAlign(LEFT);
  text(date, 20, 48);


  // Show mapprovider attribution
  fill(80, 255);
  textSize(4);
  textAlign(CENTER);
  text(attrib, width/2, height-10);


  // Stop animation at the end
  if (counterFrames>totalFrames-1) {
    counterFrames = totalFrames;
    image(replayImg, 0, boxY, 60, 60);
    pause = true;
    endAnimation = true;
  }
  else {
  if (pause) {
    image(playImg, 0, boxY, 60, 60);
  } else {
    image(pauseImg, 0, boxY, 60, 60);
  }
  }

  for (int i = 0; i < keyframes.size(); i++) {
    keyframes.get(i).update();
  }
}

class keyFrame {
  Location x;
  int keyframe;
  int zoomlevel;

  keyFrame(int kf, float lat, float lon, int zl) {
    x = new Location(lat, lon);
    keyframe = kf;
    zoomlevel = zl;
  }

  void update() {

    // When the internal animation counter corresponds with the timestamp of a keyframe the frame is zoomed and panned to the right location and zoomlevel
    if (keyframe==counterFrames) {
      map.zoomAndPanTo(zoomlevel, x);
    }
    // Used to show the keyframe pointer at the right position on the timeline.
    float kfTL = map(keyframe, 0, totalFrames, tlA, tlB);
    image(pointer, kfTL-pointer.width/4, boxY-8+(boxH/2)-pointer.height/2, pointer.width/2, pointer.height/2);
  }
  // Find the closest keyframe to the pointer on the timeline. Is used to delete a keyframe with right click.
  void getNearby() {
    keyframeIndex = abs(keyframe - counterFrames);
  }
}

class Trips {
  int tripFrames;
  int startFrame;
  int endFrame;
  Location start;
  Location end;
  Location currentLocation;
  ScreenPosition currentPosition;
  int s;

  float xscale = 1.8;
  float yscale = 0.8;

  // class constructor
  Trips(int duration, int start_frame, int end_frame, Location startLocation, Location endLocation) {
    
    tripFrames = duration;
    startFrame = start_frame;
    endFrame = end_frame;
    start = startLocation;
    end = endLocation;
  }

  // function to draw each trip
  void plotMove() {
    if (counterFrames >= startFrame && counterFrames < endFrame) {
      float percentTravelled = (float(counterFrames) - float(startFrame)) / float(tripFrames);

      currentLocation = new Location(

        // Lerp is a function for linear interpolation between two points. It will find a point between two coordinates based on a percentage. 

        lerp(start.x, end.x, percentTravelled), 
        lerp(start.y, end.y, percentTravelled));

      currentPosition = map.getScreenPosition(currentLocation);

      // In that area you can change the size of the circles for each zoomlevel. I decided to keep them always the same.
      float z = map.getZoom();
      if (z <= 32.0) { 
        s = 5;
      } else if (z == 64.0) { 
        s = 5;
      } else if (z == 128.0) { 
        s = 5;
      } else if (z == 256.0) { 
        s = 5;
      } else if (z == 512.0) { 
        s = 5;
      } else if (z == 1024.0) { 
        s = 5;
      } else if (z == 2048.0) { 
        s = 5;
      } else if (z == 4096.0) { 
        s = 5;
      } else if (z == 8192.0) { 
        s = 5;
      } else if (z >= 16384.0) { 
        s = 5;
      }

      ellipse(currentPosition.x, currentPosition.y, s, s);
    }
  }
}

void mouseReleased() {

  // Pause and play when clicking the pause/play button 
  if (mouseX>0&&mouseX<60&&mouseY>boxY&&mouseY<height) {
    if (pause==true) {
      
      // Restart when animation is finished
      if (endAnimation){
        map.zoomAndPanTo(zoom_start, center);
        delay(500);
        endAnimation = false;
        counterFrames = 0;
        
      }
      
      pause = false;
      
    } else {
      pause = true;
    }
  }

  // Click anywhere on the timeline to position the cursor there.
  if (mouseX>60&&mouseX<(boxX+boxW)&&mouseY>boxY&&mouseY<boxY+boxH) {
    float mouseCursor = map(mouseX, tlA, tlB, 0, totalFrames);

    // Right Click near a keyframe on the timeline to remove the closest keyframe.   
    if (mouseButton == RIGHT) {

      if (keyframes.size()>0) { 
        counterFrames = int(mouseCursor);
        for (int i = 0; i < keyframes.size(); i++) {

          keyframes.get(i).getNearby();

          if (keyframeIndex<=prevNearest) {
            prevNearest = keyframeIndex;
            indicator = i;
          }

          println(i + " "  + keyframeIndex);
        }

        println(indicator + " "  + prevNearest);


        keyframes.remove(indicator);
        allKeyFrames.remove(indicator);

        indicator = 0;
        prevNearest = 10000;
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    if (pause==true) {
      pause = false;
    } else {
      pause = true;
    }
  }



  if (key == 'k') {
    // Save the current position, zoomlevel and postion on the timeline as new keyframe.
    String loc;

    println(map.getCenter().getLat());
    loc = (counterFrames+","+map.getCenter().getLat()+","+map.getCenter().getLon()+","+map.getZoomLevel());

    allKeyFrames.append(loc);
    keyframes.add(new keyFrame(counterFrames, map.getCenter().getLat(), map.getCenter().getLon(), map.getZoomLevel()));
  }
  if (key == 's') {

    // By pressing S you save the current keyframes to a text file. Next time you open the sketch it will import the keyframes externally.
    String[] save = new String[allKeyFrames.size()];
    for (int i=0; i < allKeyFrames.size(); i++) {

      save[i] = allKeyFrames.get(i);
    }
    saveStrings("data/keyframes.txt", save);
  }

  // Use 0-9 and q,w,e,r,t,y,u keys to change the type of map in the background.
  if (key == '1') {
    map.mapDisplay.setProvider(provider1);
    attrib = "Basemap by " + provider1Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '2') {
    map.mapDisplay.setProvider(provider2);
    attrib = "Basemap by " + provider2Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '3') {
    map.mapDisplay.setProvider(provider3);
    attrib = "Basemap by " + provider3Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '4') {
    map.mapDisplay.setProvider(provider4);
    attrib = "Basemap by " + provider4Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '5') {
    map.mapDisplay.setProvider(provider5);
    attrib = "Basemap by " + provider5Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '6') {
    map.mapDisplay.setProvider(provider6);
    attrib = "Basemap by " + provider6Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '7') {
    map.mapDisplay.setProvider(provider7);
    attrib = "Basemap by " + provider7Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '8') {
    map.mapDisplay.setProvider(provider8);
    attrib = "Basemap by " + provider8Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '9') {
    map.mapDisplay.setProvider(provider9);
    attrib = "Basemap by " + provider9Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == '0') {
    map.mapDisplay.setProvider(provider0);
    attrib = "Basemap by " + provider0Attrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'q') {
    map.mapDisplay.setProvider(providerq);
    attrib = "Basemap by " + providerqAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'w') {
    map.mapDisplay.setProvider(providerw);
    attrib = "Basemap by " + providerwAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'e') {
    map.mapDisplay.setProvider(providere);
    attrib = "Basemap by " + providereAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'r') {
    map.mapDisplay.setProvider(providerr);
    attrib = "Basemap by " + providerrAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 't') {
    map.mapDisplay.setProvider(providert);
    attrib = "Basemap by " + providertAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'y') {
    map.mapDisplay.setProvider(providery);
    attrib = "Basemap by " + provideryAttrib;
    attribWidth = textWidth(attrib);
  } else if (key == 'u') {
    map.mapDisplay.setProvider(provideru);
    attrib = "Basemap by " + provideruAttrib;
    attribWidth = textWidth(attrib);
  }
}
