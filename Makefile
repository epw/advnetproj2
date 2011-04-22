COMPONENT=SenseAppC
C2420_CHANNEL=14
#BUILD_EXTRA_DEPS = RadioDataMsg.py RadioDataMsg.class
#CLEAN_EXTRA = RadioDataMsg.py RadioDataMsg.class RadioDataMsg.java

#RadioDataMsg.py: RadioDataToLeds.h
#	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=RadioDataMsg RadioDataToLeds.h radio_data_msg -o $@

#RadioDataMsg.class: RadioDataMsg.java
#	javac RadioDataMsg.java

#RadioDataMsg.java: RadioDataToLeds.h
#	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=RadioDataMsg RadioDataToLeds.h radio_data_msg -o $@

include $(MAKERULES)
