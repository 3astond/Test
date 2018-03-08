/* @pjs preload="AGaramond-BoldOsF.otf","AGaramondPro-Regular.otf"; */

Swarm swarm;
float c = 12;

int r1 = 255;
int g1 = 255;
int b1 = 255;
int a1 = 255;

int r2 = 255;
int g2 = 0;
int b2 = 0;
int a2 = 255;

PFont AGaramondBoldOsF;
PFont AGaramondReg;

void setup() {
  fullScreen();
  //size (1280, 720);
  background(0);
  
  AGaramondBoldOsF = createFont("AGaramond-BoldOsF.otf", 24);
  AGaramondReg = createFont("AGaramondPro-Regular.otf", 24);
  
  swarm = new Swarm();
  frameRate(24);
  noCursor();
  for (int i = 0; i <1000; i++) {
    float startDist = random(0 ,75);
    Drone d = new Drone(width/2+startDist, height/2+startDist);
    swarm.addDrone(d);
  }
}

void draw() {
  background(0);
  swarm.run();
  frameCounter();
  timer();
  newCursor();
}

void mousePressed() {
  noCursor();
  loop();
}

void newCursor() {
  fill(r2, g2, b2, a2);
  noStroke();
  ellipse(mouseX, mouseY, c, c);
}

void frameCounter(){
  float fps = frameRate;
  int fpsR = round(fps);
  textSize(c);
  textAlign(LEFT);
  if (fpsR < 24) {
    fill(r2, g2, b2, a2);
  } else {
    fill (r1, g1, b1, a1);
  }
  text(fpsR, (c*2), height-c);
}

void timer() {
  textSize(c);
  textAlign(LEFT);
  float ts = millis()/1000;
  int tsR = floor(ts);
  float tm = tsR/60;
  int tmR = floor(tm);
  int tmM = tsR%60;
  fill (r1, g1, b1, a1);
  if (tsR < 60) {
    if (tsR < 10) {
      text("0"+tsR, (c*2), height-(c*2));
    } else {
    text(tsR, (c*2), height-(c*2));
    }
  }
  if ((tsR == 60) || (tsR > 60)) {
    if (tmM < 10) {
      text(tmR+": "+"0"+tmM, (c*2), height-(c*2));
    } else {
    text(tmR+": "+tmM, (c*2), height-(c*2));
    }
  }
}

class Drone {  
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxForce;
  float maxSpeed;

  String pubYear;
  String pubDef;
  String pubAuth;
  String source;

  float h = 12;
  float p = height/80;
  
  //Accent Scalar
  float aS = 1.5;
  float w;
  float leading = 1.5*aS*h;

  //Exit button scale
  float s = h/3;

  Boolean active;
  
  //Primary colour
  int r1 = 255;
  int g1 = 255;
  int b1 = 255;
  int a1 = 255;
  
  //Accent
  int r2 = 255;
  int g2 = 0;
  int b2 = 0;
  int a2 = 255;

  Drone(float x, float y) {
    acc = new PVector(0, 0);
    vel = new PVector(random(-30, 30), random(-30, 30));
    loc = new PVector(x, y);
    r = 5.0;
    maxSpeed = height/250;
    maxForce = 0.1;
  }

  void run(ArrayList<Drone> drones) {
    update();
    borders();
    render();
  }

  void applyForce (PVector force) {
    acc.add(force);
  }

