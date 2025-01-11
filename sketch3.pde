// Class instances and game components
StartScreen startScreen;
CountdownTimer countdown;
EndScreen endScreen;
Doll doll;

// Game state to track which screen is active
String gameState = "start";

// Images
PImage bg;
PImage ssBG;
PImage esBG;
PImage donePOPUP;
PImage timePOPUP;

// Font
PFont f;

// Buttons
Button doneButton;
Button timeUpButton;
Button yesButton;
Button noButton;

// Themes
String[] themes = {"Office Siren", "Coquette", "Night Out"};
String selectedTheme = "";

// Timer variables
boolean isPaused = false;
boolean showTimePopup = false;
boolean showDonePopup = false;


// Initialize setup components
void setup() {
  size(1000, 650);
  doneButton = new Button(916, 91, 20, 20);
  timeUpButton = new Button(450, 360, 100, 57);
  yesButton = new Button(360, 370, 90, 50);
  noButton = new Button(550, 370, 90, 50);
  
  // Initialize game components
  startScreen = new StartScreen();
  countdown = new CountdownTimer(180000);
  endScreen = new EndScreen();
  doll = new Doll();

  // Load images
  bg = loadImage("ddBG.PNG");
  ssBG = loadImage("ssBG.png");
  esBG = loadImage("esBG.png");
  donePOPUP = loadImage("donePOPUP.png");
  timePOPUP = loadImage("timePOPUP.png");

  // Load font
  f = createFont("Daydream.ttf", 20);
  textFont(f);
}


// Render appropriate screen based on current game state
void draw() {
  background(255);

  // Determine which screen to display
  if (gameState.equals("start")) {
    startScreen.render();
  } else if (gameState.equals("middle")) {
    renderMiddle();
  } else if (gameState.equals("end")) {
    endScreen.render();
  }
}


// Render gameplay scene
void renderMiddle() {
  image(bg, 0, 0, width, height);

  // Display countdown timer if not paused
  countdown.render();

  // Render theme text
  renderThemeText();

  // Render doll on the main screen
  doll.render();

  // Show either the "ARE YOU DONE?" or "TIME'S UP"
  if (showDonePopup) {
    displayDonePopup();
  } else if (showTimePopup) {
    displayTimeUpPopup();
  } else {
    // Display clothing items in closet and done button if no popup is active
    renderClosetItems();
    doneButton.display();
  }
}


// Display "ARE YOU DONE?" popup
void displayDonePopup() {
  renderGrayOverlay();
  image(donePOPUP, 250, 230, 500, 250);
  yesButton.display();
  noButton.display();
}


// Display "TIME'S UP" popup
void displayTimeUpPopup() {
  renderGrayOverlay();
  image(timePOPUP, 250, 230, 500, 250);
  timeUpButton.display();
}


// Render closet items if not selected on doll
void renderClosetItems() {
  // Tops
  if (doll.selectedTop != 0) image(doll.tops[0], 58, 225, 151, 132);
  if (doll.selectedTop != 1) image(doll.tops[1], 208, 210, 140, 175);
  if (doll.selectedTop != 2) image(doll.tops[2], 353, 220, 140, 135);

  // Bottoms
  if (doll.selectedBottom != 0) image(doll.bottoms[0], 60, 334, 145, 80);
  if (doll.selectedBottom != 1) image(doll.bottoms[1], 212, 315, 130, 235);
  if (doll.selectedBottom != 2) image(doll.bottoms[2], 352, 347, 145, 80);

  // Shoes
  if (doll.selectedShoe != 0) image(doll.shoes[0], 69, 416, 130, 150);
  if (doll.selectedShoe != 1) image(doll.shoes[1], 222, 514, 110, 50);
  if (doll.selectedShoe != 2) image(doll.shoes[2], 373, 491, 110, 70);

  // Accessories
  if (!doll.selectedAcc.contains(0)) image(doll.acc[0], 520, 195, 60, 120);
  if (!doll.selectedAcc.contains(1)) image(doll.acc[1], 468, 320, 120, 230);
  
  // Rotate and display acc[2] in closet
  if (!doll.selectedAcc.contains(2)) {
    pushMatrix();
    translate(433 + 60, 193 + 40);
    rotate(HALF_PI);
    image(doll.acc[2], -60, -40, 140, 40);
    popMatrix();
  }
}


