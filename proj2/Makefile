SRCFILES := $(wildcard *.java)
CFLAGS := -cp antlr-3.5.2-complete-no-st3.jar:.
result : $(SRCFILES)
	java -jar antlr-3.5.2-complete-no-st3.jar
	java -jar antlr-3.5.2-complete-no-st3.jar myparser.g
	javac $(CFLAGS) *.java
clean :
	rm -f *.class
	rm -f myparserLexer.java
	rm -f myparserParser.java
	rm -f myparser.tokens
