/**
 * Java-side application for recording LED state information
 * 
 *
 * @author Eric Willisson <epw@wpi.edu>
 * @date 20110422
 */

import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class PC implements MessageListener {

  private MoteIF moteIF;
  
  public PC(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new RadioDataMsg(), this);
  }

  public void sendPackets() {
    int counter = 0;
    RadioDataMsg payload = new RadioDataMsg();
    
    try {
      while (true) {
	System.out.println("Sending packet " + counter);
//	payload.set_counter(counter);
	moteIF.send(0, payload);
	counter++;
	try {Thread.sleep(1000);}
	catch (InterruptedException exception) {}
      }
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }

  public void messageReceived(int to, Message message) {
    RadioDataMsg msg = (RadioDataMsg)message;
//    System.out.println("Received packet sequence number " + msg.get_counter());
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
	
    PC serial = new PC(mif);

    serial.sendPackets();
  }


}
