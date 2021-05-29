%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void yyerror(char *);
int yylex(void);
int index_ok = 0;

struct Obj OPER(struct Obj expr1, char operators, struct Obj expr2);
struct Obj VALUE_OF_VAR(struct Obj n);
int CHECK_DECLARATION(struct Obj coming);
bool VARIABLE_DECLARATION(int type, struct Obj coming);
void SET_VALUE_OF_VAR(struct Obj in, struct Obj expr);
void VARIABLE_INITIALIZATION(int type, struct Obj in, struct Obj expr);
void VARIABLE_PRINT(struct Obj in);



%} 

%code requires {
    #include <stdbool.h>
    struct Obj
    {
        //value
        char name[100];
        int set_type;
        int integer_value;
        float float_value;
        char char_value;
        char s_value[100];
        bool is_initialized;
    };

    struct Obj ARRAY[100];
}

%union {
struct Obj Object;
int Value_Int;
char Value_char;
char sValue[100];
};


%token <Value_Int> INT CHAR STR FLOUT PRINT 
%token <Value_char> PLUS MINUS MULT DIV EQU 
%token <Object> INTEGER STRING FLOAT CHARACTER VARIABLE 
%token SWITCH CASE BREAK DEFAULT OPENROUND CLOSEDROUND OPENCURLY CLOSEDCURLY COLON L G LE GE NE EQ FOR OR AND INC DEC SEMICOLON WHILE REPEAT UNTIL IF ELSE VOID COMMA ENUM

%left '+' '-'
%left '*' '/'
%type <Object> expr statement B C D ST
%type <Value_Int> typeIdentifier 
%%
pro:
pro statement '\n'
|
;



condtionalstatement:
expr L expr
         | expr G expr
         | expr LE expr
         | expr GE expr
         | expr EQ expr
         | expr NE expr
         | expr OR expr
         | expr AND expr
         ;   
expr:
INTEGER
| VARIABLE INC
| VARIABLE DEC
| FLOAT 
| CHARACTER 
| STRING 
| expr PLUS expr { $$ = OPER($1,$2,$3); }
| expr MINUS expr { $$ = OPER($1,$2,$3); }
| expr MULT expr { $$ = OPER($1,$2,$3); }
| expr DIV expr { $$ = OPER($1,$2,$3); }
|VARIABLE { $$ = VALUE_OF_VAR($1); }
;

statements:
statement statement
| statement;
// printing an immediate value
statement:
 PRINT VARIABLE { VARIABLE_PRINT($2);}
| PRINT expr
|typeIdentifier VARIABLE EQU expr { VARIABLE_INITIALIZATION($1, $2, $4); printf("\n\n");} 
| VARIABLE EQU expr { SET_VALUE_OF_VAR($1,$3); printf("\n\n");}
| typeIdentifier VARIABLE { VARIABLE_DECLARATION($1, $2);}
| expr
| ST {printf("Switch case accepted .\n");}
| FR {printf("For Loop accepted .\n");}
| WL {printf("while Loop accepted .\n");}
| RPTUNTL {printf("repeat until loop accepted .\n");}
| IFELSE  {printf("if else accepted .\n");}
| FUNCT {printf("function accepted .\n");}
| ENUM {printf("ENUM accepted .\n");}
;

typeIdentifier:
INT 
| CHAR
| FLOUT 
| STR 
;


FUNCT  :  typeIdentifier VARIABLE OPENROUND parameters CLOSEDROUND OPENCURLY statements  CLOSEDCURLY|
          VOID VARIABLE OPENROUND  CLOSEDROUND OPENCURLY  CLOSEDCURLY;
param: parameters|
parameters : typeIdentifier VARIABLE| parameters COMMA typeIdentifier VARIABLE;
ST     :    SWITCH OPENROUND VARIABLE CLOSEDROUND OPENCURLY B CLOSEDCURLY
         ;
   
B       :    C
        |    C    D
        ;
   
C      :    C    C
        |CASE INTEGER COLON statement
        |CASE INTEGER COLON statement BREAK
        ;

D      :    DEFAULT    COLON statement
        | DEFAULT    COLON statement BREAK
        ;
    
WL  :  WHILE OPENROUND condtionalstatement CLOSEDROUND DEF ;
FR       : FOR  OPENROUND statement SEMICOLON condtionalstatement SEMICOLON statement CLOSEDROUND DEF ;
IFELSE   : IFF |
           IFFELSE
           ;
IFF : IF OPENROUND condtionalstatement CLOSEDROUND OPENCURLY statements CLOSEDCURLY;
IFFELSE : IFF ELSE OPENCURLY statements CLOSEDCURLY

RPTUNTL  : REPEAT DEF UNTIL OPENROUND condtionalstatement CLOSEDROUND

DEF    : OPENCURLY LOOPSTATEMENT CLOSEDCURLY
LOOPSTATEMENT : LOOPSTATEMENT LOOPSTATEMENT 
              | statements 
              | BREAK
              ;
ENUMSTATEMENT : ENUM VARIABLE OPENCURLY ENUMLIST CLOSEDCURLY 
ENUMLIST      : VARIABLE
                | ENUMLIST COMMA VARIABLE



%%
void yyerror(char *s) {
fprintf(stderr, "%s\n", s);
}

int main(int argc, char *argv[]) {
extern FILE *yyin;
yyin = fopen(argv[1], "r");
yyparse();
fclose(yyin);
return 0;
}