// Handle mouse input based on game state and active popups
void mousePressed() {
  if (gameState.equals("start")) {
    startScreen.checkButtonClick();
  } else if (gameState.equals("middle")) {
    // Check for active popups first to prevent unintended item selection
    if (showDonePopup) {
      // If "ARE YOU DONE?" popup is active, only allow interaction with popup buttons
      if (yesButton.isClicked()) {
        gameState = "end";
        showDonePopup = false;
      } else if (noButton.isClicked()) {
        showDonePopup = false;
      }
    } else if (showTimePopup) {
      // If "TIME'S UP" popup is active, only allow interaction with "End" button
      if (timeUpButton.isClicked()) {
        gameState = "end";
      }
    } else {
      // Only allow clothing item selection if no popup is active
      if (doneButton.isClicked()) {
        showDonePopup = true;
      } else {
        handleClothingSelection();
      }
    }
  }
}


// Handle selection of "Yes", "No", and "End" buttons on popups
void handlePopupButtons() {
  if (showDonePopup) {
    if (yesButton.isClicked()) {
      gameState = "end";
      showDonePopup = false;
    } else if (noButton.isClicked()) {
      showDonePopup = false;
    }
  } else if (showTimePopup && timeUpButton.isClicked()) {
    gameState = "end";
  }
}


// Handle clothing selection logic
void handleClothingSelection() {
  // Toggle selection for tops, clicking again on selected top removes it
  if (overImage(58, 225, 151, 132)) {
    doll.selectTop(doll.selectedTop == 0 ? -1 : 0);
  } else if (overImage(208, 210, 140, 175)) {
    doll.selectTop(doll.selectedTop == 1 ? -1 : 1);
  } else if (overImage(353, 220, 140, 135)) {
    doll.selectTop(doll.selectedTop == 2 ? -1 : 2);
  }
  
  // Check if click was on doll's top area to remove it
  if (overImage(727, 191, 151, 132) && doll.selectedTop != -1) {
    // Deselect top
    doll.selectTop(-1);
  }

  // Toggle selection for bottoms
  if (overImage(60, 334, 145, 80)) {
    doll.selectBottom(doll.selectedBottom == 0 ? -1 : 0);
  } else if (overImage(212, 315, 130, 235)) {
    doll.selectBottom(doll.selectedBottom == 1 ? -1 : 1);
  } else if (overImage(352, 347, 145, 80)) {
    doll.selectBottom(doll.selectedBottom == 2 ? -1 : 2);
  }

  // Check if click was on doll's bottom area to remove it
  if (overImage(730, 285, 145, 80) && doll.selectedBottom != -1) {
    // Deselect bottom
    doll.selectBottom(-1);
  }

  // Toggle selection for shoes
  if (overImage(69, 416, 130, 150)) {
    doll.selectShoe(doll.selectedShoe == 0 ? -1 : 0);
  } else if (overImage(222, 514, 110, 50)) {
    doll.selectShoe(doll.selectedShoe == 1 ? -1 : 1);
  } else if (overImage(373, 491, 110, 70)) {
    doll.selectShoe(doll.selectedShoe == 2 ? -1 : 2);
  }

  // Check if click was on doll's shoe area to remove it
  if (overImage(732, 420, 140, 150) && doll.selectedShoe != -1) {
    // Deselect shoes
    doll.selectShoe(-1);
  }

  // Toggle selection for accessories, checking for existing selection
  if (overImage(520, 195, 60, 120)) {
    doll.toggleAccessory(0);
  } else if (overImage(468, 320, 120, 230)) {
    doll.toggleAccessory(1);
  } else if (overImage(433, 193, 120, 80)) {
    doll.toggleAccessory(2);
  }

  // Check if click was on the doll's accessory areas to remove them
  if (overImage(795, 190, 60, 120) && doll.selectedAcc.contains(0)) {
    doll.toggleAccessory(0);
  }
  if (overImage(732, 290, 137, 270) && doll.selectedAcc.contains(1)) {
    doll.toggleAccessory(1);
  }
  if (overImage(732, 135, 140, 40) && doll.selectedAcc.contains(2)) {
    doll.toggleAccessory(2); 
  }
}


