/*
	Final Project -Game
	Todd Burnop
	David Rawson Couzelis
	-Function 12 Software
	Start::11.20.2000

	
*/


import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import java.util.*;
import java.lang.*;



class MainSystem 
{

	public static void main (String args[])  
	{
		
		GameWorld game = new GameWorld ();	
		
		game.playGameWorld ();

	}
}





//A generic Opposing Object...
class OO 
{

	boolean alive;                      //If the OO is still alive...
	protected int x_pos, y_pos;         //OO's current position...
	protected int change_x, change_y;   //The change in position each game update...
	protected int direction;            //0 for left, 1 for right...
	
	protected Image pic;                //Stores the picture!...
	
	
	
	
	
	public Image getPic ()  {  return (pic);  }
	public int getXPos ()  {  return (x_pos);  }
	public int getYPos ()  {  return (y_pos);  }
	
	
	//Construct an OO!!...
	OO (String nameSent, int start_x, int start_y)
	{
		alive = true;
		direction = 1;

		pic = Toolkit.getDefaultToolkit().getImage(nameSent);
			
		x_pos = start_x;
		y_pos = start_y;
	
	}


	//Update each OO each game loop...
	public OO update ()
	{
	
		if (alive)
		{
		
			//Move OO in the correct direction...
			if (direction == 0)
				x_pos -= 2;
			if (direction == 1)
				x_pos += 2;
	
			//Check for the hitting the edge of the screen!...	
			if (x_pos >= 640-50)
			{
				x_pos = 640-50;
				direction = 0;
			}
			if (x_pos <= 0)
			{
				x_pos = 0;
				direction = 1;
			}
			
			return (this);
		}
		else  return (null);
		
	}
	
	
	
	public boolean shoot (int CCpos)
	{
		//Code here whenever you want the OOs to shoot...
		
		//Randomly run through numbers, to see if the OO will shoot...
		//One of the simplest AIs I can think of  =)  ...
		if ((int)(java.lang.Math.random () * 500) == 0)
				return (true);
		
		
		//Put a little bit more often random generator here...
		//If true, and are facing the CC, shoot...
		if (CCpos == x_pos && (int)(java.lang.Math.random () * 4) == 0)
			return (true);
		
		
		else  return (false);
	
	}
	

}



class ATK
{


	int x_pos, y_pos;          //Current ATK position...
	int change_x, change_y;    //The change in position each game update...
	int type;                  //1 for CC, 2 for OO...
	
	Image pic;                 //The picture of the ATK...

	


	public Image getPic ()  {  return (pic);  }
	public int getXPos ()  {  return (x_pos);  }
	public int getYPos ()  {  return (y_pos);  }

	
	ATK (String nameSent, int x, int y, int typeSent)
	{
		x_pos = x;  y_pos = y;

		type = typeSent;
		if (type == 1)  {  change_x = 0;  change_y = -15;  }
		else  if (type == 2)  {  change_x = 0;  change_y = 5;  }
		
		pic = Toolkit.getDefaultToolkit().getImage(nameSent);
	
	}
	
	
	public ATK update ()
	{
		x_pos += change_x;
		y_pos += change_y;

		//Check if the ATK is off the screen...
		if (x_pos<=0-20 || x_pos>=640 || y_pos<=0-20 || y_pos>=480)
			return (null);  
		else  return (this);	
			
	}


}




class GameWindow extends Frame 
{

	//NOTE::  Later, add another screen component, draw to it, then display.  Buffer!!...


	//NEW::  Try the idea that, since everything will take place in the GameWindow,
	//everything should be created in that...
	//NOTE::  Don't forget to validate after every redraw!!...

	protected static CC cc1;        //The good guy!...
	protected static OO[] oo;       //The list of OOs...
	protected static ATK[] CCatk;   //The list of CC ATKs...
	protected static ATK[] OOatk;   //The list of OO ATKs...
	
	
	Image background;               //Stores the background pic...
	Image title;
	char inkey;


