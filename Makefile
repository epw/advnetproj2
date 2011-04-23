COMPONENT=SenseAppC
C2420_CHANNEL=14
BUILD_EXTRA_DEPS = SerialData.class
CLEAN_EXTRA = RadioDataMsg.py RadioDataMsg.class RadioDataMsg.java SerialData.class SerialData.java

SerialData.class: SerialData.java
	javac SerialData.java

SerialData.java: SerialData.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=SerialData SerialData.h serial_data_msg -o $@

include $(MAKERULES)
