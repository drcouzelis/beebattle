/**
 * Copyright 2009 David Couzelis
 * 
 * This file is part of "Bee Battle".
 * 
 * "Bee Battle" is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * "Bee Battle" is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with "Bee Battle".  If not, see <http://www.gnu.org/licenses/>.
 */
/**
 * Final Project Game
 * Function 12 Software
 * David Rawson Couzelis
 * Todd Burnop
 * Start 2000/11/20
 */
#import <objc/Object.h>
#import "allegro.h"


#define GAME_TICKER 60

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define COLOR_DEPTH 24

#define BLACK (makecol(0, 0, 0))

#define MAX_NUM_OF_SPRITES 256
#define MAX_NUM_OF_CC_ATK 2


volatile int timer = 0;


int random_number(int low, int high) {
  return (rand() % (high - low + 1)) + low;
}


@interface ATK : Object {
  
  int x_pos, y_pos;          // Current ATK position...
  int x_speed, y_speed;
  
  BITMAP *pic;               // The picture of the ATK...
  int type;                  // 1 for CC, 2 for OO...
  
}

- initWithImage: (char *) nameSent andX: (int) start_x andY: (int) start_y andType: (int) typeSent;
- update;
- (BITMAP *) getPic;
- (int) getXPos;
- (int) getYPos;

@end


@implementation ATK


- init {
  self = [super init];
  if (self) {
    x_pos = 0;
    y_pos = 0;
    x_speed = 0;
    y_speed = 0;
    type = 0;
    pic = NULL;
  }
  return self;
}


- initWithImage: (char *) nameSent andX: (int) start_x andY: (int) start_y andType: (int) typeSent {
  
  PALLETE my_pallete;
  
  self = [self init];
  
  if (self) {
    
    x_pos = start_x;
    y_pos = start_y;
    type = typeSent;
    
    if (type == 1) {
      y_speed = -6;
    } else if (type == 2) {
      y_speed = 2;
    }
    
    pic = load_bitmap(nameSent, my_pallete);
    set_palette(my_pallete);
    
  }
  
  return self;
  
}


- free {
  destroy_bitmap(pic);
  return [super free];
}


- update {
  
  x_pos += x_speed;
  y_pos += y_speed;
  
  // Check if the ATK is off the screen...
  if (x_pos <= -[self getPic]->w || x_pos >= SCREEN_WIDTH || y_pos <= -[self getPic]->h || y_pos >= SCREEN_HEIGHT) {
    return nil;
  }
  
  return self;
  
}


- (BITMAP *) getPic {
  return pic;
}


- (int) getXPos {
  return x_pos;
}


- (int) getYPos {
  return y_pos;
}


@end


// A generic Controllable Character...
@interface CC : Object {
  
  int lives;               // Amount of remaining lives...
  int x_pos, y_pos;        // The position of the CC...
  
  BITMAP *pic1;            // Stores the two pictures to be animated...
  BITMAP *pic2;
  int frame;               // Which tile to display now...
  
  int keyCount;            // Counts how long the shoot button has been held...
  
}

- initWithLives: (int) livesSent;
- (BOOL) shoot;
- update;
- (BITMAP *) getPic;
- (int) getXPos;
- (int) getYPos;
- (BOOL) kill;

@end


@implementation CC


- init {
  self = [super init];
  if (self) {
    lives = 0;
    x_pos = 0;
    y_pos = 0;
    pic1 = NULL;
    pic2 = NULL;
    frame = 0;
    keyCount = 0;
  }
  return self;
}


// Construct a CC!!...
- initWithLives: (int) livesSent {
  PALLETE my_pallete;
  self = [self init];
  if (self) {
    lives = livesSent;
    pic1 = load_bitmap("bee1.bmp", my_pallete);
    pic2 = load_bitmap("bee2.bmp", my_pallete);
    set_palette(my_pallete);
    frame = 1;
    x_pos = (SCREEN_WIDTH / 2) - ([self getPic]->w / 2);   // Start at the center of the screen for now...
    y_pos = SCREEN_HEIGHT - ([self getPic]->h * 2);        // Near the bottom of the screen...
  }
  return self;
}


