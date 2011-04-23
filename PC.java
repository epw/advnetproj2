/**
 * Java-side application for recording LED state information
 * 
 *
 * @author Eric Willisson <epw@wpi.edu>
 * @date 20110422
 */

import java.io.IOException;

import java.util.LinkedList;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class PC implements MessageListener {

  private MoteIF moteIF;

  public static long start_time;

  private class Event {
		private int id;
		private boolean state;
		long timestamp;
		
		public Event (short id, short state) {
			this.id = id;
			this.state = (state != 0);
			this.timestamp = System.currentTimeMillis () - start_time;
		}

		private String offOrOn () {
			if (state) {
				return "on";
			}
			return "off";
		}
		
		public String toString () {
			return "[" + timestamp / 1000 + "] Mote " + id + " turned " + offOrOn();
		}
  }

  private static LinkedList<Event> events;
  
  public PC(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new SerialData(), this);
  }

  public void messageReceived(int to, Message message) {
    SerialData msg = (SerialData)message;
    events.addLast (new Event (msg.get_id(), msg.get_state()));
  }
  
  private static void usage() {
    System.err.println("usage: java PC [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }
    
    MoteIF mif = new MoteIF(phoenix);
    
    events = new LinkedList<Event> ();

    start_time = System.currentTimeMillis();
    
    PC serial = new PC(mif);

    while (true) {
    	int redMote = 0, greenMote = 0;
    	
    	Thread.sleep (60000);
    	for (Event e : events) {
    		System.out.println (e);
    		if (e.id == 0 && e.state) {
    			redMote++;
    		}
    		if (e.id == 1 && e.state) {
    			greenMote++;
    		}
    	}
    	System.out.println ("Red mote went above its threshold " + redMote + " times.");
    	System.out.println ("Green mote went above its threshold " + greenMote + " times.");
    	events = new LinkedList<Event> ();
    }
  }


}