	public boolean keepPlaying;

	protected Image buffer;         //Draw to this, then display buffer...


	//Override Update to minimize flicker...
	//(Don't ask me why!)...
	public void update (Graphics g) 
	{
		paint (g);
	}


	
	GameWindow ()
	{
	
	
		//Initialize the GameWorld objects...
		cc1 = new CC (5);    
	
		oo = new OO[40];
		
		
		int count = 0;
		//Initialize the OOs however you want!...
		for (int i=0; i<3; i+=1)
			for (int j=0; j<5; j+=1)
			{
				oo[count] = new OO ("oo1.gif", j*60+20,i*60+20);
				count += 1;
			}
	
		CCatk = new ATK[5];
		OOatk = new ATK[20];
		for (int i=0; i<5; i+=1)
			CCatk[i] = null;
		for (int i=0; i<20; i+=1)
			OOatk[i] = null;
	
		background = Toolkit.getDefaultToolkit().getImage("bg.gif");
		title = Toolkit.getDefaultToolkit().getImage("title.gif");
		inkey = '~';
	
		keepPlaying = true;

	
		//Ha!  WindowListeners ain't so hard...
		addWindowListener (new WindowAdapter ()
			{
			public  void windowClosing (WindowEvent e)
				{
					System.exit (0);
				}
			}  );


		//For key input...
		addKeyListener (new KeyAdapter ()
			{
			public void keyPressed (KeyEvent e)
				{
					inkey = e.getKeyChar();
				}
			public void keyReleased (KeyEvent e)
				{
					inkey = '~';
				}
			}  );
			
	
	}
	
	
	public void paint (Graphics g)
	{
	
		//Ready the buffer and ready the Graphics...
		buffer = createImage (640,480);
		Graphics bg = buffer.getGraphics();	
		//bg = g;
		
		bg.drawImage (background, 0,0, null);		
		bg.drawImage (cc1.getPic (), cc1.getXPos(),cc1.getYPos(), null);
		
		for (int i=0; i<40; i+=1)
			if (oo[i] != null)
				bg.drawImage (oo[i].getPic (), oo[i].getXPos(),oo[i].getYPos(), null);
		
		for (int i=0; i<5; i+=1)
			if (CCatk[i] != null)
				bg.drawImage (CCatk[i].getPic (), CCatk[i].getXPos(),CCatk[i].getYPos(), null);
		for (int i=0; i<20; i+=1)
			if (OOatk[i] != null)
				bg.drawImage (OOatk[i].getPic (), OOatk[i].getXPos(),OOatk[i].getYPos(), null);
		
		//Finalize the draw!...
		g.drawImage (buffer, 0,0, null);
		
		
	}


	

	public void updateEverything ()
	{
		
		//Update the CC...
		cc1.update (inkey);
		//No more than 5 CC ATKs on screen...
		if (cc1.shoot (inkey))
		{
			int j;
			for (j=0; CCatk[j]!=null && j<4; j+=1)
				;
			CCatk[j] = new ATK ("ccatk.gif", cc1.getXPos()+15,cc1.getYPos()+15, 1);	
			inkey = '~';

		}
	
	
		//Update the OOs...
		for (int i=0; i<40; i+=1)
			if (oo[i] != null)
			{
				
				if (oo[i].shoot(cc1.getXPos()))
				{
					int j;
					for (j=0; OOatk[j]!=null && j<20; j+=1)
						;
					OOatk[j] = new ATK ("ooatk.gif", oo[i].getXPos()+15,oo[i].getYPos()+15, 2);	
				
				}
				
				
				oo[i] = oo[i].update ();	
				
			}
	
		
		//Update the CC ATKs...
		for (int i=0; i<5; i+=1)
		{	
			
			if (CCatk[i] != null)
			{
				
				//Check for OO hit!!...
				for (int j=0; j<40; j+=1)
					if (oo[j]!=null)
						if (CCatk[i]!=null)
							if (CCatk[i].getXPos()>oo[j].getXPos() && (CCatk[i].getXPos()+20)<(oo[j].getXPos()+50))
								if (CCatk[i].getYPos()>oo[j].getYPos() && (CCatk[i].getYPos()+20)<(oo[j].getYPos()+50))
								{
									//Kill the ATK and the hit OO!!...
									CCatk[i] = null;
									oo[j] = null;
								}
						
				//After all that checking, if the CC ATK is still there, update it!...
				if (CCatk[i] != null)
					CCatk[i] = CCatk[i].update ();

			}
			
		}
		
		//Update the OO ATKs...
		for (int i=0; i<20; i+=1)
		{
			if (OOatk[i] != null)
			{
			
				//YOU LEFT OFF HERE!!			
			
				if (OOatk[i] != null)
					OOatk[i] = OOatk[i].update();
				
				
			}	


		}


		
	}


}




