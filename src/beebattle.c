#include <allegro.h>
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>

#define FPS 60

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define COLOR_DEPTH 24

#define BLACK (makecol(0, 0, 0))

#define MAX_NUM_OF_SPRITES 256
#define MAX_NUM_OF_CC_ATK 2

#define ATK_TYPE_CC 1
#define ATK_TYPE_OO 2

#define DIRECTION_LEFT 0
#define DIRECTION_RIGHT 1

static volatile int ticks = 0;
static PALETTE palette;

int random_number(int low, int high)
{
    return (rand() % (high - low + 1)) + low;
}

// ATK
// An "Attack"
typedef struct
{
    // Current ATK position
    int x_pos;
    int y_pos;

    int x_speed;
    int y_speed;
    
    BITMAP *pic;
 
    // Can be ATK_TYPE_CC or ATK_TYPE_OO
    int type;
  
} ATK;

ATK *ATK_init(char *filename, int start_x, int start_y, int type)
{
    ATK *atk = (ATK *)malloc(sizeof(ATK));
    assert(atk);

    atk->x_pos = start_x;
    atk->y_pos = start_y;

    atk->x_speed = 0;

    atk->type = type;
    
    if (atk->type == ATK_TYPE_CC) {
        atk->y_speed = -6;
    } else if (atk->type == ATK_TYPE_OO) {
        atk->y_speed = 2;
    }
    
    atk->pic = load_bitmap(filename, palette);
    assert(atk->pic);
    set_palette(palette);

    return atk;
}

void ATK_free(ATK *atk)
{
    if (!atk) {
        return;
    }
    destroy_bitmap(atk->pic);
    free(atk);
}

void ATK_update(ATK *atk)
{
    atk->x_pos += atk->x_speed;
    atk->y_pos += atk->y_speed;
    
    // Check if the ATK is off the screen
    //if (atk->x_pos <= -atk->pic->w || atk->x_pos >= SCREEN_WIDTH || atk->y_pos <= -atk->pic->h || atk->y_pos >= SCREEN_HEIGHT) {
    //    return false;
    //}
    
    //return true;
}

// CC
// A "Controllable Character"
typedef struct
{
    // Remaining lives
    int lives;

    int x_pos;
    int y_pos;
    
    // The two frames of animation for the CC
    BITMAP *pic1;
    BITMAP *pic2;

    // Which frame of animation to use currently, can be 1 or 2
    int frame;

    // Counts how long the shoot button has been held
    int keyCount;            
 
} CC;

CC *CC_init(int lives)
{
    CC *cc = (CC *)malloc(sizeof(CC));
    assert(cc);

    cc->pic1 = load_bitmap( PKGDATADIR "/images/bee1.bmp", palette);
    assert(cc->pic1);
    cc->pic2 = load_bitmap( PKGDATADIR "/images/bee2.bmp", palette);
    assert(cc->pic2);
    set_palette(palette);

    // Start at the center of the screen, near the bottom
    cc->x_pos = (SCREEN_WIDTH / 2) - (cc->pic1->w / 2);
    cc->y_pos = SCREEN_HEIGHT - (cc->pic1->h * 2);

    cc->lives = lives;
    cc->keyCount = 0;

    cc->frame = 1;

    return cc;
}

void CC_free(CC *cc)
{
    destroy_bitmap(cc->pic1);
    destroy_bitmap(cc->pic2);
    free(cc);
}

// Ask the CC if it's ready to shoot!
bool CC_shoot(CC *cc)
{
    if (key[KEY_SPACE]) {
        if (cc->keyCount == 0) {
            cc->keyCount = 20;
            return true;
        } else {
            cc->keyCount--;
            return false;
        }
    }

    cc->keyCount = 0;

    return false;
}

void CC_update(CC *cc)
{
    //Update the pos (keyboard input)
    if (key[KEY_LEFT]) {
        cc->x_pos -= 4;
    }
    
    if (key[KEY_RIGHT]) {
        cc->x_pos += 4;
    }
    
    // Check out of bounds position!
    if (cc->x_pos > SCREEN_WIDTH - cc->pic1->w) {
        cc->x_pos = SCREEN_WIDTH - cc->pic1->w;
    } else if (cc->x_pos < 0) {
        cc->x_pos = 0;
    }
    
    if (cc->y_pos > SCREEN_HEIGHT - cc->pic1->h) {
        cc->y_pos = SCREEN_HEIGHT - cc->pic1->h;
    } else if (cc->y_pos < 0) {
        cc->y_pos = 0;
    }
}

BITMAP *CC_getPic(CC *cc)
{
    if (cc->frame == 1) {
        cc->frame = 2;
        return cc->pic1;
    } else {
        cc->frame = 1;
        return cc->pic2;
    }
}

// When the CC is hit, kill him!
// Return true when there are no more extra lives
bool CC_kill(CC *cc)
{
    // Reset the CC starting position
    cc->x_pos = (SCREEN_WIDTH / 2) - (cc->pic1->w / 2);
    cc->y_pos = SCREEN_HEIGHT - (cc->pic1->h * 2);

    cc->lives--;

    if (cc->lives == 0) {
      return true;
    }

    return false;
}

