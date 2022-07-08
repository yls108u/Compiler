SRCFILES := $(wildcard *.java)
CFLAGS := -cp antlr-3.5.2-complete-no-st3.jar:.
result : $(SRCFILES)
	java -jar antlr-3.5.2-complete-no-st3.jar
	java -jar antlr-3.5.2-complete-no-st3.jar myInterp.g
	javac $(CFLAGS) *.java
clean :
	rm -f *.class
	rm -f myInterpParser.java
	rm -f myInterpLexer.java
	rm -f *.tokens
