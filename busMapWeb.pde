/* @pjs font="johnston.ttf"; */

//java imports
import java.util.Iterator;

//data containers
busStopList busStops;
stopLabelList stopLabels;
busRouteList busRoutes;
stopPairList stopPairs;

//what to include?
booleanHolder drawLabels = new booleanHolder(false);
booleanHolder drawStops = new booleanHolder(true);
booleanHolder drawRoutes = new booleanHolder(true);
booleanHolder drawPanel = new booleanHolder(true);
booleanHolder drawControlPanel = new booleanHolder(false);

//map controls
PVector defaultCentreOS = new PVector(531547, 823348); //mostyn gardens, in lambeth
PVector centreOS = new PVector(defaultCentreOS.x, defaultCentreOS.y); //centre on the OS Grid map //starting detail
floatHolder zoomFactor = new floatHolder(0.01, 0.0005, 0.02);

//labels
intHolder labelMouseRange = new intHolder(5, 0, 10); //how close can you get to a stop before the label pops out?
floatHolder labelWeight = new floatHolder(1, 0, 10); //how thick is the line between label and stop?
PFont newJohnston;
busStop selectedStop;

//selecting a stop
boolean chooseStop = false;
boolean chosenStop = false;

//symbols
PShape tubeLogo;
PShape trainLogo;
PShape dlrLogo;
PShape riverLogo;
PShape tramLogo;

//drawing the lines
booleanHolder scaleRouteOpacity = new booleanHolder(false);
floatHolder minRouteOpacity = new floatHolder(50, 0, 255);
floatHolder maxRouteOpacity = new floatHolder(255, 0, 255);
booleanHolder scaleRouteWeight = new booleanHolder(false);
floatHolder minRouteWeight = new floatHolder(1, 0, 10);
floatHolder maxRouteWeight = new floatHolder(10, 0, 10);

//colours
colourHolder backgroundColour = new colourHolder(color(0)); //colour behind it all
colourHolder stopColour = new colourHolder(color(255, 255, 255, 50)); //colour of the stops
colourHolder routeColour = new colourHolder(color(255, 0, 0, 50));
ArrayList<colourHolder> routeColours;

//so we can load in the data in the draw loop
int loadStep = 0;