// OO
// An "Opposing Object"
typedef struct
{
    int x_pos;
    int y_pos;

    int x_speed;
    int y_speed;
    
    // Can be DIRECTION_LEFT or DIRECTION_RIGHT
    int direction;
    
    BITMAP *pic;
} OO;

OO *OO_init(char *filename, int start_x, int start_y)
{
    OO *oo = (OO *)malloc(sizeof(OO));
    assert(oo);

    oo->pic = load_bitmap(filename, palette);
    assert(oo->pic);
    set_palette(palette);

    oo->x_pos = start_x;
    oo->y_pos = start_y;

    oo->x_speed = 1;
    oo->y_speed = 0;

    oo->direction = DIRECTION_RIGHT;

    return oo;
}

void OO_free(OO *oo)
{
    if (!oo) {
        return;
    }
    destroy_bitmap(oo->pic);
    free(oo);
}

// Update each OO each game loop
void OO_update(OO *oo)
{
    // Move the OO in the correct direction
    if (oo->direction == DIRECTION_LEFT) {
        oo->x_pos -= oo->x_speed;
    } else {
        oo->x_pos += oo->x_speed;
    }
    
    // Check for the hitting the edge of the screen!
    if (oo->x_pos >= SCREEN_WIDTH - oo->pic->w) {
        oo->x_pos = SCREEN_WIDTH - oo->pic->w;
        oo->direction = DIRECTION_LEFT;
    }
    
    if (oo->x_pos <= 0) {
        oo->x_pos = 0;
        oo->direction = DIRECTION_RIGHT;
    }
}

bool OO_shoot(OO *oo, int CCpos)
{
    // Code here whenever you want the OOs to shoot
    
    // Randomly run through numbers, to see if the OO will shoot
    // One of the simplest AIs I can think of =)
    if (random_number(0, 500) == 0) {
        return true;
    }
    
    // Put a little bit more often random generator here
    // If true, and are facing the CC, shoot
    if (CCpos == oo->x_pos && random_number(0, 4) == 0) {
        return true;
    }
    
    return false;
}

typedef struct
{
    // The good guy!
    CC *cc1;

    // The list of bad guys
    OO *oo[MAX_NUM_OF_SPRITES];

    // The list of good guy attacks
    ATK *CCatk[MAX_NUM_OF_SPRITES];

    // The list of bad guy attacks
    ATK *OOatk[MAX_NUM_OF_SPRITES];
    
    BITMAP *background;
    BITMAP *title;
    
    bool keepPlaying;
    
    // Used for double buffering
    BITMAP *buffer;
  
} WORLD;

WORLD *WORLD_init()
{
    WORLD *world = (WORLD *)malloc(sizeof(WORLD));
    assert(world);

    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        world->oo[i] = NULL;
    }
    
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        world->CCatk[i] = NULL;
    }
    
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        world->OOatk[i] = NULL;
    }
    
    // Initialize the game world
    world->cc1 = CC_init(5);
    
    int n = 0;
    
    // Initialize the OOs however you want!
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 5; col++) {
            world->oo[n] = OO_init( PKGDATADIR "/images/flower.bmp", (col * 60) + 20, (row * 60) + 20);
            n++;
        }
    }
    
    world->background = load_bitmap( PKGDATADIR "/images/background.bmp", palette);
    assert(world->background);
    //world->title = load_bitmap( PKGDATADIR "/images/title.bmp", palette);
    //assert(world->title);
    set_palette(palette);
    
    world->keepPlaying = true;
    
    world->buffer = create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT);
    clear_to_color(world->buffer, BLACK);
      
    return world;
}

void WORLD_free(WORLD *world)
{
    CC_free(world->cc1);
 
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        OO_free(world->oo[i]);
    }
  
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        ATK_free(world->CCatk[i]);
    }
  
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        ATK_free(world->OOatk[i]);
    }
  
    destroy_bitmap(world->background);
    destroy_bitmap(world->title);
  
    destroy_bitmap(world->buffer);
  
    free(world);
}

