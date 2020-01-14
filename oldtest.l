%{

#include <stdio.h>
#include <string.h>
int linecount=1;
int paracount=0;
int bracketcount=0;
%}

%option noyywrap
end			[<<EOF>>] 
newline		\n
unknownchar [@#$^_]
keywords	("void"|"main"|"int"|"double"|"float"|"char"|"for"|"while"|"if"|"else"|"printf"|"scanf"|"true"|"false")
space		[ \t\n]
number     ([0-9])+
identifier  ([a-zA-Z])+
operator    [+-/*%<>=!]
compare		("<"|"<="|">="|">"|"=="|"!=")
semi		;
char		"'"[a-zA-Z]"'"
expression	({number}|{identifier})([+-/*%]({number}|{identifier}))*|{char}
Declare		[ \t]*("int"|"double"|"float"|"char")(" ")+{identifier}(" ")*("="(" ")*{expression})?
multipleDec [ \t]*("int"|"double"|"float"|"char")(" ")+{identifier}(" ")*(","{identifier}(" ")*)+
initialize	{identifier}(" ")*"="(" ")*{expression}

printf		[ \t]*"printf(\"""\")"|"printf("{expression}")"

statement	[ \t]*({initialize}|{Declare}|{multipleDec})(" ")*";"

ifstate	"if("{condition}")"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*("else"({space})*"{"({space})*{statement}*({space})*"}"({space})*)?

condition	{expression}{compare}{expression}|"true"|"false"|"1"|"0"

%%
{newline}			{linecount++;}
"("					{paracount++;}
")"					{paracount--;}
"{"					{bracketcount++;}
"}"					{bracketcount--;}

{unknownchar}		{printf("line %d: unknown character \n",linecount);} 



({Declare}|{initialize})[" "]*{newline} {printf("line %d: missing ; \n",linecount++);} 
{Declare}|{initialize}	   {printf("line %d: error \n",linecount);} 
{printf}			{printf("PRINTING");}

{ifstate}		    {count_lines(yytext);}
{statement}			{printf("this is a statement on line %d \n",linecount);}  


[ \t]				;
.					{skip_line_error();} 
<<EOF>>	     		{ if(paracount>0) printf("line %d: missing )\n",linecount);
					  if(paracount<0) printf("line %d: missing (\n",linecount);
					  if(bracketcount>0) printf("line %d: missing }\n",linecount);
					  if(bracketcount<0) printf("line %d: missing {\n",linecount);
					  printf("END!! %d \n",linecount); yyterminate();}
%%

skip_line_error(void)
{
  printf("line %d: error \n",linecount++);
  
  int c;

  /* Read until we find \n or EOF */
  while((c = input()) != '\n' && c != EOF)
    ;

  /* Maybe you want to place back EOF? */
  if(c == EOF)
    unput(c);
}

count_lines(char *  yytext){
	printf("COUNTING LINES! \n");
	size_t i = 0;
	while (yytext[i] != '\0') { 
		if(yytext[i]=='\n'){   linecount++;    }
		i++;
	}
}

check_bracket(){
	printf("COUNTING LINES! \n");
	size_t i = 0;
	while (yytext[i] != '\0') { 
		if(yytext[i]==')' && yytext[i+1]=='{'){   bracketcount++;    }
		i++;
	}
}


main() {
yylex();
printf("\n============================================================================");
}


