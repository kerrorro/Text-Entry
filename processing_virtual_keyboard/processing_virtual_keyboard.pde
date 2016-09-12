/* 
   Example of Serial Communication by Tom Igoe. 
   Modified by Caroline Chen.
   Creates an on screen keyboard to which reads serial button presses
   to allow text entry via 5-button method (directional arrows + enter).
*/

import java.awt.List;
import java.util.Map;
import processing.serial.*; 

/**** Button Processing Variables ****/
Serial myPort;                                           // The serial port
PFont myFont;                                            // The display font
String buttonPressed;                                    // Input string from serial port
String[] buttonLabels = {"1", "2", "3", "4", "5"};       // Expected input from serial corresponding to button
int lf = 10;                                             // ASCII linefeed 

/**** Grid Set Up Variables ****/
ArrayList<String> optionsList = new ArrayList<String>(); // holds keys used in creation of location map
int numRow = 5;                                          // dimensions of grid layout
int numCol = 6;
int row;                                                 // actual position in grid
int col;
HashMap<String, int[]> location = new HashMap<String, int[]>();           // stores the entry option's grid location; "a": [0,0]

/**** Drawing Variables ****/
int[] highlightedCell = {0, 0};                                     // Marker for grid position of currently selected letter
String displayText = "";                                            // Text entry to be displayed
PImage virtualKeyboardImg;
HighlightSquare select = new HighlightSquare(152, 170, 80);


public class HighlightSquare{
  private int highlightSize;
  private int pixelPositionX;
  private int pixelPositionY;
  private int startingX;
  private int startingY;
  
  public int getSize(){return highlightSize;}
  public int getStartingX(){return startingX;}
  public int getStartingY(){return startingY;}
  
  public void setPixelX(int x){
    this.pixelPositionX = x;  
  }
  public void setPixelY(int y){
    this.pixelPositionY = y;
  }
  HighlightSquare(int x, int y, int size){
    this.pixelPositionX = x;
    this.startingX = x;
    this.pixelPositionY = y;
    this.startingY = y;
    this.highlightSize = size;
  }
  
  public void draw(){
    fill(113, 191, 68, 63);
    rect(this.pixelPositionX, this.pixelPositionY, this.highlightSize, this.highlightSize, 7);
  }
  
 
}


void setup() { 
  size(800,600); 
  myFont = createFont("Letter Gothic Std", 60); 
  textFont(myFont); 
 
  myPort = new Serial(this, Serial.list()[0], 9600);     // Set to "COM4" at baud rate of 9600
  myPort.bufferUntil(lf); 
  
  int rowCount = 0;                                        
  int colCount = 0;
  for(int i=97; i<123; i++){                             // Adds a-z to optionsArray using ascii
    optionsList.add(Character.toString((char)i));
  };
  optionsList.add("SPACE");
  optionsList.add("BACKSPACE");
  
  for(String option : optionsList){                      // Creates the grid position for each option
    row = rowCount % numRow;
    col = colCount % numCol;
    int[] coordinates = {row, col};
    location.put(option, coordinates);
    if (col == 5){
      rowCount++;
    }
    colCount++;
  }
  
  virtualKeyboardImg = loadImage("virtualkeyboard.png");

} 
 
 
 
void draw() { 
  image(virtualKeyboardImg, 0, 0);
  //text(displayText, 20, 50);

 // fill(113, 191, 68, 63);                                             // (r, g, b, alpha)
  //rect(152, 170, highlightSize, highlightSize, 7);                    // (x, y, width, height)
  fill(0, 0, 0);
  text(displayText, 10,150);
  select.draw();
} 
 
 
 
 
void serialEvent(Serial p) { 
  buttonPressed = p.readString().replaceAll("\\s", ""); 
  System.out.println(buttonPressed);

  switch (buttonPressed) {
      case "1":
        System.out.println("Enter");
        // Enter button: Flash fill color and add letter to display text
        String selectedKey = getKey(location, highlightedCell);
        switch(selectedKey){
          case "SPACE":
            System.out.println("Adding space to display text");
            displayText += " ";
            break;
          case "BACKSPACE":
            System.out.println("Deleting last letter in display text");
            displayText = displayText.substring(0, displayText.length() - 1);
            break;
          default:
            System.out.println("Adding selected letter to display text");
            System.out.println(selectedKey);
            displayText += selectedKey;
            break;
        }
        
        break;  
      case "2":
        System.out.println("Right");
        // Right button: 
        highlightedCell[1] = (highlightedCell[1] + 1) % numCol;
        //select.setPixelY(select.getPixelY() + select.getSize());
        select.setPixelX(select.getStartingX() + highlightedCell[1]*select.getSize());
        break;
      case "3":
        System.out.println("Up");
        // Up button:
        if (highlightedCell[0] - 1 < 0){                             // Adds full "phase change" if number will be negative, then calculates modulo
          highlightedCell[0] = highlightedCell[0] + numRow;
        }
        highlightedCell[0] = (highlightedCell[0] - 1) % numRow;
        select.setPixelY(select.getStartingY() + highlightedCell[0]*select.getSize());
        break;  
      case "4":
        System.out.println("Left");
        // Left button:
        if (highlightedCell[1] - 1 < 0){                             // Adds full "phase change" if number will be negative, then calculates modulo
          highlightedCell[1] = highlightedCell[1] + numCol;
        }
        highlightedCell[1] = (highlightedCell[1] - 1) % numCol;
        select.setPixelX(select.getStartingX() + highlightedCell[1]*select.getSize());
        break;  
      case "5":
        System.out.println("Down");
        // Down button:
        highlightedCell[0] = (highlightedCell[0] + 1) % numRow;
        System.out.println(highlightedCell[0]);
        select.setPixelY(select.getStartingY() + highlightedCell[0]*select.getSize());
        break;
    };
    System.out.println("Currently selected:" + highlightedCell[0] + "," + highlightedCell[1]);
} 



// Returns key look up for position value
static String getKey(HashMap<String, int[]> map, int[] coordinates) {
  for(Map.Entry<String, int[]> entry : map.entrySet()) {
    if((coordinates[0] == entry.getValue()[0] && coordinates[1] == entry.getValue()[1])){
        String selectedKey = entry.getKey();
        return selectedKey;
      }      
  }
  return "";
}