struct Obj OPER(struct Obj in1, char operators, struct Obj in2) {
    
    
    struct Obj result; //hereeee
    strcpy(result.name, "");

    if(in1.is_initialized) { //lazim yet2kd en two expr have values
    if (in2.is_initialized){
        if(in1.set_type != in2.set_type) {
        yyerror("Type mismatch\n");
        }
        else {

            if( in1.set_type == INTEGER ) {
                result.set_type = INTEGER;
                if (operators == '+') 
                {result.integer_value = in1.integer_value + in2.integer_value;}
                else if (operators == '-') 
                {result.integer_value = in1.integer_value - in2.integer_value;}
                else if (operators == '*') 
                {result.integer_value = in1.integer_value * in2.integer_value;}
                else if (operators == '/') 
                {result.integer_value = in1.integer_value / in2.integer_value;}
                else if (operators == 'c') 
                {
                    if(in1.integer_value>in2.integer_value)
                    result.integer_value = in1.integer_value;
                    else
                    result.integer_value = in2.integer_value;
                    }

                result.is_initialized = true;
            }
            else if( in1.set_type == FLOAT ) {
                result.set_type = FLOAT;
                if (operators == '+' ) 
                {result.float_value = in1.float_value + in2.float_value;}
                else if (operators == '-') 
                {result.float_value = in1.float_value - in2.float_value;}
                else if (operators == '*') 
                {result.float_value = in1.float_value * in2.float_value;}
                else if (operators == '/') 
                {result.float_value = in1.float_value / in2.float_value;}
                result.is_initialized = true;
            }
            else {
                yyerror("Error in the operation\n");
            }

        }

    }
}

    return result;
}


int CHECK_DECLARATION(struct Obj coming) { //return index of object in symbol table

     for(int index1 = 0 ; index1 < index_ok; index1++) {
        if(strcmp(ARRAY[index1].name, coming.name) == 0) {
            return index1;
        }
    }
    return -1;
}

struct Obj VALUE_OF_VAR(struct Obj n) { //yegeb variable already mawgood
    struct Obj value;
    int check = CHECK_DECLARATION(n);
    value.is_initialized = false;
    if(check == -1) {
    yyerror("the variable is undeclared");
    }
    else 
    {
        if(!ARRAY[check].is_initialized) {
          yyerror("Cannot use uninitialized variable");            
        }
        else 
        {
            struct Obj value2 = ARRAY[check];
           return  value2;
        }
    }
    return value;
}

bool VARIABLE_DECLARATION(int type, struct Obj coming) { //awel may3rf variable ok m3aia

int check=CHECK_DECLARATION(coming);
    if(check != -1){yyerror("Variable already declared!"); //already declared
    return false;
    }

    if (check == -1) { //so declare it
        ARRAY[index_ok].set_type = type; strcpy(ARRAY[index_ok].name, coming.name);
        ARRAY[index_ok].is_initialized = false;
        index_ok++;
        return true;
    }
    
    return false;
}

void VARIABLE_PRINT(struct Obj in) {

    int check = CHECK_DECLARATION(in);
    if(check == -1) { //is not  declared
                yyerror("Variable is  undeclared!");
    }
    else 
    {
       if(!ARRAY[check].is_initialized) { //is not initialized
             yyerror("variable is uninitialized!");
        }
        else
        {
            if(ARRAY[check].set_type == CHARACTER) {
                printf("%c", ARRAY[check].char_value);
                 printf("\n");
                }
            else if(ARRAY[check].set_type == STRING) {
                printf(ARRAY[check].s_value);
                 printf("\n");
                }
            else if(ARRAY[check].set_type == INTEGER) {
                printf("%d", ARRAY[check].integer_value);
                 printf("\n");
                }
            else if(ARRAY[check].set_type == FLOAT) {
                printf("%f", ARRAY[check].float_value);
                 printf("\n");
                }           
        }
    }
}



void SET_VALUE_OF_VAR(struct Obj in, struct Obj expr) { //intializatiooon

int check = CHECK_DECLARATION(in);
if(check==-1){
    yyerror("The variable is undeclared, Sorry can't set it"); //can't declare x to this y value
}
      
    if (check != -1) {
        if(expr.is_initialized) { //law x=y make sure in y kaman intialized

            if(ARRAY[check].set_type == expr.set_type) { //hasab type yehot el value type of x= type of y
                if (ARRAY[check].set_type == INTEGER) {
                    ARRAY[check].integer_value = expr.integer_value;}
                else if (ARRAY[check].set_type == FLOAT) 
                {ARRAY[check].float_value = expr.float_value;}
                else if (ARRAY[check].set_type == CHARACTER) 
                {ARRAY[check].char_value = expr.char_value;}
                else if (ARRAY[check].set_type == STRING) 
                {strcpy(ARRAY[check].s_value,expr.s_value);}

                ARRAY[check].is_initialized = true; //tamam initialized

            }
        }
    }
}

void VARIABLE_INITIALIZATION(int type, struct Obj in, struct Obj expr) { //heena byhsal feeha el two function el ablha 3latouul

if(type != expr.set_type) {
yyerror("Type mismatch");
}
    if(type == expr.set_type) {
        if(VARIABLE_DECLARATION(type, in)) SET_VALUE_OF_VAR(in, expr);
    }
}