- free {
  destroy_bitmap(pic1);
  destroy_bitmap(pic2);
  return [super free];
}


// Ask the CC if it's ready to shoot!...
- (BOOL) shoot {
  if (key[KEY_SPACE]) {
    if (keyCount == 0) {
      keyCount = 20;
      return YES;
    } else {
      keyCount--;
      return NO;
    }
  }
  keyCount = 0;
  return NO;
}


- update {
  
  //Update the pos (keyboard input)...
  if (key[KEY_LEFT]) {
    x_pos -= 4;
  }
  
  if (key[KEY_RIGHT]) {
    x_pos += 4;
  }
  
  // Check out of bounds position!...
  if (x_pos > SCREEN_WIDTH - [self getPic]->w) {
    x_pos = SCREEN_WIDTH - [self getPic]->w;
  } else if (x_pos < 0) {
    x_pos = 0;
  }
  
  if (y_pos > SCREEN_HEIGHT - [self getPic]->h) {
    y_pos = SCREEN_HEIGHT - [self getPic]->h;
  } else if (y_pos < 0) {
    y_pos = 0;
  }
  
  return self;
  
}


- (BITMAP *) getPic {
  if (frame == 1) {
    frame = 2;
    return pic1;
  } else {
    frame = 1;
    return pic2;
  }
}

- (int) getXPos {
  return x_pos;
}


- (int) getYPos {
  return y_pos;
}


// When the CC is hit, kill him!...
// Return true when there are no more extra lives...
- (BOOL) kill {
  x_pos = (SCREEN_WIDTH / 2) - ([self getPic]->w / 2);     // Start at the center of the screen for now...
  y_pos = SCREEN_HEIGHT - ([self getPic]->h * 2);   // Near the bottom of the screen...
  lives--;
  if (lives == 0) {
    return YES;
  }
  return NO;
}


@end


// A generic Opposing Object...
@interface OO : Object {
  
  int x_pos, y_pos;         // OO's current position...
  int x_speed, y_speed;
  
  int direction;            // 0 for left, 1 for right...
  
  BITMAP *pic;              // Stores the picture!...
  
}

- initWithImage: (char *) imageFilename andX: (int) start_x andY: (int) start_y;
- update;
- (BOOL) shoot: (int) CCpos;
- (BITMAP *) getPic;
- (int) getXPos;
- (int) getYPos;

@end


@implementation OO


// Construct an OO!!...
- init {
  self = [super init];
  if (self) {
    direction = 1;
    x_pos = 0;
    y_pos = 0;
    x_speed = 0;
    y_speed = 0;
    pic = NULL;
  }
  return self;
}

  
- initWithImage: (char *) nameSent andX: (int) start_x andY: (int) start_y {
  PALLETE my_pallete;
  self = [self init];
  if (self) {
    pic = load_bitmap(nameSent, my_pallete);
    set_palette(my_pallete);
    x_pos = start_x;
    y_pos = start_y;
    x_speed = 1;
  }
  return self;
}


- free {
  destroy_bitmap(pic);
  return [super free];
}


// Update each OO each game loop...
- update {
  
  // Move the OO in the correct direction...
  if (direction == 0) {
    x_pos -= x_speed;
  } else {
    x_pos += x_speed;
  }
  
  // Check for the hitting the edge of the screen!...	
  if (x_pos >= SCREEN_WIDTH - [self getPic]->w) {
    x_pos = SCREEN_WIDTH - [self getPic]->w;
    direction = 0;
  }
  
  if (x_pos <= 0) {
    x_pos = 0;
    direction = 1;
  }
  
  return (self);
  
}


- (BOOL) shoot: (int) CCpos {
  
  // Code here whenever you want the OOs to shoot...
  
  // Randomly run through numbers, to see if the OO will shoot...
  // One of the simplest AIs I can think of  =)  ...
  if (random_number(0, 500) == 0) {
    return YES;
  }
  
  // Put a little bit more often random generator here...
  // If true, and are facing the CC, shoot...
  if (CCpos == x_pos && random_number(0, 4) == 0) {
    return YES;
  }
  
  return NO;
  
}


- (BITMAP *) getPic {
  return pic;
}


