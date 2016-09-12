/*
 Pushbutton interrupt example with debouncing
 for RedBear Duo with internal pull-down resistor.
 
 Blink an LED as long as a button is pressed.
 Adapted from the Particle Photon documentation.
 modified 29 Aug 2016
 by Bjoern Hartmann for RedBear Duo
 
 The circuit:
 * internal LED on D7
 * pushbutton connected to D1 to D5 and 3V3
 
 see https://docs.particle.io/reference/firmware/photon/#attachinterrupt-
 */

// do not use the cloud functions - assume programming through Arduino IDE
#if defined(ARDUINO) 
SYSTEM_MODE(MANUAL); 
#endif


int interruptState;

const int myButtons[] = {D1, D2, D3, D4, D5};
// note: Particle documentation states external interrupts
// DO NOT work on D0 and A5 for RedBear Duo
const int LED = D7;                         // LED is connected to D7

long debounceDelay = 50;                    // the debounce time in ms
volatile int LED_state = LOW;               
volatile int activatedButton;               // activatedButton does include debounce; just a 

void toggle(void);
void isr(void);

Timer timer(debounceDelay, toggle, true);   // toggle event raised repeatedly (true) after debounceDelay elapses (one shot timer)

void setup()
{
  Serial.begin(9600);
  pinMode(LED, OUTPUT);

  for (int button : myButtons){
    pinMode(button, INPUT_PULLDOWN);
    attachInterrupt(button, isr, RISING);     // ISR can be triggered on CHANGE, RISING or FALLING
  }
  
}

void loop()
{
  for (int button : myButtons){
    if(digitalRead(button) == HIGH){
      activatedButton = button;
//      Serial.print(activatedButton);
    }
  }
}

void toggle() {                             // switches state when button is pressed (only if the one shot timer has triggered the event i.e. alrdy debounced) 
  if(digitalRead(activatedButton)==HIGH){
    LED_state=!LED_state;
    digitalWrite(LED, LED_state);

    //Serial.println(activatedButton);

  
  }
}

void isr(void)
{ 
  noInterrupts();                           // stop allowing interrupts once in an ISR (won't cause noise switches to start another ISR)
  if(digitalRead(activatedButton)==HIGH){

    timer.resetFromISR();                   //start or reset timer on every rising edgev
  } else {
    timer.stopFromISR();                    //stop on falling edge; counts to see if timer will exceed debounce delay
  } 
  
  interrupts();                             // allow interrupts again once ISR has completed executing
  interruptState = 0;
}