void setup() {
  //initialise the display
  size(800, 500, P2D);
  background(0);
 
  //font
  newJohnston = createFont("johnston.ttf"); //http://www.rmweb.co.uk/community/index.php?/topic/8826-br-corporate-rail-alphabet-fonts/
  textFont(newJohnston, 12);
  
  //route colours
  routeColours = new ArrayList<colourHolder>();
  routeColours.add(new colourHolder(#3399FF));
  routeColours.add(new colourHolder(#990033));
  routeColours.add(new colourHolder(#00CC33));
  routeColours.add(new colourHolder(#663399));
  routeColours.add(new colourHolder(#CCFF33));
  routeColours.add(new colourHolder(#993300));
  routeColours.add(new colourHolder(#999999));
  routeColours.add(new colourHolder(#FFFFFF));
  routeColours.add(new colourHolder(#CC3333));
  routeColours.add(new colourHolder(#FF6600));
  routeColours.add(new colourHolder(#66FF99));
  routeColours.add(new colourHolder(#CC66CC));
  routeColours.add(new colourHolder(#6666CC));
  routeColours.add(new colourHolder(#99CCCC));
  routeColours.add(new colourHolder(#006633));
  routeColours.add(new colourHolder(#CCCC00));
  routeColours.add(new colourHolder(#CC0000));
  routeColours.add(new colourHolder(#FF9999));
  routeColours.add(new colourHolder(#FF9900));
  routeColours.add(new colourHolder(#6699FF));
  routeColours.add(new colourHolder(#990099));
  routeColours.add(new colourHolder(#33CC33));
  routeColours.add(new colourHolder(#FF9966));
  routeColours.add(new colourHolder(#FFFF99));
  
  //data containers
  stopLabels = new stopLabelList();
  stopPairs = new stopPairList();
  
  String stopsFilename = "busStops.csv";
  String routesFilename = "busRoutes.csv";

  //show progress while loading
  textSize(12);
  textAlign(CENTER);
  fill(255);
  
  //load the data
  text("Starting to load data at " + millis() + " milliseconds", width / 2, height / 2);
  
  //load symbols
  tubeLogo = loadShape("tubeRoundel.svg");
  trainLogo = loadShape("National_Rail_logo.svg");
  dlrLogo = loadShape("DLR_no-text_roundel.svg");
  riverLogo = loadShape("riverRoundel.svg");
  tramLogo = loadShape("Tramlink_no-text_roundel.svg");
}

void draw() {
  background(backgroundColour.value);

  //load the data if we haven't already -> and indicate what the next step will be as it can't write text/load at the same time
  switch(loadStep) {
    case 0: //need to load the bus stops -> and indid
      busStops = new busStopList("busStops.csv");
      text("Starting to load bus stops at " + millis() + " milliseconds", width / 2, height / 2);
      loadStep = 1;
      break;

    case 1: //load the bus routes
      busRoutes = new busRouteList("busRoutes.csv");
      text("Starting to make bus stop pairs at " + millis() + " milliseconds", width / 2, height / 2);
      loadStep = 2;
      break;

    case 2: //make pairs of stops from bus routes
      busRoutes.makePairs();
      text("Starting to sort bus routes at each stop at " + millis() + " milliseconds", width / 2, height / 2);
      loadStep = 3;
      break;

    case 3: //sort bus routes
      busStops.sortRoutes();
      text("All data loaded by " + millis() + " milliseconds", width / 2, height / 2);
      loadStep = 4;
      selectedStop = busStops.getCode(47546);
      drawPanel.value = true;
      break;

    default:
      break;
  }

  if (loadStep == 4) { //only do the real thing if it's all loaded
  
    //draw the bus routes - either everything or ones for the selected stop
    if (drawRoutes.value) {
      if (selectedStop == null) {
  //      stopPairs.draw(); //too much for a browser today to draw all the red lines
      }
      else {
        selectedStop.drawRoutes();
      }
    }
    
    //draw points for the stops
    busStops.draw(); //the toggle occurs inside the function
    
    //draw labels when you mouse over
    if (drawLabels.value) {
      stopLabels.draw();
    }
    
    //draw details of the stop you last clicked on
    if (drawPanel.value) {
      if (selectedStop != null) {
        selectedStop.drawDetails();
      }
    }
  }
}

void mouseClicked() {
  //only select a stop in the right circumstances
  if (!drawPanel.value || drawPanel.value || selectedStop == null) {
      chooseStop = true;
      chosenStop = false;
  }
}

void mouseDragged() {
  if (!drawPanel.value || drawPanel.value || selectedStop == null) {
    //move the map around
    centreOS.x -= (mouseX - pmouseX) / zoomFactor.value;
    centreOS.y -= (mouseY - pmouseY) / zoomFactor.value;
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
}

void keyPressed() {
  if (key == '-') { //zoom out
    zoomFactor.value /= 1.03;
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
  if (key == '=') { //zoom in
    zoomFactor.value *= 1.03;
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
  
  if (key == ' ') { //space = reset
    zoomFactor.reset();
    centreOS.x = defaultCentreOS.x;
    centreOS.y = defaultCentreOS.y;
    selectedStop = null;
    drawStops.reset();
    drawLabels.reset();
    drawRoutes.reset();
    drawPanel.reset();
    scaleRouteOpacity.reset();
    scaleRouteWeight.reset();
    backgroundColour.reset();
    stopColour.reset();
    routeColour.reset();
    for (int i = 0; i < routeColours.size(); i++) {
      routeColours.get(i).reset();
    }
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
}
class busRoute {
  String routeNumber; //some are non-numeric, eg. D6
  ArrayList<busStop> outwardLeg;
  ArrayList<busStop> returnLeg;
  
  busRoute(String rN) {
    routeNumber = rN;
    outwardLeg = new ArrayList<busStop>();
    returnLeg = new ArrayList<busStop>();
  }
}

class busRouteList {
  private ArrayList<busRoute> routes;
  
  //load the data file into routes
  busRouteList(String filePath) {
    //load the data file
    String[] routeFile = loadStrings(filePath);
//    println("Loaded bus routes by " + millis() + " milliseconds");
    
    //create new container
    routes = new ArrayList<busRoute>();
    
    //go through data line by line
    for (int i = 1; i < routeFile.length; i++) {
      String[] routeData = split(routeFile[i], ",");
      
      //only bother if it's a valid line
      if (routeData.length > 5) {
        String routeNumber = trim(routeData[0]);
        
        boolean outwardLeg = true;
        if ((int(trim(routeData[1])) % 2) == 0) {
          outwardLeg = false;
        }
        
        //get the stop and check it's real
        String stopLBSL = trim(routeData[3]);
        busStop thisStop = busStops.get(stopLBSL);
        if (thisStop != null) {
          //add it to the route!
          busRoute thisRoute = this.get(routeNumber);
          
          //add a new bus route if it doesn't already exist
          if (thisRoute == null) {
            thisRoute = new busRoute(routeNumber);
            routes.add(thisRoute);
          }
          
          ArrayList<busStop> thisLeg;
          int legNumber;
          //work out which leg it's for
          if (outwardLeg) {
            thisLeg = thisRoute.outwardLeg;
            legNumber = 1;
          }
          else {
            thisLeg = thisRoute.returnLeg;
            legNumber = 2;
          }
          
          //add the stop to this route of the leg
          thisLeg.add(thisStop);
          
          //add route/leg to the stop
          stopRoute thisStopRoute = thisStop.getStopRoute(routeNumber);
          if (thisStopRoute == null) {
            //make a new one
            thisStopRoute = new stopRoute(thisRoute, outwardLeg, !outwardLeg);
            thisStop.routes.add(thisStopRoute);
          }
          else {
            //it's already there, just flag that they stop both ways
            thisStopRoute.outwardLeg = true;
            thisStopRoute.returnLeg = true;
          }
        }
      }
    }
//    println("Processed bus routes by " + millis() + " milliseconds");
  }
  
  int size() {
    return routes.size();
  }
  
  //how many stops on a route?
  int totalStops() {
    int count = 0;
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      count += thisRoute.outwardLeg.size();
      count += thisRoute.returnLeg.size();
    }
    return count;
  }
  
  //lookup by number
  busRoute get(String routeNumber) {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      if (thisRoute.routeNumber.equals(routeNumber)) {
        return thisRoute;
      }
    }
    return null;
  }
  
  //
  ArrayList<busStop> getStops(String routeNumber, boolean outward) {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      if (thisRoute.routeNumber.equals(routeNumber)) {
        if (outward) {
          return thisRoute.outwardLeg;
        }
        else {
          return thisRoute.returnLeg;
        }
      }
    }
    return null;
  }
  
  //this is the time-consuming bit -> looking up to see if this pair already exists
  void makePairs() {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      for (int j = 0; j < thisRoute.outwardLeg.size() - 1; j++) {
        busStop firstStop = (busStop)thisRoute.outwardLeg.get(j);
        busStop secondStop = (busStop)thisRoute.outwardLeg.get(j + 1);
        
        stopPair thisPair = stopPairs.getLocation(firstStop.easting, firstStop.northing, secondStop.easting, secondStop.northing);
        if (thisPair == null) {
          thisPair = new stopPair(firstStop, secondStop);
          stopPairs.add(thisPair);
        }
        else {
          thisPair.busCount++;
          if (thisPair.busCount > stopPairs.busiest) {
            stopPairs.busiest = thisPair.busCount;
          }
        }
      }
      for (int j = 0; j < thisRoute.returnLeg.size() - 1; j++) {
        busStop firstStop = (busStop)thisRoute.returnLeg.get(j);
        busStop secondStop = (busStop)thisRoute.returnLeg.get(j + 1);
        
        stopPair thisPair = stopPairs.getLocation(firstStop.easting, firstStop.northing, secondStop.easting, secondStop.northing);
        if (thisPair == null) {
          thisPair = new stopPair(firstStop, secondStop);
          stopPairs.add(thisPair);
        }
        else {
          thisPair.busCount++;
          if (thisPair.busCount > stopPairs.busiest) {
            stopPairs.busiest = thisPair.busCount;
          }
        }
      }
    }
    stopPairs.updateScales();
    stopPairs.updateScreen();
//    println("Made bus stop pairs by " + millis() + " milliseconds");
  }
}

class stopRoute implements Comparable {
  busRoute route;
  boolean outwardLeg = false;
  boolean returnLeg = false;
  
  stopRoute(busRoute r, boolean out, boolean rtn) {
    route = r;
    if (out) {
      outwardLeg = true;
    }
    if (rtn) {
      returnLeg = true;
    }
  }
  
  int compareTo(Object s) {
    stopRoute sR = (stopRoute)s;
    
    String route1 = this.route.routeNumber;
    int iRoute1 = int(route1);
    String route2 = sR.route.routeNumber;
    int iRoute2 = int(route2);
    
    //case 1: a is non-numeric, b is numeric -> b comes first
    if ((iRoute1 == 0) && (iRoute2 != 0)) {
      return 1;
    }
    //case 2: a is numeric, b is non-numeric -> a comes first
    if ((iRoute1 != 0) && (iRoute2 == 0)) {
      return -1;
    }
    //case 3: both are numeric -> lowered number comes first
    if ((iRoute1 != 0) && (iRoute2 != 0)) {
      return iRoute1 - iRoute2;
    }
    //case 4: neither is numeric -> sort as strings
    return route1.compareTo(route2);
  }
}
class busStop {
  String lbsl; //unique ID, key field
  int code; //5 digit for texting the bus tracker
  String name; //what's it called?
  int easting; //OS Grid map
  int northing; //OS Grid map
  int heading; //which direction it faces?
  String stopArea; //from the data, unknown use
  boolean virtual; //is it a virtual bus stop. if yes, remove it!

  PVector screen; //where on the screen to draw it?
  boolean onScreen;
  PVector normal; //what direction is perpendicular to the average line going through this stop? (unit length)
  float scale; //how big to draw it?
  int busCount; //how many routes go here?  
  stopLabel label;
  ArrayList<stopRoute> routes; //which routes stop here? which legs?
  ArrayList<stopPairRoute> routePairs; //which pairs of stops stop here?

  //interchanges
  boolean tube = false;
  boolean train = false;
  boolean dlr = false;
  boolean tram = false;
  boolean river = false;

  busStop(String[] stopData) {
    //process the data from the file
    this.lbsl = trim(stopData[0]);
    this.code = int(trim(stopData[1]));
    int eastingStart = 4;

    //name - get the basic info into one string
    if (trim(stopData[3].charAt(0)) != "\"") {
      this.name = stopData[3];
    }
    else {
      String nameString = stopData[3];
      while (eastingStart < (stopData.length - 5)) {
        nameString = nameString + ", " + trim(stopData[eastingStart]); //restore original comma 
        eastingStart = eastingStart + 1;
      }
      this.name = nameString;
    }

    //see if it has connections!
    if (this.name.indexOf("<>") != -1) {
      this.tube = true;
      this.name = this.name.replace("<>", "");
    }
    if (this.name.indexOf("#") != -1) {
      this.train = true;
      this.name = this.name.replace("#", "");
    }
    if (this.name.indexOf("[DLR]") != -1) {
      this.dlr = true;
      this.name = this.name.replace("[DLR]", "");
    }
    if (this.name.indexOf("(DLR)") != -1) {
      this.dlr = true;
      this.name = this.name.replace("(DLR)", "");
    }
    if (this.name.indexOf(">T<") != -1) {
      this.tram = true;
      this.name = this.name.replace(">T<", "");
    }
    if (this.name.indexOf("<T>") != -1) {
      this.tram = true;
      this.name = this.name.replace("<T>", "");
    }
    if (this.name.indexOf(">R<") != -1) {
      this.river = true;
      this.name = this.name.replace(">R<", "");
    }
    if (this.name.indexOf("<R>") != -1) {
      this.river = true;
      this.name = this.name.replace("<R>", "");
    }

    //tidy up the name 
    while (this.name.indexOf ("  ") != -1) { //get rid of double spaces
      this.name = this.name.replace("  ", " ");
    }
    this.name = this.name.replace("\"", ""); //get rid of speech marks
    this.name = titleCase(this.name);
    
    //remove the superfluous commas from the name
    String newName = "";
    for (int i = 0; i < this.name.length; i+=2) {
      newName = newName + this.name[i];
    }
    this.name = newName;

    this.easting = int(trim(stopData[eastingStart]));
    this.northing = int(trim(stopData[eastingStart + 1]));
    this.heading = int(trim(stopData[eastingStart + 2]));
    this.stopArea = trim(stopData[eastingStart + 3]);

    //virtual bus stops are used to give the route waypoints but there's not an actual stop there
    if (trim(stopData[eastingStart + 4]).equals("1")) {
      this.virtual = true;
    }
    else {
      this.virtual = false;
    }

    //work out starting place to draw it
    this.screen = screenCoordinates(easting, northing);
    this.onScreen = isOnScreen(this.screen);

    //container to store routes
    routes = new ArrayList<stopRoute>();
  }

  // adds a pop out label to the list
  void addLabel() {
    if (label == null) { //if it doesn't already have a label, see if there's one with the same name
      stopLabel findLabel = stopLabels.find(this.name);
      if (findLabel == null) { //if not, make one
        new stopLabel(this);
      }
      else { //if yes, make it exist longer
        findLabel.creationTime = millis();
      }
    }
    else { //renewed lease of life for existing label
      label.creationTime = millis();
    }
  }

  //makes life easier for drawing -> compiles together a list of the routes, which is helpful for getting colours
  ArrayList<busRoute> getRoutes() {
    ArrayList<busRoute> routeList = new ArrayList<busRoute>(); 
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      routeList.add(thisStopRoute.route);
    }
    return routeList;
  }

  //which combo of leg of this route is this stop on?
  stopRoute getStopRoute(String routeNumber) {
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      if (thisStopRoute.route.routeNumber.equals(routeNumber)) {
        return thisStopRoute;
      }
    }
    return null;
  }

  //draw the popup panel with details of the bus stop and its route
  void drawDetails() {
    //set up a bit at the bottom of the screen
    fill(0);
    noStroke();
    rect(0, height - 100, width, 100);
    stroke(255);
    strokeWeight(1);
    line(0, height - 100, width, height - 100);

    //stop name
    fill(255);
    textAlign(LEFT);
    text(this.name, 12, height - 80);

    //symbols for interchanges
    float startX = 12 + textWidth(this.name) + 4;
    float startY = height - 90;
    noStroke();
    if (this.tube) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(tubeLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.train) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(trainLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.dlr) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(dlrLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.river) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(riverLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.tram) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(tramLogo, startX, startY, 16, 12);
      startX += 18;
    }

    //show the stop code
    if (this.code > 0) {
      textAlign(RIGHT);
      text(this.code, width - 12, height - 80);
    }

    //boxes for routes -> up to 24 of the buggers
    int widthDiff = 12;
    int heightDiff = 72;
    int boxRow = floor(width - widthDiff) / 48;
    
    for (int i = 0; i < routes.size(); i++) {
      if (i == boxRow) {
        widthDiff = 12;
        heightDiff -= 36;
      }
      //box for the route number
      fill(routeColours.get(i).value);
      noStroke();
      rect(widthDiff, height - heightDiff, 40, 30);

      //route number in the box
      fill(0);
      stopRoute thisStopRoute = (stopRoute)routes.get(i);

      textAlign(CENTER);
      int boxLeft = widthDiff;
      int boxRight = widthDiff + 40;
      text(thisStopRoute.route.routeNumber, (boxLeft + boxRight) / 2.0, height - heightDiff + 20);

      widthDiff += 48;
    }
  }

  //draw the lines stopping at this stop
  void drawRoutes() {
    //safety first - check we have routes and if not, get them
    if (routePairs == null) {
      getRoutePairs();
    }

    //now draw the lines!
    strokeWeight(2); // leaves a gap between lines for clarity!
    ArrayList<busRoute> routeList = getRoutes(); //need a list of the routes in order so we can get the colours right
    for (int i = 0; i < routePairs.size(); i++) {
      stopPairRoute thisPairRoute = (stopPairRoute)routePairs.get(i);
      stopPair thisPair = thisPairRoute.pair;

      for (int j = 0; j < thisPairRoute.routes.size(); j++) {
        //colour each line according to the route
        busRoute thisRoute = (busRoute)thisPairRoute.routes.get(j);
        int colourNumber = routeList.indexOf(thisRoute); 
        stroke(routeColours.get(colourNumber).value);

        //if either stop is on screen, work out the correct offset for this route at each stop, and join them up
        if (thisPair.firstStop.onScreen || thisPair.secondStop.onScreen) {
          PVector firstScreen = routeScreen(thisPair.firstStop, thisRoute);
          PVector secondScreen = routeScreen(thisPair.secondStop, thisRoute);
          line(firstScreen.x, firstScreen.y, secondScreen.x, secondScreen.y);
        }
      }
    }
  }

  //when drawing multiple routes, need to offset them from where we draw the stop itself, so you can see them going in parallel
  PVector routeScreen(busStop thatStop, busRoute thisRoute) {
    ArrayList sharedRoutes = this.commonRoutes(thatStop);
    int routeIndex = sharedRoutes.indexOf(thisRoute);

    PVector stopNormal = thatStop.normal;
    if (stopNormal == null) {
      thatStop.getNormal();
      stopNormal = thatStop.normal;
    }

    float offsetCount = routeIndex - ((sharedRoutes.size() - 1) / 2.0);
    float xOffset = 3 * offsetCount * stopNormal.x;
    float yOffset = 3 * offsetCount * stopNormal.y;

    return new PVector(thatStop.screen.x - xOffset, thatStop.screen.y - yOffset);
  }

  //work out which line is perpendicular to the average line through the stop
  void getNormal() {
    float dx = 0;
    float dy = 0;
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      if (thisStopRoute.outwardLeg) {
        PVector legResult = getNormalLeg(thisStopRoute, true);
        dx += legResult.x;
        dy += legResult.y;
      }
      if (thisStopRoute.returnLeg) {
        PVector legResult = getNormalLeg(thisStopRoute, false);
        dx += legResult.x;
        dy += legResult.y;
      }
    }
    normal = new PVector(-dy, dx);
    normal.normalize();
  }

  //use to save duplication in getNormal() - where we have two legs
  PVector getNormalLeg(stopRoute s, boolean outwardLeg) {
    ArrayList<busStop> stopList;
    if (outwardLeg) {
      stopList = s.route.outwardLeg;
    }
    else {
      stopList = s.route.returnLeg;
    }

    float dx = 0;
    float dy = 0;
    for (int j = 0; j < stopList.size(); j++) {
      busStop thatStop = (busStop)stopList.get(j);
      if (thatStop == this) {
        busStop otherStop;
        if (j > 0) {
          otherStop = (busStop)stopList.get(j - 1);
          dx += (thatStop.screen.x - otherStop.screen.x);
          dy += (thatStop.screen.y - otherStop.screen.y);
        }
        if (j < stopList.size() - 1) {
          otherStop = (busStop)stopList.get(j + 1);
          dx += (otherStop.screen.x - thatStop.screen.x);
          dy += (otherStop.screen.y - thatStop.screen.y);
        }
      }
    }

    return new PVector(dx, dy);
  } 

  //work out which pairs of stops are on the routes that stop here
  void getRoutePairs() {
    routePairs = new ArrayList<stopPairRoute>(); //combo of pair + routes

    //for each route
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      busRoute thisRoute = thisStopRoute.route;

      //get the right legs!
      if (thisStopRoute.outwardLeg) {
        extractPairs(thisStopRoute.route.outwardLeg, thisRoute);
      }
      if (thisStopRoute.returnLeg) {
        extractPairs(thisStopRoute.route.returnLeg, thisRoute);
      }
    }
  }

  //extract pairs from a particular leg of a journey and add to routePiars
  private void extractPairs(ArrayList<busStop> stops, busRoute thisRoute) {
    //for each stop on the outward leg (except the last one)
    for (int j = 0; j < stops.size() - 1; j++) {
      busStop firstStop = (busStop)stops.get(j);
      busStop secondStop = (busStop)stops.get(j + 1);
      stopPair thisPair = new stopPair(firstStop, secondStop);

      //does it exist already?
      stopPairRoute thisStopPairRoute = null;
      for (int k = 0; k < routePairs.size(); k++) {
        stopPairRoute resultPair = (stopPairRoute)routePairs.get(k);
        if (resultPair.pair.equals(thisPair)) {
          thisStopPairRoute = resultPair;
          break;
        }
      }

      //if it exists, add this route to its routes
      if (thisStopPairRoute != null) {
        //only add it if we don't already have it
        if (!thisStopPairRoute.routes.contains(thisRoute)) {
          thisStopPairRoute.routes.add(thisRoute);
        }
      }
      else {
        thisStopPairRoute = new stopPairRoute(thisPair, thisRoute);
        routePairs.add(thisStopPairRoute);
      }
    }
  }

  //which routes do this stop and that stop have in common?
  ArrayList<busRoute> commonRoutes(busStop thatStop) {
    ArrayList<busRoute> results = new ArrayList<busRoute>();
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      busRoute thisRoute = thisStopRoute.route;
      for (int j = 0; j < thatStop.routes.size(); j++) {
        stopRoute thatStopRoute = (stopRoute)thatStop.routes.get(j);
        busRoute thatRoute = thatStopRoute.route;
        if (thisRoute == thatRoute) {
          results.add(thisRoute);
          break;
        }
      }
    }
    return results;
  }
}

//container for bus stops, unsurprisingly
class busStopList {
  private HashMap<String, busStop> stops;
  int busiest; //track which is the busiest station

  //create a list of stops from a data file
  busStopList(String filePath) {
    //load the data file
    String[] stopFile = loadStrings(filePath);
//    println("Loaded bus stops by " + millis() + " milliseconds");

    //set up the parameters
    busiest = 0;
    stops = new HashMap<String, busStop>();

    //process the info, line by line
    for (int i = 1; i < stopFile.length; i++) {
      String[] stopData = split(stopFile[i], ',');
      if (stopData.length >= 8) {
        busStop thisStop = new busStop(stopData);
        if ((thisStop.northing != 0) && (thisStop.northing != 999999)) {
          stops.put(thisStop.lbsl, thisStop);
        }
      }
    }
//    println("Processed bus stops by " + millis() + " milliseconds");
  }

  //work out where each stop should be on the screen - ie. when zoomed/panned
  void updateScreen() {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
        thisStop.screen = screenCoordinates(thisStop.easting, thisStop.northing);
        thisStop.onScreen = isOnScreen(thisStop.screen);
      }
    }
  }

  //how many bus stops in the list?
  int size() {
    return stops.size();
  }

  //give us a bus stop from the list
  busStop get(String lsbl) {
    return (busStop)stops.get(lsbl);
  }

  //look up a bus stop by 5 digit bustracker code
  busStop getCode(int code) {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
        if (thisStop.code == code) {
          return thisStop;
        }
      }
    }
    return null;
  }

  //sort the routes at each stop into order
  void sortRoutes() {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
//        Collections.sort(thisStop.routes);
      }
    }
//    println("Sorted bus routes at each stop by " + millis() + " milliseconds");
  }

  //draw a point for each stop
  void draw() {
    noFill();
    if (selectedStop == null) {
      strokeWeight(2);
      stroke(stopColour.value);
    }

    //handle mouse movements
    ArrayList<busStop> selectionCandidates = new ArrayList<busStop>();
    strokeWeight(2);
    stroke(stopColour.value);
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null && !thisStop.virtual && thisStop.onScreen) {
        //normal stops in normal colour
        if (drawStops.value) {
          point(thisStop.screen.x, thisStop.screen.y);
        }
        //if the mouse is near stations, make a force-directed label
        if (!drawControlPanel.value) {
          if ((abs(thisStop.screen.x - mouseX) <= labelMouseRange.value) && (abs(thisStop.screen.y - mouseY) <= labelMouseRange.value)) {
            if (chooseStop) {
              selectionCandidates.add(thisStop); //don't just pick any stop - get the nearest one
            }
            else {
              thisStop.addLabel(); //add/update the label
            }
          }
        }
      }
    }

    //there may be several stops in range, so work out which is the nearest and select that one
    if (chooseStop) {
      float minDistance = 999999;
      PVector mousePos = new PVector(mouseX, mouseY);
      for (int j = 0; j < selectionCandidates.size(); j++) {
        busStop thisStop = (busStop)selectionCandidates.get(j);  
        float thisDistance = thisStop.screen.dist(mousePos);
        if (thisDistance < minDistance) {
          chosenStop = true;
          minDistance = thisDistance;
          selectedStop = thisStop;
        }
      }
      //will need the list of routes for drawing
      if (selectedStop != null) {
        if (selectedStop.routePairs == null) {
          selectedStop.getRoutePairs(); //so we can draw them!
        }
      }
      updateScreen();
    }

    //didn't find anything, so go back to overview mode
    if (chooseStop && !chosenStop) {
      if ((selectedStop != null) && (selectedStop.routePairs != null)) {
        selectedStop.routePairs = null;
      }
      //make sure we never run out of memory
      for (int j = 0; j < stops.size(); j++) {
        busStop thisStop = (busStop)stops.get(j);
        if (thisStop != null) {
          if (thisStop.normal != null) {
            thisStop.normal = null;
          }
        }
      }
      selectedStop = null;
      updateScreen();
    }
    chooseStop = false;
  }
}

//map from OS Grid references to screen coordinates
PVector screenCoordinates(float easting, float northing) {
  PVector screenLocation = new PVector();
  //i checked this. now just use it.
  screenLocation.x = (width / 2.0) + ((easting - centreOS.x) * zoomFactor.value);
  screenLocation.y = (height / 2.0) + (((999999 - northing) - centreOS.y) * zoomFactor.value);
  return screenLocation;
}

//test if a location is on screen
boolean isOnScreen(PVector screenLocation) {
  if ((screenLocation.x < 0) || (screenLocation.x > width) || (screenLocation.y < 0) || (screenLocation.y > height)) {
    return false;
  }
  if (drawPanel.value && (selectedStop != null)) {
    if (screenLocation.y > height - 100) {
      return false;
    }
  }
  return true;
}

//for drawing lines - is the line on screen? ie. is 
boolean isLineOnScreen(PVector location1, PVector location2) {
  if ((location1.x > 0) && (location1.x < width) && (location2.x > 0) && (location2.x < width)) {
    //if both are above/below the screen in the same direction, it's not on screen. otherwise, it cuts across or is in the middle
    if (((location1.y < 0) && (location2.y < 0)) || ((location1.y > height) && (location2.y > height))) {
      return false;
    }
    else {
      return true;
    }
  }
  if ((location1.y > 0) && (location1.y < height) && (location2.y > 0) && (location2.y < height)) {
    //if both are left or right of the screen in the same direction, it's not on screen. otherwise, it cuts across or is in the middle
    if (((location1.x < 0) && (location2.x < 0)) || ((location1.x > width) && (location2.x > width))) {
      return false;
    }
    else {
      return true;
    }
  }
  return false;
}
//force directed label for each station
class stopLabel {
  String tooltip; //text it contains
  float tooltipWidth; //how wide is the text?
  busStop stop; //which stop is it for?
  PVector screen; //where is the centre of it on the screen?
  PVector velocity; //how fast is it moving
  int creationTime; //when was it added to the map?
  PVector topLeft; //where does the box start??
  
  stopLabel(busStop thisStop) {
    tooltip = thisStop.name;
    tooltipWidth = textWidth(tooltip);
    stop = thisStop;
    //make space for logos if we're having them
    if (stop.tube) {
      tooltipWidth += 18;
    }
    if (stop.train) {
      tooltipWidth += 18;
    }
    if (stop.dlr) {
      tooltipWidth += 18;
    }
    if (stop.tram) {
      tooltipWidth += 18;
    }
    if (stop.river) {
      tooltipWidth += 18;
    }
    if (stop.tube || stop.train || stop.dlr || stop.tram || stop.river) {
      tooltipWidth -= 1;
    }
    creationTime = millis();
    velocity = new PVector();
    
    //put it a certain distance in the direction of the mouse
    float angle = random(0, 2*PI);
    PVector direction = new PVector(50 * sin(angle), 50 * cos(angle));
    screen = PVector.add(stop.screen, direction);
    topLeft = new PVector(screen.x - (tooltipWidth / 2) - 4, screen.y - 12);
    
    stopLabels.add(this);
  }
  
  //repel itself from other locations
  void repel(PVector otherLocation) {
    float d = PVector.dist(screen, otherLocation); //distance to the other one
    float radius = tooltipWidth; //limit on how far the force reaches
    float strength = -1; //tweakable
    float ramp = 0.4; //tweakable
    if (d > 0 && d < radius) { //if in range
      float s = pow(d / radius, 1 / ramp); //no idea how this works -> got it from the Generative Design book
      float f = s * 9 * strength * (1 / (s + 1) + ((s - 3) / 4)) / d;
      PVector df = PVector.sub(screen, otherLocation);
      df.mult(f);
      
      velocity.x -= df.x;
      velocity.y -= df.y;
    }
  }
  
  //is this label overlapping/overlapped by another one?
  boolean overlapping(stopLabel otherLabel) {
    float longestWidth = max(tooltipWidth, otherLabel.tooltipWidth);
      if (abs(topLeft.x - otherLabel.topLeft.x) < (longestWidth + 8)) {
        if (abs(topLeft.y - otherLabel.topLeft.y) < 17) {
          return true; //yes, if top left corners of each are too close
        }
      }
    return false;
  }
  
  //make it force-directed - this is the magic
  void update() {
    //remove if it's too old
    int timeNow = millis();
    if ((timeNow - creationTime) > 1000) {
      stop.label = null;
      stopLabels.remove(this);
    }
    
    //repel all other nodes
    boolean foundOverlap = false;
    for (int i = 0; i < stopLabels.size(); i++) {
      stopLabel otherLabel = stopLabels.get(i);
      if (otherLabel == null) { //can't repel a blank label
        break;
      }
      if (otherLabel == this) { //can't repel yourself
        continue;
      }
      repel(otherLabel.screen); //repel other labels in range
      repel(stop.screen); //also repel the station -> stretches the label line so it's not blocking the other lines
      
      if (!foundOverlap) { //keep checking if you're overlapping someone until you are, or you run out of ones to check
        if (overlapping(otherLabel)) {
          foundOverlap = true;
        }
      }
    }
    
    //if it's not overlapping anyone, then you can just stop moving around
    if (!foundOverlap) {
      if (PVector.dist(getNearestCorner(), stop.screen) > 35) { //so long as the nearest corner is far enough from the station -> wasn't accurate enough when working off the centre point
        velocity = new PVector(0, 0); //STOP!
      }
    }
    
    screen.add(velocity); //get new location!
    
    //stay in the limits of the window
    if ((screen.x - (tooltipWidth / 2) - 4) < 0) {
      screen.x = (tooltipWidth / 2) + 5;
      velocity.x *= -0.5; //bounce off the walls
    }
    if ((screen.x + (tooltipWidth / 2) + 4) > width) {
      screen.x = width - (tooltipWidth / 2) - 5;
      velocity.x *= -0.5;
    }
    if ((screen.y - 12) < 0) {
      screen.y = 13;
      velocity.y *= -0.5;
    }
    int bottomLimit = height;
    if (drawPanel.value && (selectedStop != null)) {
      bottomLimit = height - 100;
    }
    
    if ((screen.y + 12) > bottomLimit) {
      screen.y = bottomLimit - 13;
      velocity.y *= -0.5;
    }
    topLeft = new PVector(screen.x - (tooltipWidth / 2) - 4, screen.y - 12); //update top left position
  }
  
  //get the location of the corner of the label box nearest to the station itself 
  PVector getNearestCorner() {
    PVector nearestCorner = new PVector();
    float lowestDistance = 999999;
    float width = tooltipWidth + 8;
    float height = 17;
    //these are the possibilities!
    PVector[] corners = {new PVector(topLeft.x, topLeft.y), new PVector(topLeft.x + width, topLeft.y), new PVector(topLeft.x, topLeft.y + height), new PVector(topLeft.x + width, topLeft.y + height)};
    //test each for length, return the the lowest one
    for (int i = 0; i < corners.length; i++) {
      float distance = PVector.dist(corners[i], stop.screen);
      if (distance < lowestDistance) {
        lowestDistance = distance;
        nearestCorner = corners[i];
      }
    } 
    return nearestCorner;
  }
}

class stopLabelList {
  private ArrayList<stopLabel> labels;
  
  stopLabelList(int capacity) {
    labels = new ArrayList<stopLabel>();
  }
  
  stopLabelList() {
    labels = new ArrayList<stopLabel>();
  }
  
  //have to pass on some of the arraylist methods to the array list
  void add(stopLabel label) {
    labels.add(label);
  }
  
  stopLabel find(String name) {
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      if (thisLabel.tooltip.equals(name)) {
        return thisLabel;
      }
    }
    return null;
  }
  
  void remove(stopLabel label) {
    labels.remove(label);
  }
  
  int size() {
    return labels.size();
  }
  
  stopLabel get(int i) {
    return (stopLabel)labels.get(i);
  }
  
  //now some of the interesting methods
  void draw() {
    //draw the lines to the labels first, so they're at the back
    textAlign(LEFT);
    strokeWeight(labelWeight.value);
    stroke(255);
    fill(255);
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      line(thisLabel.screen.x, thisLabel.screen.y, thisLabel.stop.screen.x, thisLabel.stop.screen.y);
    }
    //draw the labels themselves
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      fill(0);
      stroke(255);
      rect(thisLabel.screen.x - (thisLabel.tooltipWidth / 2) - 4, thisLabel.screen.y - 12, thisLabel.tooltipWidth + 8, 17);
      fill(255);
      text(thisLabel.tooltip, thisLabel.screen.x - (thisLabel.tooltipWidth / 2.0), thisLabel.screen.y);
      
      //draw the logos
      float logoStart = textWidth(thisLabel.tooltip) + thisLabel.screen.x - (thisLabel.tooltipWidth / 2.0) + 3;
      noStroke();
      if (thisLabel.stop.tube) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(tubeLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.train) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(trainLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.dlr) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(dlrLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.tram) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(tramLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.river) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(riverLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      
      thisLabel.update();
    }
  }
}

String titleCase(String input) {
  input = input.toLowerCase().replace("\"", "");
  char[] charArray = input.toCharArray();
  for (int i = 0; i < charArray.length - 1; i++) {
    charArray[0] = str(charArray[0]).toUpperCase().charAt(0);
    if ((charArray[i] == ' ') || (charArray[i] == '(') || (charArray[i] == '-')) { //it's a space!
      charArray[i + 1] = str(charArray[i + 1]).toUpperCase().charAt(0);
    }
  }
  
  return new String(charArray);
}
class stopPair {
  busStop firstStop;
  busStop secondStop;
  int busCount;
  float opacity;
  float weight; 
//  busRoute route; //link back to the route you're on
  boolean onScreen;
  
  stopPair(busStop s1, busStop s2) {
    //further west comes first
    if (s1.easting < s2.easting) {
      firstStop = s1;
      secondStop = s2;
    }
    else {
      firstStop = s2;
      secondStop = s1;
    }
    //if neither is further west, further south wins
    if (s1.easting == s2.easting) {
      if (s1.northing <= s2.northing) {
        firstStop = s1;
        secondStop = s2;
      }
      else {
        firstStop = s2;
        secondStop = s1;
      }
    }
    busCount = 1;
  }
  
  //will equal true if it's the same memory location. but it should be!
  boolean equals(stopPair otherPair) {
    if (((firstStop == otherPair.firstStop) && (secondStop == otherPair.secondStop)) || ((firstStop == otherPair.secondStop) && (secondStop == otherPair.firstStop))) {
      return true;
    }
    return false;
  }
}

class stopPairList {
  private ArrayList<stopPair> pairs;
  int busiest;
  
  stopPairList() {
    pairs = new ArrayList<stopPair>();
    busiest = 1;
  }
  
  void add(stopPair p) {
    pairs.add(p);
  }
  
  int size() {
    return pairs.size();
  }
  
  stopPair getCode(int code1, int code2) {
    int s1 = min(code1, code2); //always stored a certain way round
    int s2 = max(code1, code2);
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if ((thisPair.firstStop.code == s1) && (thisPair.secondStop.code == s2)) {
        return thisPair;
      }
    }
    return null;
  }
  
  stopPair getLBSL(String code1, String code2) {
    String s1;
    String s2;
    
    //store it with the lower code first
    if (code1.compareTo(code2) <= 0) {
      s1 = code1;
      s2 = code2;
    }
    else {
      s1 = code2;
      s2 = code1;
    }
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if ((thisPair.firstStop.lbsl.equals(s1)) && (thisPair.secondStop.lbsl.equals(s2))) {
        return thisPair;
      }
    }
    return null;
  }

  //identify if it's a matching pair by location -> stored with western first (and southern first in a tie-break)
  stopPair getLocation(int easting1, int northing1, int easting2, int northing2) {
    int western = min(easting1, easting2);
    int eastern = max(easting1, easting2);
    int southern = min(northing1, northing2);
    int northern = max(northing1, northing2);
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if (western == eastern) {
        if ((thisPair.firstStop.northing == southern) && (thisPair.secondStop.northing == northern)) {
          return thisPair;
        }
      }
      else {
        //easting1 and northing1 are the first stop
        if (western == easting1) {
          if ((thisPair.firstStop.northing == northing1) && (thisPair.secondStop.northing == northing2)) {
            return thisPair;
          }
        }
        else {
          if ((thisPair.firstStop.northing == northing2) && (thisPair.secondStop.northing == northing1)) {
            return thisPair;
          }
        }
      }
    }
    return null;
  }
 
  void updateScales() {
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      thisPair.opacity = map(thisPair.busCount, 0, busiest, minRouteOpacity.value, maxRouteOpacity.value);
      thisPair.weight = map(thisPair.busCount, 0, busiest, minRouteWeight.value, maxRouteWeight.value);
    }
  }
  
 void updateScreen() {
   for (int i = 0; i < pairs.size(); i++) {
     stopPair thisPair = (stopPair)pairs.get(i);
     thisPair.onScreen = isLineOnScreen(thisPair.firstStop.screen, thisPair.secondStop.screen);
   }
 }
 
 void draw() {
   noFill();
   strokeCap(ROUND);
   if (!scaleRouteWeight.value) {
     strokeWeight(1);
   }
   if (!scaleRouteOpacity.value) {
     stroke(routeColour.value);
   }
   for (int i = 0; i < pairs.size(); i++) {
     stopPair thisPair = (stopPair)pairs.get(i);
     if (thisPair.onScreen) {
       if (scaleRouteOpacity.value) {
         stroke(red(routeColour.value), green(routeColour.value), blue(routeColour.value), thisPair.opacity);
       }
       if (scaleRouteWeight.value) {
         strokeWeight(thisPair.weight);
       }
       line(thisPair.firstStop.screen.x, thisPair.firstStop.screen.y, thisPair.secondStop.screen.x, thisPair.secondStop.screen.y); 
     }
   }
 } 
}

class stopPairRoute {
  stopPair pair;
  ArrayList<busRoute> routes;
  
  stopPairRoute(stopPair p, busRoute r) {
    pair = p;
    routes = new ArrayList<busRoute>();
    routes.add(r);
  }
}
//wrapper for global controllable booleans so we can control with a control panel
class booleanHolder {
  boolean value;
  boolean defaultValue;
 
  booleanHolder(boolean v) {
    value = v;
    defaultValue = v;
  }
  
  booleanHolder(boolean v, boolean d) {
    value = v;
    defaultValue = d;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable ints so we can control with a control panel
class intHolder {
  int value;
  int defaultValue;
  int max;
  int min;
  
  intHolder(int v) {
    value = v;
    defaultValue = v;
    min = int(0.5 * v);
    max = int(1.5 * v);
  }
  
  intHolder(int v, int d) {
    value = v;
    defaultValue = d;
    min = int(0.5 * v);
    max = int(1.5 * v);
  }
  
  intHolder(int v, int mN, int mX, int d) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = d;
  }
  
  intHolder(int v, int mN, int mX) {
    value = v;
    min = mN;
    max = mX;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable floats so we can control with a control panel
class floatHolder {
  float value;
  float defaultValue;
  float min;
  float max;
  
  floatHolder(float v) {
    value = v;
    defaultValue = v;
    min = 0.5 * v;
    max = 1.5 * v;
  }
  
  floatHolder(float v, float d) {
    value = v;
    defaultValue = d;
    min = 0.5 * v;
    max = 1.5 * v;
  }
  
  floatHolder(float v, float mN, float mX, float d) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = d;
  }
  
  floatHolder(float v, float mN, float mX) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = v;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable floats so we can control with a control panel
class colourHolder {
  color value;
  color defaultValue;
  
  colourHolder(color v) {
    value = v;
    defaultValue = v;
  }
  
  colourHolder(color v, color d) {
    value = v;
    defaultValue = d;
  }
  
  void reset() {
    value = defaultValue;
  }
  
  color nonAlpha() {
    float r = red(value);
    float g = green(value);
    float b = blue(value);
    
    return color(r, g, b);
  }
}