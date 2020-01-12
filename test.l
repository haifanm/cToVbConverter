%{

#include <stdio.h>
#include <string.h>
void showError();
%}

%option noyywrap
keywords	("void"|"main"|"int"|"double"|"float"|"char"|"for"|"while"|"if"|"else"|"printf"|"scanf"|"true"|"false")
space		[ \t\n]
number     ([0-9])+
identifier  ([a-zA-Z])+
operator    [+-/*%<>=!]
compare		("<"|"<="|">="|">"|"=="|"!=")
semi		;
char		"'"[a-zA-Z]"'"
expression	(({number}|{identifier})([+-/*%]{number}|{identifier})*|{char})
Declare		("int"|"double"|"float"|"char")(" ")+{identifier}(" ")*("="(" ")*{expression})?
initialize	{identifier}"="{expression}
statement	({initialize}|{Declare})(" ")*";"

codeblock	({space})*"{"({space})*{statement}*({space})*"}"({space})*

condition	{expression}{compare}{expression}|"true"|"false"
ifstatement	"if("{condition}")"({space})*"{"({space})*{statement}*({space})*"}"({space})*("else"({space})*"{"({space})*{statement}*({space})*"}"({space})*)?

%%
{statement}			{printf("this is a statement \n");}  
{codeblock}			{printf("CODEBLOCK ");}  
{initialize}		{printf("initialize ");}  
{ifstatement}		{printf("ifstatement ");}  
[\n]				;

.       			{printf(yytext);}  

%%

main() {
yylex();
printf("\n============================================================================");
}


