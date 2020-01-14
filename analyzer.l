%{

#include <stdio.h>
#include <string.h>
int linecount=1;
int paracount=0;
int bracketcount=0;
int valid=1;
%}

%option noyywrap
end			[<<EOF>>] 
newline		\n
unknownchar [@$^_]
imports 	("#include<stdio.h>"|"#include<string.h>"|"#include<math.h>")*

keywords	("void"|"main"|"int"|"double"|"float"|"char"|"for"|"while"|"if"|"else"|"printf"|"scanf"|"true"|"false")
type  		("int"|"char"|"float"|"double")
space		[ \t\n]
number     	([0-9])+
identifier  ([a-zA-Z])+
operator    [+-/*%<>=!]
compare		("<"|"<="|">="|">"|"=="|"!=")
semi		;
a 			"%d"|"%f"|"%c"|"%s"  
id 			[a-zA-Z][a-zA-Z0-9]* 
chara ["]
openbracket [(]
closebracket [)]
input ["printf"] 
coma ","
char		"'"[a-zA-Z]"'"

expression	({number}|{identifier})([+-/*%]({number}|{identifier}))*|{char}
Declare		[ \t]*{type}(" ")+{identifier}(" ")*("="(" ")*{expression})?
multipleDec [ \t]*{type}(" ")+{identifier}(" ")*(","{identifier}(" ")*)+
initialize	[ \t]*{identifier}(" ")*"="(" ")*{expression}
printstate  [ \t]*({input}*{openbracket}*{chara}*({a}*|.*)*{chara}*{coma}*{id}*{closebracket}{semi})
statement	[ \t]*({initialize}|{Declare}|{multipleDec}|{printstate})(" ")*";"{space}*
condition	{expression}{compare}{expression}|"true"|"false"|"1"|"0"


ifstate		[ \t]*"if("{condition}")"({space})*"{"({space})*(({statement}|{ifstatesec}|{elsestate}){newline})*({space})*"}"({space})*
ifstatesec		[ \t]*"if("{condition}")"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*
elsestate		[ \t]*"if("{condition}")"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*"else"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*
elsestatesec	[ \t]*"if("{condition}")"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*"else"({space})*"{"({space})*(({statement}){newline})*({space})*"}"({space})*

mainfunc 	"main()"{space}*"{"{space}*({ifstate}|{elsestate}|({statement}"\n"))*{space}*"}"

%%
{newline}			{linecount++;}
"("					{paracount++;}
")"					{paracount--;}
"{"					{bracketcount++;}
"}"					{bracketcount--;}

{unknownchar}		{valid=0; printf("line %d: unknown character \n",linecount);} 

{multipleDec}		{printf("multiple");}

{imports} 			{}
{mainfunc} 			{count_lines(yytext);}

({Declare}|{initialize})[" "]*{newline} {valid=0; printf("line %d: missing ; \n",linecount++);} 
{Declare}|{initialize}	   {valid=0; printf("line %d: error \n",linecount);} 

{ifstate}		    {count_lines(yytext);}
{elsestate}		    {count_lines(yytext);}
{printstate}		{printf("this is a print!\n");}
{statement}			{/*printf("this is a statement on line %d \n",linecount);*/}  


[ \t]				;
.					{skip_line_error(yytext);} 
<<EOF>>	     		{ if(paracount>0) printf("line %d: missing )\n",linecount);
					  if(paracount<0) printf("line %d: missing (\n",linecount);
					  if(bracketcount>0) printf("line %d: missing }\n",linecount);
					  if(bracketcount<0) printf("line %d: missing {\n",linecount);
					  if(valid){
						printf("\nYour code is valid :)\t"); printf("total lines: %d\n",linecount); yyterminate();
					  }
					  else{
						printf("\nYour code is not valid, fix your errors and try again..\t"); printf("total lines: %d\n",linecount); yyterminate();
					  }
					  
					  }
%%

skip_line_error(char *  yytext)
{
	valid=0;
  printf("line %d: error\n",linecount++);
  
  int c;

  /* Read until we find \n or EOF */
  while((c = input()) != '\n' && c != EOF)
    ;

  /* Maybe you want to place back EOF? */
  if(c == EOF)
    unput(c);
}

count_lines(char *  yytext){
	//printf("COUNTING LINES! \n");
	size_t i = 0;
	while (yytext[i] != '\0') { 
		if(yytext[i]=='\n'){   linecount++;    }
		i++;
	}
}

check_bracket(char *  yytext){
	printf("COUNTING brackets! \n");
	size_t i = 0;
	while (yytext[i] != '\0') { 
		if(yytext[i]==')'){   bracketcount++;   }
		i++;
	}
}

main() {
yylex();
printf("============================================================================");
}