// Render the randomized theme text
void renderThemeText() {
  // Theme box dimensions (to center text on specific area)
  float bX = 90;
  float bY = 65;
  float bW = 300;
  float bH = 60;
  
  // Theme box aesthetics
  noFill();
  rect(bX, bY, bW, bH);
  textAlign(CENTER, CENTER);
  textSize(25);
  fill(0);
  text(selectedTheme, bX + bW / 2, bY + bH / 2);
}


// Handle popup display and button interactions
void handlePopupsAndButtons() {
  if (showDonePopup) {
    image(donePOPUP, 250, 230, 500, 250);
    yesButton.display();
    noButton.display();
  } else if (showTimePopup) {
    image(timePOPUP, 250, 230, 500, 250);
    timeUpButton.display();
  }
  
  // Display and handle done button if no popup is active
  if (!showTimePopup && !showDonePopup) {
    doneButton.display();
    if (doneButton.isClicked()) {
      showDonePopup = true;
    }
  }
}


// Doll class to handle clothing items and rendering
class Doll {
  // Images
  PImage baseDoll;
  PImage[] tops = new PImage[3];
  PImage[] bottoms = new PImage[3];
  PImage[] shoes = new PImage[3];
  PImage[] acc = new PImage[3];

  // Selected clothing indicies and array
  int selectedTop = -1;
  int selectedBottom = -1;
  int selectedShoe = -1;
  ArrayList<Integer> selectedAcc = new ArrayList<Integer>();

  // Initialize doll and load all images
  Doll() {
    baseDoll = loadImage("baseDoll.PNG");
    tops[0] = loadImage("top1.PNG");
    tops[1] = loadImage("top2.PNG");
    tops[2] = loadImage("top3.PNG");
    bottoms[0] = loadImage("bottom1.PNG");
    bottoms[1] = loadImage("bottom2.PNG");
    bottoms[2] = loadImage("bottom3.PNG");
    shoes[0] = loadImage("shoe1.PNG");
    shoes[1] = loadImage("shoe2.PNG");
    shoes[2] = loadImage("shoe3.PNG");
    acc[0] = loadImage("acc1.PNG");
    acc[1] = loadImage("acc2.PNG");
    acc[2] = loadImage("acc3.PNG");
  }
  
  // Render selected clothing items on the doll at specified positions
  void render() {
    image(baseDoll, 715, 90, 160, 470);
    
    // Accessory (seperated here for proper layering)
    if (selectedAcc.contains(1)) image(acc[1], 732, 290, 137, 270);
    
    // Shoes
    if (selectedShoe == 0) image(shoes[0], 732, 420, 140, 150);
    else if (selectedShoe == 1) image(shoes[1], 733, 513, 140, 60);
    else if (selectedShoe == 2) image(shoes[2], 732, 490, 140, 80);
    
    // Bottoms
    if (selectedBottom == 0) image(bottoms[0], 730, 285, 145, 80);
    else if (selectedBottom == 1) image(bottoms[1], 734, 294, 135, 250);
    else if (selectedBottom == 2) image(bottoms[2], 734, 283, 135, 80);
   
    // Tops
    if (selectedTop == 0) image(tops[0], 727, 191, 151, 132);
    else if (selectedTop == 1) image(tops[1], 732, 191, 140, 175);
    else if (selectedTop == 2) image(tops[2], 732, 190, 140, 135);

    // Accessories
    if (selectedAcc.contains(0)) image(acc[0], 795, 190, 60, 120);
    if (selectedAcc.contains(2)) image(acc[2], 732, 135, 140, 40);
  }