- (int) getXPos {
  return x_pos;
}


- (int) getYPos {
  return y_pos;
}


@end


@interface World : Object {
  
  // NOTE:: Later, add another screen component, draw to it, then display. Buffer!!...
  
  CC *cc1;                          //The good guy!...
  OO *oo[MAX_NUM_OF_SPRITES];       //The list of OOs...
  ATK *CCatk[MAX_NUM_OF_SPRITES];   //The list of CC ATKs...
  ATK *OOatk[MAX_NUM_OF_SPRITES];   //The list of OO ATKs...
  
  BITMAP *background;               //Stores the background pic...
  BITMAP *title;
  
  BOOL keepPlaying;
  
  BITMAP *buffer;                   //Draw to this, then display buffer...
  
}

- update;
- draw;
- (BOOL) keepPlaying;

@end


@implementation World


- init {
  
  PALLETE my_pallete;
  int count;
  int i, j;
  
  self = [super init];
  
  if (self) {
    
    cc1 = nil;
    
    for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
      oo[i] = nil;
    }
    
    for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
      CCatk[i] = nil;
    }
    
    for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
      OOatk[i] = nil;
    }
    
    // Initialize the GameWorld objects...
    cc1 = [[CC alloc] initWithLives: 5];
    
    //oo = new OO[40];
    
    count = 0;
    
    // Initialize the OOs however you want!...
    for (i = 0; i < 3; i++) {
      for (j = 0; j < 5; j++) {
        oo[count] = [[OO alloc] initWithImage: "flower.bmp" andX: j * 60 + 20 andY: i * 60 + 20];
        count++;
      }
    }
    
    background = load_bitmap("background.bmp", my_pallete);
    title = load_bitmap("title.bmp", my_pallete);
    set_palette(my_pallete);
    
    keepPlaying = YES;
    
    buffer = create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT);
    clear_to_color(buffer, BLACK);
    
  }
  
  return self;
  
}


- free {
  
  int i;
  
  [cc1 free];
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    [oo[i] free];
  }
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    [CCatk[i] free];
  }
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    [OOatk[i] free];
  }
  
  destroy_bitmap(background);
  destroy_bitmap(title);
  
  destroy_bitmap(buffer);
  
  return self;
  
}

  
- update {
  
  int i, j;
  
  // Update the CC...
  [cc1 update];
  
  if ([cc1 shoot]) {
    i = 0;
    while (i < MAX_NUM_OF_CC_ATK && CCatk[i] != nil) {
      i++;
    }
    if (i < MAX_NUM_OF_CC_ATK) {
      CCatk[i] = [[ATK alloc] initWithImage: "stinger.bmp" andX: [cc1 getXPos] + 15 andY: [cc1 getYPos] + 15 andType: 1];
    }
  }	
  
  // Update the OOs...
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    if (oo[i] != nil) {
      
      if ([oo[i] shoot: [cc1 getXPos]]) {
        j = 0;
        while (j < MAX_NUM_OF_SPRITES && OOatk[j] != nil) {
          j++;
        }
        if (i < MAX_NUM_OF_SPRITES) {
          OOatk[j] = [[ATK alloc] initWithImage: "pollen.bmp" andX: [oo[i] getXPos] + 15 andY: [oo[i] getYPos] + 15 andType: 2];
        }
      }
      
      [oo[i] update];
      
    }
  }
  
  // Update the CC ATKs...
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    
    if (CCatk[i] != nil) {
      
      // Check for OO hit!!...
      for (j = 0; j < MAX_NUM_OF_SPRITES; j++) {
        if (oo[j] != nil) {
          if (CCatk[i] != nil) {
            if ([CCatk[i] getXPos] > [oo[j] getXPos] && [CCatk[i] getXPos] + [CCatk[i] getPic]->w < [oo[j] getXPos] + [oo[j] getPic]->w) {
              if ([CCatk[i] getYPos] > [oo[j] getYPos] && [CCatk[i] getYPos] + [CCatk[i] getPic]->h < [oo[j] getYPos] + [oo[j] getPic]->h) {
                // Kill the ATK and the hit OO!!...
                [CCatk[i] free];
                CCatk[i] = nil;
                [oo[j] free];
                oo[j] = nil;
              }
            }
          }
        }
      }
      
      // After all that checking, if the CC ATK is still there, update it!...
      if (CCatk[i] != nil) {
        [CCatk[i] update];
        if ([CCatk[i] getYPos] < 0) {
          [CCatk[i] free];
          CCatk[i] = nil;
        }
      }
      
    }
    
  }
  
  // Update the OO ATKs...
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    if (OOatk[i] != nil) {
      
      // YOU LEFT OFF HERE!!
      //if (OOatk[i] != nil) {
        [OOatk[i] update];
        if ([OOatk[i] getYPos] > SCREEN_HEIGHT) {
          [OOatk[i] free];
          OOatk[i] = nil;
        }
      //}
      
    }
  }
  
  return self;
  
}


