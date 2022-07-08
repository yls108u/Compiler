SRCFILES := $(wildcard *.java)
CFLAGS := -cp antlr-3.5.2-complete-no-st3.jar:.
result : $(SRCFILES)
	java -jar antlr-3.5.2-complete-no-st3.jar
	java -jar antlr-3.5.2-complete-no-st3.jar mylexer.g
	javac $(CFLAGS) *.java
	gcc test1.c -o test1
	gcc test2.c -o test2
	gcc test3.c -o test3
	gcc test4.c -o test4
clean :
	rm -f *.class
	rm -f mylexer.java
	rm -f mylexer.tokens
	rm -f test1
	rm -f test2
	rm -f test3
	rm -f test4
