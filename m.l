character [A-Za-z]
num [0-9]
%{
#include <stdlib.h>
#include <string.h>
void yyerror(char *);
#include "m.tab.h"
%}
%%

"int"    { yylval.Value_Int = INTEGER; 
return INT; }

"string" { yylval.Value_Int = STRING; 
return STR; }

"char"   { yylval.Value_Int = CHARACTER; 
return CHAR; } 

"float"  { yylval.Value_Int = FLOAT; 
return FLOUT; }


switch    return SWITCH;
case     return CASE;
break     return BREAK;
default   return DEFAULT;

"print"  { yylval.Value_Int = PRINT; 
return PRINT; }

{num}+ {  strcpy(yylval.Object.name, ""); 
yylval.Object.integer_value = atoi(yytext); 
          yylval.Object.set_type = INTEGER;      
           yylval.Object.is_initialized = true; 
           return INTEGER; }


{num}+[.]{num}+ { strcpy(yylval.Object.name, ""); 
                  yylval.Object.set_type = FLOAT;
                  yylval.Object.is_initialized = true; 
                  yylval.Object.float_value = atof(yytext);
                  return FLOAT; }


{character}({character}|{num})* {   strcpy(yylval.Object.name, yytext); 
                                    return VARIABLE; }



\"[^"]\" { strcpy(yylval.Object.name, "");
           yylval.Object.set_type = CHARACTER;           
           yylval.Object.is_initialized = true;
           yylval.Object.char_value = yytext[1];
           return CHARACTER; }

\"[^"]*\" { strcpy(yylval.Object.name, "");
            yylval.Object.set_type = STRING;  
            yylval.Object.is_initialized = true;           
            memset(yylval.Object.s_value, '\0', sizeof(yylval.Object.s_value)); 
            strncpy(yylval.Object.s_value, yytext + 1, strlen(yytext) - 2); 
            return STRING;}
            

[\n] { return *yytext; }

[=] { yylval.Value_char = yytext[0]; 
return EQU;}
[-] { yylval.Value_char = yytext[0]; 
return MINUS;}
[+] { yylval.Value_char = yytext[0]; 
return PLUS;}
[*] { yylval.Value_char = yytext[0]; 
return MULT;}
[/] { yylval.Value_char = yytext[0]; 
return DIV;}
[ \t] ;

. yyerror("invalid character");
%%
int yywrap(void) {
return 1;
}