  void swarm(ArrayList<Drone> drones) {
    PVector sep = separate(drones);
    PVector ali = align(drones);
    PVector coh = cohesion(drones);

    sep.mult(h*0.180);
    ali.mult(h*0.200);
    coh.mult(h*0.025);
    
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    loc.add(vel);
    acc.mult(0);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, loc);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxForce);
    return steer;
  }

  void render() {
    float theta = vel.heading() + radians(90);
    active = false;
    fill(r1, g1, b1, a1);
    textAlign(CENTER);
    textFont(AGaramondBoldOsF);
    textSize(h);
    text(pubYear, loc.x, loc.y);
    w = textWidth(pubYear);
    if (w > h) {
      if ((loc.x > 0) && (loc.x < width/2)) {
        if ((mouseX > loc.x-p) && (mouseX < loc.x+w+p)) {
          if ((mouseY < loc.y+p) && (mouseY > loc.y-h-p)) {
            textAlign(LEFT);
            textFont(AGaramondReg);
            textSize(h*aS);
            text(pubAuth, loc.x + w/2+h/2, loc.y);
            fill(r2, g2, b2, a2);
            text(pubDef, loc.x + w/2+h/2, loc.y+(leading));
            acc.mult(0);
            vel.mult(0);
          }
        }
      }
    }
    
    if (w > h) {
      if ((loc.x == width/2) || (loc.x > width/2)) {
        if ((mouseX > loc.x-p) && (mouseX < loc.x+w+p)) {
          if ((mouseY < loc.y+p) && (mouseY > loc.y-h-p)) {
            textAlign(RIGHT);
            textFont(AGaramondReg);
            textSize(h*aS);
            text(pubAuth, loc.x - w/2-h/2, loc.y);
            float pubAuthw = textWidth(pubAuth);
            fill(r2, g2, b2, a2);
            textAlign(LEFT);
            text(pubDef, loc.x-w/2-h/2 - pubAuthw, loc.y+(leading));
            acc.mult(0);
            vel.mult(0);
          }
        }
      }
    }

    if (w > h) {
      if ((mouseX > loc.x-p) && (mouseX < loc.x+w+p)) {
        if ((mouseY < loc.y+p) && (mouseY > loc.y-h-p)) {
          if (mousePressed) {
            active = true;
            link(source);
          }
        }
      }
    }


    if (active == true) {
      //sustainText();
      cursor();
      noLoop();
    }

    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    popMatrix();
  }

  void borders() {
    if (loc.x < -r) loc.x = width+r;
    if (loc.y < -r) loc.y = height+r;
    if (loc.x > width +r) loc.x = -r;
    if (loc.y > height +r) loc.y = -r;
  }
  
  PVector separate (ArrayList<Drone> drones) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (Drone other : drones) {
      float d = PVector.dist(loc, other.loc);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(vel);
      steer.limit(maxForce);
    }
    return steer;
  }

  PVector align (ArrayList<Drone> drones) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Drone other : drones) {
      float d = PVector.dist(loc, other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxSpeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  PVector cohesion (ArrayList<Drone> drones) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Drone other : drones) {
      float d = PVector.dist(loc, other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }
}

class Swarm {
  ArrayList<Drone> drones;
  
  Swarm() {
    drones = new ArrayList<Drone>();
  }
  
  void run() {

    for (Drone d: drones) {
      d.pubYear = "+";
      d.pubDef = " ";
      d.pubAuth = " ";
      d.source = " ";
    }
    
    Drone d1502 = drones.get(0);
    d1502.pubYear = "1502";
    d1502.pubDef = "Droon";
    d1502.pubAuth = "Elizabeth of York";
    d1502.source = "https://books.google.co.uk/books?num=8&id=ulkLAAAAYAAJ&q=droon#v=snippet&q=droon&f=false";
    
    Drone d1509 = drones.get(1);
    d1509.pubYear = "1509";
    d1509.pubDef = "Dranynge";
    d1509.pubAuth = "Alexander Barclay";
    d1509.source = "https://books.google.co.uk/books?num=8&id=B0VjAAAAcAAJ&q=dranynge#v=snippet&q=dranynge&f=false";
    
    Drone d1515 = drones.get(2);
    d1515.pubYear = "1515";
    d1515.pubDef = "Drone";
    d1515.pubAuth = "Alexander Barclay";
    d1515.source = "https://books.google.co.uk/books?num=8&id=lphTAAAAcAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1500a = drones.get(3);
    d1500a.pubYear = "c.1500–20a";
    d1500a.pubDef = "Drane";
    d1500a.pubAuth = "William Dunbar";
    d1500a.source = "https://books.google.co.uk/books?num=8&id=-qs8AAAAIAAJ&q=drane#v=snippet&q=drane&f=false";
    
    Drone d1500b = drones.get(4);
    d1500b.pubYear = "c.1500–20b";
    d1500b.pubDef = "Dronis";
    d1500b.pubAuth = "William Dunbar";
    d1500b.source = "https://books.google.co.uk/books?num=8&id=-qs8AAAAIAAJ&q=dronis#v=snippet&q=dronis&f=false";
    
    Drone d1530 = drones.get(5);
    d1530.pubYear = "1530";
    d1530.pubDef = "Drone";
    d1530.pubAuth = "Jean Palsgrave";
    d1530.source = "https://books.google.co.uk/books?num=8&id=HH8fAQAAMAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1549 = drones.get(6);
    d1549.pubYear = "1549";
    d1549.pubDef = "Drone";
    d1549.pubAuth = "John Leyden";
    d1549.source = "https://archive.org/stream/complayntofscotl00leyd#page/138/mode/2up/search/drone";
    
    Drone d1575 = drones.get(7);
    d1575.pubYear = "1575";
    d1575.pubDef = "Dronel";
    d1575.pubAuth = "Appius & Virginia";
    d1575.source = "https://archive.org/stream/fiveanonymouspla00farmuoft#page/40/mode/2up/search/dronel";
    
    Drone d1583 = drones.get(8);
    d1583.pubYear = "1583";
    d1583.pubDef = "Dronets";
    d1583.pubAuth = "Phillip Stubbes";
    d1583.source = "https://archive.org/stream/b24876422#page/n131/mode/2up/search/dronets";
    
    Drone d1592 = drones.get(9);
    d1592.pubYear = "1592";
    d1592.pubDef = "Drone";
    d1592.pubAuth = "John Lyly";
    d1592.source = "https://books.google.co.uk/books?num=20&id=FXZMAAAAcAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1596 = drones.get(10);
    d1596.pubYear = "1596";
    d1596.pubDef = "Drone";
    d1596.pubAuth = "William Shakespeare";
    d1596.source = "https://books.google.co.uk/books?num=8&id=MiI3AQAAMAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1599 = drones.get(11);
    d1599.pubYear = "1599";
    d1599.pubDef = "Droning";
    d1599.pubAuth = "Benjamin Johnson";
    d1599.source = "https://books.google.co.uk/books?num=20&id=7vxdAAAAcAAJ&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1601 = drones.get(12);
    d1601.pubYear = "1601";
    d1601.pubDef = "Droming";
    d1601.pubAuth = "John Marston";
    d1601.source = "https://archive.org/stream/schoolshakspere01furngoog#page/n152/mode/2up/search/droming";
    
    Drone d1614 = drones.get(13);
    d1614.pubYear = "1614";
    d1614.pubDef = "Droned";
    d1614.pubAuth = "Benjamin Johnson";
    d1614.source = "https://archive.org/stream/in.ernet.dli.2015.184506/2015.184506.The-Works-Of-Ben-Jonsonn-Volume-4#page/n369/mode/2up/search/droned";
    
    Drone d1623 = drones.get(14);
    d1623.pubYear = "1623";
    d1623.pubDef = "Drone";
    d1623.pubAuth = "Ælfricus Abbas & William L'isle";
    d1623.source = "https://books.google.co.uk/books?num=8&id=NO5DAQAAMAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1627 = drones.get(15);
    d1627.pubYear = "1627";
    d1627.pubDef = "Droane";
    d1627.pubAuth = "Michaell Drayton";
    d1627.source = "https://books.google.co.uk/books?num=8&id=NVxiAAAAcAAJ&q=droane#v=snippet&q=droane&f=false";
    
    Drone d1630 = drones.get(16);
    d1630.pubYear = "1630";
    d1630.pubDef = "Dronish";
    d1630.pubAuth = "John Taylor";
    d1630.source = "https://books.google.co.uk/books?num=8&id=3V7sKiXROowC&q=dronish#v=snippet&q=dronish&f=false";
    
    Drone d1641 = drones.get(17);
    d1641.pubYear = "1641";
    d1641.pubDef = "Drone";
    d1641.pubAuth = "John Milton";
    d1641.source = "https://archive.org/stream/miltonstheoryofp00lang#page/48/mode/2up/search/drone";

    Drone d1659 = drones.get(18);
    d1659.pubYear = "1659";
    d1659.pubDef = "Drone-pipe";
    d1659.pubAuth = "John Cleveland";
    d1659.source = "https://archive.org/stream/poemsofjohncleve00clevrich#page/62/mode/2up/search/drone-pipe";
    
    Drone d1663 = drones.get(19);
    d1663.pubYear = "1663";
    d1663.pubDef = "Drone";
    d1663.pubAuth = "Samuel Butler";
    d1663.source = "https://books.google.co.uk/books?num=8&id=GxsUAAAAQAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1680 = drones.get(20);
    d1680.pubYear = "1680";
    d1680.pubDef = "Droning";
    d1680.pubAuth = "John Dryden";
    d1680.source = "https://books.google.co.uk/books?num=8&id=rZW1AGFdA9YC&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1700 = drones.get(21);
    d1700.pubYear = "1700";
    d1700.pubDef = "Drones";
    d1700.pubAuth = "Thomas Evans";
    d1700.source = "";
    
    Drone d1704 = drones.get(22);
    d1704.pubYear = "1704";
    d1704.pubDef = "Droning";
    d1704.pubAuth = "Dean Swift";
    d1704.source = "https://books.google.co.uk/books?num=8&id=CJ_RAAAAMAAJ&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1711 = drones.get(23);
    d1711.pubYear = "1711";
    d1711.pubDef = "Drones";
    d1711.pubAuth = "John Gay";
    d1711.source = "https://books.google.co.uk/books?num=18&id=-tchAAAAMAAJ&q=drones#v=snippet&q=drones&f=false";
    
    Drone d1714 = drones.get(24);
    d1714.pubYear = "1714";
    d1714.pubDef = "Dronish";
    d1714.pubAuth = "Nicholas Rowe";
    d1714.source = "https://books.google.co.uk/books?num=8&id=kGIzAQAAMAAJ&q=dronish#v=snippet&q=dronish&f=false";
    
    Drone d1736 = drones.get(25);
    d1736.pubYear = "1736";
    d1736.pubDef = "Droan";
    d1736.pubAuth = "Thomas Otway";
    d1736.source = "https://books.google.co.uk/books?num=8&id=gZV0kaExMO0C&q=droan#v=snippet&q=droan&f=false";
    
    Drone d1739 = drones.get(26);
    d1739.pubYear = "1739";
    d1739.pubDef = "Drone";
    d1739.pubAuth = "John Wesley";
    d1739.source = "https://books.google.co.uk/books?num=8&id=gOReAAAAcAAJ&q=drone#v=snippet&q=drone&f=false";

    Drone d1750 = drones.get(27);
    d1750.pubYear = "1750";
    d1750.pubDef = "Droning";
    d1750.pubAuth = "Thomas Gay";
    d1750.source = "https://books.google.co.uk/books?num=8&id=rxRKAAAAcAAJ&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1751 = drones.get(28);
    d1751.pubYear = "1751";
    d1751.pubDef = "Drones";
    d1751.pubAuth = "Samuel Johnson";
    d1751.source = "https://books.google.co.uk/books?num=8&id=wK4mAQAAMAAJ&q=drones#v=snippet&q=drones&f=false";
    
    Drone d1753 = drones.get(29);
    d1753.pubYear = "1753";
    d1753.pubDef = "Dronishness";
    d1753.pubAuth = "John Mason";
    d1753.source = "https://books.google.co.uk/books?num=8&id=G6lIAAAAMAAJ&q=dronishness#v=snippet&q=dronishness&f=false";
    
    Drone d1755 = drones.get(30);
    d1755.pubYear = "1755";
    d1755.pubDef = "Drone";
    d1755.pubAuth = "Edward Young";
    d1755.source = "https://books.google.co.uk/books?num=8&id=3lVeAAAAcAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1774 = drones.get(31);
    d1774.pubYear = "1774";
    d1774.pubDef = "Drones";
    d1774.pubAuth = "Thomas Pennant";
    d1774.source = "https://books.google.co.uk/books?num=8&id=9D8IAAAAQAAJ&q=drones#v=snippet&q=drones&f=false";
    
    Drone d1777 = drones.get(32);
    d1777.pubYear = "1777";
    d1777.pubDef = "Drone";
    d1777.pubAuth = "Frances Burney";
    d1777.source = "https://archive.org/stream/earlydiaryoffran01burnuoft#page/204/mode/2up/search/drone";
    
    Drone d1781a = drones.get(33);
    d1781a.pubYear = "1781a";
    d1781a.pubDef = "Drone-pipe";
    d1781a.pubAuth = "William Cowper";
    d1781a.source = "https://books.google.co.uk/books?num=8&id=qBUlAAAAMAAJ&q=drone-pipe#v=snippet&q=drone-pipe&f=false";
    
    Drone d1781b = drones.get(34);
    d1781b.pubYear = "1781b";
    d1781b.pubDef = "Drony";
    d1781b.pubAuth = "Samuel Johnson";
    d1781b.source = "https://books.google.co.uk/books?num=8&id=QFprVtQoo5gC&q=drony#v=snippet&q=drony&f=false";
    
    Drone d1786a = drones.get(35);
    d1786a.pubYear = "1786a";
    d1786a.pubDef = "Drones";
    d1786a.pubAuth = "Robert Burns";
    d1786a.source = "https://books.google.co.uk/books?num=8&id=UCxYAAAAcAAJ&q=drones#v=snippet&q=drones&f=false";
    
    Drone d1786b = drones.get(36);
    d1786b.pubYear = "1786b";
    d1786b.pubDef = "Drone";
    d1786b.pubAuth = "Robert Burns";
    d1786b.source = "https://books.google.co.uk/books?num=8&id=UCxYAAAAcAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1789 = drones.get(37);
    d1789.pubYear = "1789";
    d1789.pubDef = "Droning";
    d1789.pubAuth = "Hester Lynch Piozzi";
    d1789.source = "https://books.google.co.uk/books?num=8&id=SH9CAAAAcAAJ&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1794 = drones.get(40);
    d1794.pubYear = "1794";
    d1794.pubDef = "Drony";
    d1794.pubAuth = "Hester Lynch Piozzi";
    d1794.source = "https://books.google.co.uk/books?num=8&id=6cOKqyu_uxEC&q=drony#v=snippet&q=drony&f=false";
    
    Drone d1819 = drones.get(41);
    d1819.pubYear = "1819";
    d1819.pubDef = "Drone";
    d1819.pubAuth = "William Tennant";
    d1819.source = "https://books.google.co.uk/books?num=8&id=KsDPAAAAMAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1822 = drones.get(42);
    d1822.pubYear = "1822";
    d1822.pubDef = "Drony";
    d1822.pubAuth = "George Wilkins";
    d1822.source = "https://books.google.co.uk/books?num=8&id=8HJhBTcKJeAC&q=drony#v=snippet&q=drony&f=false";
    
    Drone d1827 = drones.get(43);
    d1827.pubYear = "1827";
    d1827.pubDef = "Drones";
    d1827.pubAuth = "Thomas Macaulay";
    d1827.source = "https://books.google.co.uk/books?num=8&id=2bs8AAAAIAAJ&q=drones#v=snippet&q=drone&f=false";
    
    Drone d1834 = drones.get(44);
    d1834.pubYear = "1834";
    d1834.pubDef = "Drone";
    d1834.pubAuth = "Edward Lytton";
    d1834.source = "https://books.google.co.uk/books?num=8&id=TzjW9AvV8skC&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1837a = drones.get(45);
    d1837a.pubYear = "1837a";
    d1837a.pubDef = "Drony";
    d1837a.pubAuth = "William Blackwood";
    d1837a.source = "https://books.google.co.uk/books?num=8&id=3WZHAQAAMAAJ&q=drony#v=snippet&q=drony&f=false";
    
    Drone d1837b = drones.get(46);
    d1837b.pubYear = "1837b";
    d1837b.pubDef = "Drones";
    d1837b.pubAuth = "Thomas Carlyle";
    d1837b.source = "https://books.google.co.uk/books?num=8&id=NJFIAQAAMAAJ&q=drones#v=snippet&q=drones&f=false";
    
    Drone d1843 = drones.get(47);
    d1843.pubYear = "1843";
    d1843.pubDef = "Drone";
    d1843.pubAuth = "Edward Lytton";
    d1843.source = "https://books.google.co.uk/books?num=8&id=_at43_TgTvsC&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1844 = drones.get(48);
    d1844.pubYear = "1844";
    d1844.pubDef = "Droning";
    d1844.pubAuth = "Ralph Waldo Emerson";
    d1844.source = "https://books.google.co.uk/books?num=8&id=RO1LAAAAcAAJ&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1845 = drones.get(49);
    d1845.pubYear = "1845";
    d1845.pubDef = "Dronish";
    d1845.pubAuth = "Thomas Hood";
    d1845.source = "https://books.google.co.uk/books?num=8&id=K1o7AAAAYAAJ&q=dronish#v=snippet&q=dronish&f=false";
    
    Drone d1849 = drones.get(50);
    d1849.pubYear = "1849";
    d1849.pubDef = "Droned";
    d1849.pubAuth = "George Payne Rainsford James";
    d1849.source = "https://books.google.co.uk/books?num=8&id=F9gNAAAAQAAJ&q=drone#v=onepage&q=droned&f=false";
    
    Drone d1852 = drones.get(51);
    d1852.pubYear = "1852";
    d1852.pubDef = "Droned";
    d1852.pubAuth = "Mary Eleanor Wilkins";
    d1852.source = "https://archive.org/stream/humbleromanceoth00freeiala#page/n33/mode/2up/search/droned";
    
    Drone d1853 = drones.get(52);
    d1853.pubYear = "1853";
    d1853.pubDef = "Droners";
    d1853.pubAuth = "Robert Forman Horton";
    d1853.source = "https://archive.org/stream/verbumdei00hortuoft#page/186/mode/2up/search/droners";
    
    Drone d1854 = drones.get(53);
    d1854.pubYear = "1854";
    d1854.pubDef = "Drean";
    d1854.pubAuth = "James Manning";
    d1854.source = "https://archive.org/stream/transactionsphi00britgoog#page/n230/mode/2up/search/drean";
    
    Drone d1858a = drones.get(54);
    d1858a.pubYear = "1858a";
    d1858a.pubDef = "Droning";
    d1858a.pubAuth = "William Johnson Cory";
    d1858a.source = "https://archive.org/stream/ionica00cory#page/76/mode/2up/search/droning";
    
    Drone d1858b = drones.get(55);
    d1858b.pubYear = "1858b";
    d1858b.pubDef = "Droning";
    d1858b.pubAuth = "Thomas Carlyle";
    d1858b.source = "https://archive.org/stream/worksofthomascar12carliala#page/52/mode/2up/search/droning";
    
    Drone d1860 = drones.get(56);
    d1860.pubYear = "1860";
    d1860.pubDef = "Droning";
    d1860.pubAuth = "William Thackeray";
    d1860.source = "https://books.google.co.uk/books?num=8&id=w_OigbQqSYoC&q=droning#v=snippet&q=droning&f=false";
    
    Drone d1864 = drones.get(57);
    d1864.pubYear = "1864";
    d1864.pubDef = "Drone";
    d1864.pubAuth = "Margaret Gatty";
    d1864.source = "https://archive.org/stream/parablesfromnat02gattgoog#page/n212/mode/2up/search/drone";
    
    Drone d1868 = drones.get(58);
    d1868.pubYear = "1868";
    d1868.pubDef = "Drone";
    d1868.pubAuth = "Charles Kingsley";
    d1868.source = "https://archive.org/stream/poemscharleskin00kinggoog#page/n328/mode/2up";

    Drone d1869 = drones.get(59);
    d1869.pubYear = "1869";
    d1869.pubDef = "Drony";
    d1869.pubAuth = "James Russell Lowell";
    d1869.source = "https://books.google.co.uk/books?num=8&id=OtwzAQAAIAAJ&q=drony#v=snippet&q=drony&f=false";
    
    Drone d1875 = drones.get(60);
    d1875.pubYear = "1875";
    d1875.pubDef = "Drone";
    d1875.pubAuth = "Charles Maurice Davies";
    d1875.source = "https://books.google.co.uk/books?num=8&id=f_QPAAAAYAAJ&q=drone#v=snippet&q=drone&f=false";
    
    Drone d1878 = drones.get(61);
    d1878.pubYear = "1878";
    d1878.pubDef = "Droning";
    d1878.pubAuth = "Henry Stanley";
    d1878.source = "https://archive.org/stream/throughdarkconti01henr#page/146/mode/2up/search/droning";
    
    Drone d1879 = drones.get(62);
    d1879.pubYear = "1879";
    d1879.pubDef = "Drones";
    d1879.pubAuth = "William Stone";
    d1879.source = "https://archive.org/stream/dictionaryofmusi01grovuoft#page/124/mode/2up/search/drones";
    
    Drone d1886 = drones.get(63);
    d1886.pubYear = "1886";
    d1886.pubDef = "Drane";
    d1886.pubAuth = "Frederic Elworthy";
    d1886.source = "https://books.google.co.uk/books?num=8&id=qHkKAAAAIAAJ&q=droningly#v=onepage&q=drane&f=false";
    
    Drone d1887a = drones.get(64);
    d1887a.pubYear = "1887a";
    d1887a.pubDef = "Droningly";
    d1887a.pubAuth = "Walter Hervey";
    d1887a.source = "https://archive.org/stream/picturework00herv#page/22/mode/2up/search/droningly";
    
    Drone d1887b = drones.get(65);
    d1887b.pubYear = "1887b";
    d1887b.pubDef = "Droning";
    d1887b.pubAuth = "Walter Hervey";
    d1887b.source = "https://archive.org/stream/picturework00herv#page/22/mode/2up/search/droning";
    
    Drone d1892 = drones.get(66);
    d1892.pubYear = "1892";
    d1892.pubDef = "Droningly";
    d1892.pubAuth = "James Russell Lowell";
    d1892.source = "https://archive.org/stream/compwritingsof08lowerich#page/n207/mode/2up/search/droningly";
    
    Drone d1894 = drones.get(67);
    d1894.pubYear = "1894";
    d1894.pubDef = "Dronings";
    d1894.pubAuth = "James Anthony Froude";
    d1894.source = "https://archive.org/stream/cu31924006784338#page/n137/mode/2up/search/dronings";
    
    /*
    Drone d = drones.get();
    d.pubYear = "";
    d.pubDef = "";
    d.pubAuth = "";
    d.source = "";
    */
    
    for (Drone d: drones) {
      d.swarm(drones);
    }
  
    for (Drone d: drones) {
      d.run(drones);
    }
  }
  
  void addDrone(Drone d) {
    drones.add(d);
  }
}