  // Render final outfit in end screen
  void displayEndScreen() {
    image(baseDoll, width / 2 - 80, height / 2 - 202, 160, 470);

    // Render selected accessory on doll
    if (selectedAcc.contains(1)) image(acc[1], width / 2 - 63, height / 2 - 11, 137, 270);
    
    // Render selected shoe on doll
    if (selectedShoe != -1) {
      if (selectedShoe == 0) image(shoes[0], width / 2 - 62, height / 2 + 128, 140, 150); 
      else if (selectedShoe == 1) image(shoes[1], width / 2 - 62, height / 2 + 221, 140, 60); 
      else if (selectedShoe == 2) image(shoes[2], width / 2 - 62, height / 2 + 198, 140, 80);
    }
    
    // Render selected bottom the doll
    if (selectedBottom != -1) {
      if (selectedBottom == 0) image(bottoms[0], width / 2 - 65, height / 2 - 6, 145, 80); 
      else if (selectedBottom == 1) image(bottoms[1], width / 2 - 61, height / 2 - 2, 135, 250); 
      else if (selectedBottom == 2) image(bottoms[2], width / 2 - 60, height / 2 - 10, 135, 80);
    }
    
    // Render selected top on doll
    if (selectedTop != -1) {
      if (selectedTop == 0) image(tops[0], width / 2 - 68, height / 2 - 102, 151, 132); 
      else if (selectedTop == 1) image(tops[1], width / 2 - 63, height / 2 - 106, 140, 175);
      else if (selectedTop == 2) image(tops[2], width / 2 - 63, height /2 - 104, 140, 135);
    }
    
    // Render selected accessory on doll
    if (selectedAcc.contains(0)) image(acc[0], width / 2 + 1, height / 2 - 106, 60, 120);
    if (selectedAcc.contains(2)) image(acc[2], width / 2 - 63, height / 2 - 157, 140, 40);
  }

  // Update selected top index
  void selectTop(int index) { 
    selectedTop = index; 
  }
  
  // Update selected bottom index
  void selectBottom(int index) { 
    selectedBottom = index; 
  }
  
  // Update selected shoe index
  void selectShoe(int index) { 
    selectedShoe = index; 
  }
  
  // Update selected accessory index
  void toggleAccessory(int index) {
    if (selectedAcc.contains(index)) selectedAcc.remove((Integer) index);
    else selectedAcc.add(index);
  }
}


// End screen class to display final game state
class EndScreen {
  void render() {
    background(255);
    image(esBG, 0, 0, width, height);
    doll.displayEndScreen(); 
  }
}


// Utility function to check if mouse is over an image
boolean overImage(int x, int y, int w, int h) {
  return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
}


// Button class to handle interactive buttons
class Button {
  float x;
  float y;
  float w;
  float h;
  
  // Button constructor to initialize button dimensions
  Button(float x, float y, float w, float h) {
    this.x = x; 
    this.y = y; 
    this.w = w; 
    this.h = h;
  }
  
  // Display button on screen
  void display() { 
    noFill(); 
    noStroke(); 
    rect(x, y, w, h); 
  }
  
  // Check if button is clicked
  boolean isClicked() { 
    return mousePressed && mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h; 
  }
}


// CountdownTimer class to manage game timing
class CountdownTimer {
  int startTime;
  int totalTime;
  
  // Initialize timer with a specific duration
  CountdownTimer(int totalTime) { 
    this.totalTime = totalTime; reset(); 
  }
  
  // Reset the timer to start again
  void reset() { 
    startTime = millis(); 
  }
  
  // Calculate and return remaining time
  int getRemainingTime() { 
    return totalTime - (millis() - startTime); 
  }
  
  // Check if timer has run out
  boolean isTimeUp() { 
    return getRemainingTime() <= 0; 
  }
  
  // Render countdown timer on screen
  void render() {
    int remainingTime = max(getRemainingTime(), 0);
    int minutes = remainingTime / 60000;
    int seconds = (remainingTime % 60000) / 1000;
    String timeText = nf(minutes, 1) + ":" + nf(seconds, 2);
    
    // Display formatted timer text
    textFont(f); 
    textSize(24); 
    fill(0); 
    text(timeText, 530, 92);
    
    // Trigger popup when time is up
    if (isTimeUp()) showTimePopup = true;
  }
}


// Start screen class to display instructions and start game
class StartScreen {
  // Button to start the game
  Button startButton;
  
  // Constructor to initialize start button
  StartScreen() { 
    startButton = new Button(450, 490, 100, 57); 
  }
  
  // Render start screen with instructions and start button
  void render() { 
    background(255); 
    image(ssBG, 0, 0, width, height); 
    startButton.display(); 
  }
  
  // Check if start button is clicked to begin game
  void checkButtonClick() {
    if (startButton.isClicked()) {
      selectedTheme = themes[int(random(themes.length))];
      gameState = "middle";
      countdown = new CountdownTimer(180000);
    }
  }
}


// Render transparent gray overlay
void renderGrayOverlay() {
  fill(0, 0, 0, 120);
  rect(0, 0, width, height);
  noFill();
}