- draw {
  
  int i;
  
  // Ready the buffer and ready the Graphics...
  //buffer = createImage (640,480);
  //Graphics bg = buffer.getGraphics();	
  
  draw_sprite(buffer, background, 0, 0);
  draw_sprite(buffer, [cc1 getPic], [cc1 getXPos], [cc1 getYPos]);
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    if (oo[i] != nil) {
      draw_sprite(buffer, [oo[i] getPic], [oo[i] getXPos], [oo[i] getYPos]);
    }
  }
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    if (CCatk[i] != nil) {
      draw_sprite(buffer, [CCatk[i] getPic], [CCatk[i] getXPos], [CCatk[i] getYPos]);
    }
  }
  
  for (i = 0; i < MAX_NUM_OF_SPRITES; i++) {
    if (OOatk[i] != nil) {
      draw_sprite(buffer, [OOatk[i] getPic], [OOatk[i] getXPos], [OOatk[i] getYPos]);
    }
  }
  
  // Finalize the draw!...
  vsync();
  blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);
  
  return self;
  
}


- (BOOL) keepPlaying {
  return keepPlaying;
}


@end


// The main game world...
@interface Game : Object {
  // Create the game window here, and construct it...
  World *world;
  // YOU LEFT OFF HERE!!
  //long timer;
}

- play;

@end


@implementation Game


- init {
  self = [super init];
  if (self) {
    // Initialize the window!...
    world = [[World alloc] init];
    //screen.setTitle ("Bee Battle!!");
    //screen.setSize (640,480);
    //screen.setResizable (false);
    //screen.setLocation (30,30);
    //screen.setVisible (true);
    // YOU LEFT OFF HERE!!
    //timer = System.currentTimeMillis ();
  }
  return self;
}


- free {
  [world free];
  return [super free];
}


// Call this to get the game started. It will finish when the game is over!...
- play {
  
  int timemark;
  
  timer = 0;
  
  while (!key[KEY_ESC] && [world keepPlaying]) {
    
    while (timer == 0) {
      rest(100 / GAME_TICKER);
    }
    
    while (timer > 0) {
      
      timemark = timer;
      
      // Update the game...
      [world update];
      
      timer--;
      
      if (timemark <= timer) {
        break;
      }
      
    }
    
    // Draw Screen!!...
    [world draw];
    
    // Wait!!...
    // (try to replace this with a nicer, friendlier, faster wait)...
    // Fixed: Please see the use of the timer above.
    //while (System.currentTimeMillis() - timer < 16);
    //timer = System.currentTimeMillis ();	
    
  }
  
  return self;
  
}


@end


/**
 * To keep the game running at the correct frames per second
 */
void do_timer(void) {
  timer++;
} END_OF_FUNCTION (do_timer);


int main() {
  
  Game *game;
  
  allegro_init();
  
  install_timer();
  
  LOCK_VARIABLE(timer);
  LOCK_FUNCTION(do_timer);
  install_int_ex(do_timer, BPS_TO_TIMER(GAME_TICKER));
  
  srand(time(NULL));
  
  install_keyboard();
  
  set_color_depth(COLOR_DEPTH);
  set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);
  clear_to_color(screen, makecol(0, 0, 0));
  
  game = [[Game alloc] init];
  [game play];
  [game free];
  
  return 0;
  
}
END_OF_MAIN()