void WORLD_update(WORLD *world)
{
    // Update the CC
    CC_update(world->cc1);
  
    if (CC_shoot(world->cc1)) {

        int i = 0;

        while (i < MAX_NUM_OF_CC_ATK && world->CCatk[i] != NULL) {
            i++;
        }

        if (i < MAX_NUM_OF_CC_ATK) {
            world->CCatk[i] = ATK_init( PKGDATADIR "/images/stinger.bmp" , world->cc1->x_pos + 15, world->cc1->y_pos + 15, ATK_TYPE_CC);
        }
    }	
  
    // Update the OOs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {

        if (world->oo[i] != NULL) {
      
            // Update the OO
            OO_update(world->oo[i]);
      
            if (OO_shoot(world->oo[i], world->cc1->x_pos)) {

                int j = 0;

                while (j < MAX_NUM_OF_SPRITES && world->OOatk[j] != NULL) {
                    j++;
                }

                if (j < MAX_NUM_OF_SPRITES) {
                    world->OOatk[j] = ATK_init( PKGDATADIR "/images/pollen.bmp", world->oo[i]->x_pos + 15, world->oo[i]->y_pos + 15, ATK_TYPE_OO);
                }
            }
      
        }
    }
  
    // Update the CC ATKs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
      
        if (world->CCatk[i] != NULL) {
          
            // Check for OO hit!
            for (int j = 0; j < MAX_NUM_OF_SPRITES; j++) {
                if (world->oo[j] != NULL && world->CCatk[i] != NULL) {
                    if (world->CCatk[i]->x_pos > world->oo[j]->x_pos && world->CCatk[i]->x_pos + world->CCatk[i]->pic->w < world->oo[j]->x_pos + world->oo[j]->pic->w) {
                        if (world->CCatk[i]->y_pos > world->oo[j]->y_pos && world->CCatk[i]->y_pos + world->CCatk[i]->pic->h < world->oo[j]->y_pos + world->oo[j]->pic->h) {
                            // Kill the ATK and the hit OO!
                            ATK_free(world->CCatk[i]);
                            world->CCatk[i] = NULL;
                            OO_free(world->oo[j]);
                            world->oo[j] = NULL;
                        }
                    }
                }
            }
            
            // After all that checking, if the CC ATK is still there, update it!
            if (world->CCatk[i] != NULL) {

              ATK_update(world->CCatk[i]);

              // Destroy the attacks that leave the top of the screen
              if (world->CCatk[i]->y_pos < 0) {
                ATK_free(world->CCatk[i]);
                world->CCatk[i] = NULL;
              }
            }
          
        }
      
    }
  
    // Update the OO ATKs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {

      if (world->OOatk[i] != NULL) {
        
        ATK_update(world->OOatk[i]);

        // Destroy the attacks that leave the bottom of the screen
        if (world->OOatk[i]->y_pos > SCREEN_HEIGHT) {
          ATK_free(world->OOatk[i]);
          world->OOatk[i] = NULL;
        }
        
      }
    }
}

void WORLD_draw(WORLD *world)
{
    // Draw the background
    draw_sprite(world->buffer, world->background, 0, 0);

    // Draw the CC
    draw_sprite(world->buffer, CC_getPic(world->cc1), world->cc1->x_pos, world->cc1->y_pos);
    
    // Draw the OOs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        if (world->oo[i] != NULL) {
            draw_sprite(world->buffer, world->oo[i]->pic, world->oo[i]->x_pos, world->oo[i]->y_pos);
        }
    }
    
    // Draw the CC ATKs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        if (world->CCatk[i] != NULL) {
            draw_sprite(world->buffer, world->CCatk[i]->pic, world->CCatk[i]->x_pos, world->CCatk[i]->y_pos);
        }
    }
    
    // Draw OO ATKs
    for (int i = 0; i < MAX_NUM_OF_SPRITES; i++) {
        if (world->OOatk[i] != NULL) {
            draw_sprite(world->buffer, world->OOatk[i]->pic, world->OOatk[i]->x_pos, world->OOatk[i]->y_pos);
        }
    }
    
    // Finalize the draw!
    vsync();
    blit(world->buffer, screen, 0, 0, 0, 0, world->buffer->w, world->buffer->h);
}

typedef struct
{
    // Create the game window here, and construct it
    WORLD *world;
} GAME;

GAME *GAME_init()
{
    GAME *game = (GAME *)malloc(sizeof(GAME));
    assert(game);

    // Initialize the window!
    game->world = WORLD_init();

    //screen.setTitle ("Bee Battle!");
    //screen.setSize (640,480);
    //screen.setResizable (false);
    //screen.setLocation (30,30);
    //screen.setVisible (true);

    return game;
}

void GAME_free(GAME *game)
{
    WORLD_free(game->world);
    free(game);
}

// Call this to get the game started. It will finish when the game is over!
void GAME_play(GAME *game)
{
    int timemark = 0;

    // Reset the game ticker, just before starting
    ticks = 0;
    
    while (!key[KEY_ESC] && game->world->keepPlaying) {
      
        while (ticks == 0) {
            rest(100 / FPS);
        }
      
        while (ticks > 0) {
        
            timemark = ticks;
        
            // Update the game
            WORLD_update(game->world);
        
            ticks--;
        
            if (timemark <= ticks) {
                break;
            }
        
        }
      
        // Draw Screen!
        WORLD_draw(game->world);
    }
}

// To keep the game running at the correct frames per second
void update_ticks()
{
  ticks++;
} END_OF_FUNCTION (update_ticks);

int main(int argc, char **argv)
{
    allegro_init();
    
    install_timer();
    
    LOCK_VARIABLE(ticks);
    LOCK_FUNCTION(update_ticks);
    install_int_ex(update_ticks, BPS_TO_TIMER(FPS));
    
    srand(time(NULL));
    
    install_keyboard();
    
    // Setup the game screen
    set_color_depth(COLOR_DEPTH);
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);
    clear_to_color(screen, makecol(0, 0, 0));
    
    // Setup the game
    GAME *game = GAME_init();
  
    // PLAY!
    GAME_play(game);
  
    // Cleanup
    GAME_free(game);
    
    return 0;
}
END_OF_MAIN()
