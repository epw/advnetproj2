/*
 * Copyright (c) 2006, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitaet Berlin nor the names
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Revision -------------------------------------------------------------
 * $Revision: 1.4 $
 * $Date: 2006/12/12 18:22:49 $
 * @author: Jan Hauer
 * ========================================================================
 */

/**
 * 
 * Sensing demo application. See README.txt file in this directory for usage
 * instructions and have a look at tinyos-2.x/doc/html/tutorial/lesson5.html
 * for a general tutorial on sensing in TinyOS.
 *
 * @author Jan Hauer
 */

#include "Timer.h"
#include "RadioDataToLeds.h"

module SenseC
{
  uses {
    interface Boot;
    interface Leds;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
  }
}
implementation
{
  // current packet
  message_t packet;
  
  // mutex lock for packet operations
  bool locked = FALSE;
  
  // designates if LED should be on or not
  bool ledOn = FALSE;
  
  // the mote number (either 0 or 1)
  #define MOTE_ID 0

  // sampling frequency in binary milliseconds
  #define SAMPLING_FREQUENCY 250
  
  // light threshold
  #define LIGHT_THRES 150
  
  event void Boot.booted() {
    call AMControl.start();
  }
  
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
		call Timer.startPeriodic(SAMPLING_FREQUENCY);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }

  event void Timer.fired() 
  {
    call Read.read();

    if (locked) {return;}
    else {
      radio_data_msg_t* rcm = (radio_data_msg_t*)call Packet.getPayload(&packet, sizeof(radio_data_msg_t));
      if (rcm == NULL) {return;}

      rcm->data = MOTE_ID & (ledOn? 0x02 : 0x00);
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_data_msg_t)) == SUCCESS) {
			locked = TRUE;
      }
    }
  }


  event void Read.readDone(error_t result, uint16_t data) {
    if (result == SUCCESS){
    
    	if (data > LIGHT_THRES){
    		ledOn = TRUE;
    	} else {
    		ledOn = FALSE;
    	}
    }
  }
  
  
    event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
	    if (len != sizeof(radio_data_msg_t)) {return bufPtr;}
	    else {
		    radio_data_msg_t* rcm = (radio_data_msg_t*)payload;
		       
		    // if data from mote 0
		    if (rcm->data & MOTEMASK) {
		    		
		    	// If LED should be on, turn on
				if (rcm->data & LEDMASK){
					call Leds.led0On();
					
				// If LED should be off, turn off
				} else {
					call Leds.led0Off();
				}
		    } 
		    
		    // if data from mote 1
		    else {
		    
		    	// If LED should be on, turn on
		    	if (rcm->data & LEDMASK){
		    		call Leds.led1On();
		    		
		    	// If LED should be off, turn off
		    	} else {
		    		call Leds.led1Off();
		    	}
		    }
		}
	    return bufPtr;
  	}
  
    event void AMSend.sendDone(message_t* bufPtr, error_t error) {
	    if (&packet == bufPtr) {
	      locked = FALSE;
	    }
  	}
}
