## Rutas para OSX

calc_token.exe: calc_token.l calc_token.y
	bison -d calc_token.y
	flex calc_token.l
	g++ -Wall -o $@ calc_token.tab.c lex.yy.c -lfl

clean:
	rm calc_token.tab.* lex.yy.c calc_token.exe data.json calc_token.exe.stackdump