//The main game world...
class GameWorld 
{

	
	//Create the game window here, and construct it...
	GameWindow screen;
	long timer;	
	
	
	public GameWorld ()
	{
	
		//Initialize the window!...
		screen = new GameWindow ();
		
		screen.setTitle ("Bee Battle!!");
		screen.setSize (640,480);
		screen.setResizable (false);
		screen.setLocation (30,30);
		screen.setVisible (true);
		
		timer = System.currentTimeMillis ();	
		
	}




	//Call this to get the game started.  It will finish when the game is over!...
	public void playGameWorld () 
	{
						
		while (screen.keepPlaying)
		{
			//Update the game...
			//Send the current inkey...
			screen.updateEverything ();
			
			//Draw Screen!!...
			screen.repaint ();
			//screen.validate();

			//Wait!!...			
			//(try to replace this with a nicer, friendlier, faster wait)...
			while (System.currentTimeMillis() - timer < 16);
			timer = System.currentTimeMillis ();	
			
		
		}
	
	
	}


}






//A generic Controllable Character...
class CC 
{

	protected int lives;               //Amount of remaining lives...
	protected int x_pos, y_pos;        //The position of the CC...
	
	protected Image pic1, pic2;        //Stores the two pictures to be animated...
	protected int frame;               //Which tile to display now...


	//Construct a CC!!...
	CC (int livesSent)
	{
		lives = livesSent;
		x_pos = 640/2;     //Start at the center of the screen for now...
		y_pos = 480-100;   //Near the bottom of the screen...
		
		pic1 = Toolkit.getDefaultToolkit().getImage("cc1.gif");
		pic2 = Toolkit.getDefaultToolkit().getImage("cc2.gif");
		frame = 1;

	}


	//Ask the CC if it's ready to shoot!...
	public boolean shoot (char inkey)
	{
		if (inkey == 'z' || inkey == ' ')
			return (true);
		else  return (false);

	}


 	public void update (char inkey)  
	{  

		//Update the pos (keyboard input)...
		if (inkey == 'j')
			x_pos -= 15;
		else  if (inkey == 'l')
			x_pos += 15;
		
		
		//Check out of bounds position!...
		if (x_pos > 640-50)
			x_pos = 640-50;
		else  if (x_pos < 0)
			x_pos = 0;
		if (y_pos > 480-50)
			y_pos = 48050;
		else  if (y_pos < 0)
			y_pos = 0;		
		
	
	}


	public Image getPic ()  
	{  
		if (frame == 1)  {  frame=2;  return (pic1);  }
		else  {  frame=1;  return (pic2);  }
	}
	public int getXPos ()  {  return (x_pos);  }
	public int getYPos ()  {  return (y_pos);  }



	//When the CC is hit, kill him!...
	//Return true when there are no more extra lives...
	public boolean kill ()
	{
		x_pos = 640/2;
		lives -= 1;
		if (lives < 1)
			return (true);
		else
			return (false);
	}


}


