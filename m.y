%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

///////////////////////////////////////////////////////////////////////////////
// A structure to represent a stack
struct Stack {
    int top;
    unsigned capacity;
    int* array;
};
 
// function to create a stack of given capacity. It initializes size of
// stack as 0
struct Stack* createStack(unsigned capacity)
{
    struct Stack* stack = (struct Stack*)malloc(sizeof(struct Stack));
    stack->capacity = capacity;
    stack->top = -1;
    stack->array = (int*)malloc(stack->capacity * sizeof(int));
    return stack;
}
 
// Stack is full when top is equal to the last index
int isFull(struct Stack* stack)
{
    return stack->top == stack->capacity - 1;
}
 
// Stack is empty when top is equal to -1
int isEmpty(struct Stack* stack)
{
    return stack->top == -1;
}
 
// Function to add an item to stack.  It increases top by 1
void push(struct Stack* stack, int item)
{
    if (isFull(stack))
        return;
    stack->array[++stack->top] = item;
    //printf("%d pushed to stack\n", item);
}
 
// Function to remove an item from stack.  It decreases top by 1
int pop(struct Stack* stack)
{
    if (isEmpty(stack))
        return INT_MIN;
    return stack->array[stack->top--];
}
 
// Function to return the top from stack without removing it
int peek(struct Stack* stack)
{
    if (isEmpty(stack))
        return INT_MIN;
    return stack->array[stack->top];
}
 
///////////////////////////////////////////////////////////////////////









///////////////////////////////////////////////////////////////////////////////
// A structure to represent a stack
typedef struct strlist
{
        int size;
        int pos;
        char *list[1]; // Actually ends up being larger than one element because of malloc() size
} strlist;

#define STRLIST_MINSIZE 16
#define STRLIST_FREE(X) (((X)->size)-((X)->pos))

strlist *strlist_create(void)
{
        strlist *s=malloc(sizeof(strlist)+(sizeof(char *)*STRLIST_MINSIZE));
        s->pos=0;
        s->size=STRLIST_MINSIZE;
        return(s);
}

strlist *strlist_resize(strlist *s)
{
        strlist *n=realloc(s, sizeof(strlist) +
                (sizeof(char *)*(s->size<<1)));

        if(n == NULL)
                return(NULL);

        n->size<<=1;

        return(n);
}

void strlist_free(strlist *s)
{
        int n;
        for(n=0; n<s->pos; n++)
                free(s->list[n]);
        free(s);
}

strlist *strlist_append(strlist *s, const char *str)
{
        if(STRLIST_FREE(s) <= 0)
        {
                strlist *n=strlist_resize(s);
                if(n == NULL)
                        return(NULL);
                s=n;
        }

        s->list[s->pos++]=strdup(str);
        return(s);
}

char *strlist_pop(strlist *s)
{
        if(s->pos <= 0) return(NULL);
        return(s->list[--s->pos]);
}
 
///////////////////////////////////////////////////////////////////////

























char temp[3];
void yyerror(char *);
int yylex(void);
int index_ok = 0;
int q_index = 0;
char result_name[3] = {'t','0','\0'};
char address_register_name[3] = {'d','0','\0'};
int lbl=0;
int lbl1,lbl2=0;
int lbl_function=0;

int enum_counter=0;
int lbl_switch=0;
char switchcasevar[3];


void restart_enum_counter();
struct Obj OPER(struct Obj expr1, char operators, struct Obj expr2);
void print_quadruples();
struct Obj VALUE_OF_VAR(struct Obj n);
int CHECK_DECLARATION(struct Obj coming);
bool VARIABLE_DECLARATION(int type, struct Obj coming);
bool DECLARATION_function(int type, struct Obj coming);
void SET_VALUE_OF_VAR(struct Obj in, struct Obj expr);
void VARIABLE_INITIALIZATION(int type, struct Obj in, struct Obj expr);
void VARIABLE_PRINT(struct Obj in);
struct Obj put_in_temp(struct Obj n);
void label();
void label2();
void label3();
void labelIf();
void labelElse();
void labelIf2();
void labelif22();
void labelRpt();
void initialize_stack(int type);
void initialize_stack_void(int type);
void get_variable_object(int type,struct Obj coming);
void get_variable_object_type(struct Obj coming);
bool FUNCTION_DECLARATION(int type, struct Obj coming) ;
void initialize_function(int type, struct Obj in);
struct Obj get_function(struct Obj var);
void get_variable_object_type(struct Obj coming);
bool check_return_type(struct Obj var);
bool check_return_type_void();
void pop_paramters();
void evaluate_enum_element(struct Obj element);
void labelSwitch();
void labelSwitch2();
void labelswitch3(struct Obj intval);
void switchcasevar2(struct Obj var);


%} 

%code requires {
    #include <stdbool.h>
    struct Obj
    {
        //value
        char name[100];
        char registerName[100];
        int set_type;
        int integer_value;
        float float_value;
        char char_value;
        char s_value[100];
        bool is_initialized;
        bool bool_value;
        int no_arguments;
        int parameters[100];
        int label;
        bool is_function;

    };

    struct Obj ARRAY[100];
    struct quad{
    char op;
    char arg1[10];
    char arg2[10];
    char result[10];
}Quadruples[30];
FILE * quadruples_file;
FILE * sementic_errors_file;
struct Stack* parameters;
struct strlist* param_names;
int no_parameters;
int function_type;
bool returned;
}

%union {
struct Obj Object;
int Value_Int;
char Value_char;
char sValue[100];
};



%token <Value_Int> INT CHAR STR FLOUT PRINT BOOL2 VOID
%token <Value_char> PLUS MINUS MULT DIV EQU 
%token <Object> INTEGER STRING FLOAT CHARACTER VARIABLE BOOL 
%token SWITCH CASE BREAK DEFAULT OPENROUND CLOSEDROUND OPENCURLY CLOSEDCURLY COLON L G LE GE NE EQ FOR OR AND INC DEC SEMICOLON WHILE REPEAT UNTIL IF ELSE COMMA ENUM RETURN

%left  MINUS PLUS
%left  MULT DIV
%type <Object> expr statement B C D ST condtionalstatement FUNCTCALL
%type <Value_Int> typeIdentifier 
%%
pro:
pro statmentorfunction
|
;

statmentorfunction:
| statement statmentorfunction
| FUNCT statmentorfunction {printf("functionnn accepted .\n");}
|
;



condtionalstatement:
expr L expr{ $$ = OPER($1,'<',$3); }
         | expr G expr{ $$ = OPER($1,'>',$3); }
         | expr LE expr{ $$ = OPER($1,'l',$3); }
         | expr GE expr{ $$ = OPER($1,'g',$3); }
         | expr EQ expr{ $$ = OPER($1,'c',$3); }
         | expr NE expr{ $$ = OPER($1,'!',$3); }
         | expr OR expr{ $$ = OPER($1,'|',$3); }
         | expr AND expr{ $$ = OPER($1,'&',$3); }
         ;   

expr:
BOOL
|INTEGER{$$=put_in_temp($1);}
| VARIABLE INC
| VARIABLE DEC 
|FLOAT
| CHARACTER 
| STRING 
| condtionalstatement
| expr PLUS expr { $$ = OPER($1,$2,$3); }
| expr MINUS expr { $$ = OPER($1,$2,$3); }
| expr MULT expr { $$ = OPER($1,$2,$3); }
| expr DIV expr { $$ = OPER($1,$2,$3); }
|VARIABLE { $$ = VALUE_OF_VAR($1); }
;



statements:
statement statement
| statement;

functionstatements:
functionstatements functionstatements
| statements
| RETURN expr{check_return_type($2);}
| RETURN {check_return_type_void();}
;
// printing an immediate value
statement:
 PRINT expr { VARIABLE_PRINT($2);}
|typeIdentifier VARIABLE EQU expr { VARIABLE_INITIALIZATION($1, $2, $4); printf("\n\n"); } 
| VARIABLE EQU expr { SET_VALUE_OF_VAR($1,$3); printf("\n\n");}
| typeIdentifier VARIABLE { VARIABLE_DECLARATION($1, $2);}
| expr
| ST {printf("Switch case accepted .\n");}
| FR {printf("For Loop accepted .\n");}
| WL {printf("while Loop accepted .\n");}
| RPTUNTL {printf("repeat until loop accepted .\n");}
| IFELSE  {printf("if else accepted .\n");}
| ENUMSTATEMENT {printf("ENUM accepted .\n");}
| FUNCTCALL
| typeIdentifier VARIABLE EQU FUNCTCALL { VARIABLE_INITIALIZATION($1, $2, $4); printf("\n\n"); }
| VARIABLE EQU FUNCTCALL { SET_VALUE_OF_VAR($1,$3); printf("\n\n");}
;

typeIdentifier:
BOOL2
|INT 
| CHAR
| FLOUT 
| STR 
;

FUNCT  :  typeIdentifier VARIABLE  {initialize_stack($1);}  OPENROUND parameters CLOSEDROUND OPENCURLY{printf("L%03d:\n", lbl);fprintf(quadruples_file,"L%03d:\n", lbl);lbl_function=lbl++;printf("pop %s\n",address_register_name);fprintf(quadruples_file,"pop %s\n",address_register_name);pop_paramters();} functionstatements  CLOSEDCURLY{initialize_function($1,$2);}|
          VOID VARIABLE {initialize_stack_void($1);} OPENROUND parameters CLOSEDROUND OPENCURLY {printf("L%03d:\n",lbl);fprintf(quadruples_file,"L%03d:\n",lbl);lbl_function=lbl++} functionstatements {printf("pop %s\n",result_name);fprintf(quadruples_file,"pop %s\n",result_name);printf("JMP %s\n",result_name);fprintf(quadruples_file,"JMP %s\n",result_name);} CLOSEDCURLY{initialize_function(VOID,$2);};

FUNCTCALL : VARIABLE OPENROUND {initialize_stack_void(1);} DeclaredParameters CLOSEDROUND{$$=get_function($1)};
DeclaredParameters:expr{get_variable_object_type($1)}
| DeclaredParameters COMMA expr{get_variable_object_type($3)};

parameters : typeIdentifier VARIABLE{DECLARATION_function($1, $2); get_variable_object($1,$2);}
| parameters COMMA typeIdentifier VARIABLE{DECLARATION_function($3, $4); get_variable_object($3,$4); };
|;
ST     :    SWITCH OPENROUND VARIABLE{switchcasevar2($3);} CLOSEDROUND OPENCURLY B CLOSEDCURLY{labelSwitch();}
         ;
   
B       :    C
        |    C    D
        ;
   
C      :    C    C
        | BREAKSTATEMENT {printf("L%03d:\n",lbl);fprintf(quadruples_file,"L%03d:\n",lbl++);}
        | BREAKSTATEMENT BREAK {labelSwitch2();printf("L%03d:\n",lbl);fprintf(quadruples_file,"L%03d:\n",lbl++);}
        ;
BREAKSTATEMENT : CASE INTEGER {labelswitch3($2);}  COLON statement 
        ;

D      :    DEFAULT   COLON statement
        | DEFAULT   COLON statement BREAK {labelSwitch2();}
        | DEFAULT   COLON BREAK
        ;
    
WL  :  WHILE {label();} OPENROUND condtionalstatement CLOSEDROUND{label2();} DEF{label3();}
FR       : FOR  OPENROUND statement SEMICOLON condtionalstatement SEMICOLON statement CLOSEDROUND DEF ;
IFELSE   : IFF {labelIf2();} |
           IFFELSE
           ;
IFF : IF OPENROUND condtionalstatement CLOSEDROUND {labelIf();}OPENCURLY statements CLOSEDCURLY;
IFFELSE : IFF ELSE {labelElse();labelIf2();}OPENCURLY statements CLOSEDCURLY{labelif22();}
RPTUNTL  : REPEAT {label();}DEF UNTIL OPENROUND condtionalstatement {label2();} CLOSEDROUND {label3();}

DEF    : OPENCURLY LOOPSTATEMENT CLOSEDCURLY
LOOPSTATEMENT : LOOPSTATEMENT LOOPSTATEMENT 
              | statements 
              | BREAK
              ;
ENUMSTATEMENT : ENUM VARIABLE OPENCURLY {restart_enum_counter();} ENUMLIST CLOSEDCURLY 
ENUMLIST      : VARIABLE {evaluate_enum_element($1);}
                | ENUMLIST COMMA VARIABLE {evaluate_enum_element($3);}



%%
/*void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}*/

void print_symbol_table()
{
    FILE* f_symbol=fopen("symbol_table", "w");
    fprintf(f_symbol,"symbol\t\ttype\t\tvalue\n");
    for(int i=0; i<index_ok;i=i+1)
    {
        fprintf(f_symbol,"%s\t\t",ARRAY[i].name);

        if(ARRAY[i].is_function)
            fprintf(f_symbol,"function\t\tN/A\n");
        else
        {
             if(!ARRAY[i].is_initialized)
            {
                switch(ARRAY[i].set_type)
                {
                    case(INTEGER):
                        fprintf(f_symbol,"integer\t\tnull\n");
                        break;
                    case(FLOAT):
                        fprintf(f_symbol,"float\t\tnull\n");
                        break;
                    case(CHAR):
                        fprintf(f_symbol,"char\t\tnull\n");
                        break;
                    case(BOOL):
                        fprintf(f_symbol,"bool\t\tnull\n");
                        break;
                    default:
                        break;
                }

            }
            else
            {
                 switch(ARRAY[i].set_type)
                {
                    case(INTEGER):
                        fprintf(f_symbol,"integer\t\t%s\n",ARRAY[i].integer_value);
                        break;
                    case(FLOAT):
                        fprintf(f_symbol,"float\t\t%s\n",ARRAY[i].float_value);
                        break;
                    case(CHAR):
                        fprintf(f_symbol,"char\t\t%s\n",ARRAY[i].char_value);
                        break;
                    case(BOOL):
                        fprintf(f_symbol,"bool\t\t%s\n",ARRAY[i].bool_value);
                        break;
                    default:
                        break;
                }
            }
        }

     fclose(f_symbol);

}
}
int main(int argc, char *argv[]) {
    extern FILE *yyin;
    yyin = fopen("test.cpp", "r");
    quadruples_file=fopen("quadruples.txt", "w");
    sementic_errors_file=fopen("sementic_errors.txt", "w");
    yyparse();
    print_symbol_table();
    fclose(yyin);
    fclose(quadruples_file);
    return 0;
}


struct Obj OPER(struct Obj in1, char operators, struct Obj in2) {
    
    
    struct Obj result; //hereeee
    strcpy(result.name, "");

    if(in1.is_initialized) { //lazim yet2kd en two expr have values
    if (in2.is_initialized){
        if(in1.set_type != in2.set_type) {
        //yyerror("Type mismatch\n");
        fprintf(sementic_errors_file,"Type mismatch\n");
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
            else if(in1.set_type==BOOL){
                result.set_type = BOOL;
                result.is_initialized = true;
            }
            else {
                //yyerror("Error in the operation\n");
                fprintf(sementic_errors_file,"Error in the operation\n");
            }

        }

    }
}
    strcpy(Quadruples[q_index].arg1, in1.registerName);
    Quadruples[q_index].op = operators;
    strcpy(Quadruples[q_index].arg2, in2.registerName);
    strcpy(Quadruples[q_index].result, result_name);
    strcpy(result.registerName,result_name);
    result_name[1]++;
    if(operators=='-'){
        printf("sub %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        fprintf(quadruples_file,"sub %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
    }
    if(operators=='+') {
        printf("Add %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        fprintf(quadruples_file,"Add %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        }
    if(operators=='*') {
        printf("MUL %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        fprintf(quadruples_file,"MUL %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        }
    if(operators=='/') {
        printf("DIV %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        fprintf(quadruples_file,"DIV %s,%s,%s\n",Quadruples[q_index].result,in1.registerName,in2.registerName);
        }
    if(operators=='c') {
        printf("compEQ %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compEQ %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
        }
    if(operators=='>') {
        printf("compGT %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compGT %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
        }
    if(operators=='<') {
        printf("compLT %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compLT %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    if(operators=='!') {
        printf("compNE %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compNE %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    if(operators=='&') {
        printf("AND %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"AND %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    if(operators=='|') {
        printf("OR %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"OR %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    if(operators=='g') {
        printf("compGE %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compGE %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    if(operators=='l') {
        printf("compLE %s,%s\n",in1.registerName,in2.registerName);
        fprintf(quadruples_file,"compLE %s,%s\n",in1.registerName,in2.registerName);
        result_name[1]='0';
    }
    q_index++;
    return result;
}

void evaluate_enum_element(struct Obj element)
{
    //add to symbol table, value=enum_counter
    //printf("evaluating,counter=%d",enum_counter);
    strcpy(ARRAY[index_ok].name,element.name);
    ARRAY[index_ok].integer_value=enum_counter++;
    ARRAY[index_ok].set_type = INTEGER;
    ARRAY[index_ok].is_initialized = true;
    printf("LD %s,%d\n",result_name,ARRAY[index_ok].integer_value);
    fprintf(quadruples_file,"LD %s,%d\n",result_name,ARRAY[index_ok].integer_value);
    printf("ST %s,%s\n",element.name,result_name);
    fprintf(quadruples_file,"ST %s,%s\n",element.name,result_name);
    index_ok++;

}
void restart_enum_counter()
{
    enum_counter=0;
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
        printf("%s",n.name);
    //yyerror("the variable is undeclared");
    fprintf(sementic_errors_file,"the variable is undeclared");
    }
    else 
    {
        if(!ARRAY[check].is_initialized) {
          //yyerror("Cannot use uninitialized variable");   
          fprintf(sementic_errors_file,"Cannot use uninitialized variable");         
        }
        else 
        {
            struct Obj value2 = ARRAY[check];
            strcpy(Quadruples[q_index].arg1, n.name);
            Quadruples[q_index].op = '=';
            strcpy(Quadruples[q_index].arg2, "");
            strcpy(Quadruples[q_index].result, result_name);
            strcpy(value2.registerName,result_name);
            result_name[1]++;
            printf("LD %s,%s\n",Quadruples[q_index].result,n.name);
            fprintf(quadruples_file,"LD %s,%s\n",Quadruples[q_index].result,n.name);
            q_index++;
           return  value2;
        }
    }
    //q_index++;
    return value;
}
bool DECLARATION_function(int type, struct Obj coming) { //awel may3rf variable ok m3aia

int check=CHECK_DECLARATION(coming);
    if(check != -1){
        //yyerror("Variable already declared!"); //already declared
        fprintf(sementic_errors_file,"Variable already declared!");
    return false;
    }

    if (check == -1) { //so declare it
        ARRAY[index_ok].set_type = type; strcpy(ARRAY[index_ok].name, coming.name);
        ARRAY[index_ok].is_initialized = true;
        //strcpy(ARRAY[index_ok].registerName,result_name);
        //result_name[1]++;
        index_ok++;
        return true;
    }
    
    return false;
}
bool VARIABLE_DECLARATION(int type, struct Obj coming) { //awel may3rf variable ok m3aia

int check=CHECK_DECLARATION(coming);
    if(check != -1){
        //yyerror("Variable already declared!"); //already declared
        fprintf(sementic_errors_file,"Variable already declared!");
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
    //{ //is not  declared
       //         printf("%s %d",in.name,check);
     //           yyerror("Variable is  undeclared!");
   // }
    //else 
    if(check != -1||strlen(in.name)==0) 
    {
       if(strlen(in.name)!=0&&!ARRAY[check].is_initialized) { //is not initialized
             //yyerror("variable is uninitialized!");
             fprintf(sementic_errors_file,"variable is uninitialized!");
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
            else if(ARRAY[check].set_type == BOOL) {
                printf("Boolean accepted"); // to be changed.....
                 printf("\n");
                }         
        }
        printf("print %s\n",in.registerName);
    }
}



void SET_VALUE_OF_VAR(struct Obj in, struct Obj expr) { //intializatiooon

int check = CHECK_DECLARATION(in);
if(check==-1){
    //yyerror("The variable is undeclared, Sorry can't set it"); //can't declare x to this y value
    fprintf(sementic_errors_file,"The variable is undeclared, Sorry can't set it"); //can't declare x to this y value
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
                 else if (ARRAY[check].set_type == BOOL) 
                {ARRAY[check].bool_value,expr.bool_value;}

                char tempLocal[3] = {' ',' ','\0'};
                strcpy(Quadruples[q_index].arg1,expr.registerName);
                Quadruples[q_index].op = '=';
                strcpy(Quadruples[q_index].arg2,tempLocal);
                strcpy(Quadruples[q_index].result,in.name);
                printf("ST %s,%s\n",Quadruples[q_index].result,expr.registerName);
                fprintf(quadruples_file,"ST %s,%s\n",Quadruples[q_index].result,expr.registerName);
                result_name[1]='0';
                q_index++;

                ARRAY[check].is_initialized = true; //tamam initialized

            }
            else{
               //yyerror("Type mismatch"); 
               fprintf(sementic_errors_file,"Type mismatch");
            }
        }
    }
}

void VARIABLE_INITIALIZATION(int type, struct Obj in, struct Obj expr) { //heena byhsal feeha el two function el ablha 3latouul

if(type != expr.set_type) {
//yyerror("Type mismatch");
fprintf(sementic_errors_file,"Type mismatch");
}
    if(type == expr.set_type) {
        if(VARIABLE_DECLARATION(type, in)) SET_VALUE_OF_VAR(in, expr);
    }
}



void print_quadruples(){
    for(int i=0;i<q_index;i++){
        printf("quadruple arg1: %s\n",Quadruples[i].arg1);
        printf("quadruple arg2: %s\n",Quadruples[i].arg2);
        printf("quadruple result: %s\n",Quadruples[i].result);
        printf("quadruple operand %c:\n",Quadruples[i].op);
    }
}

struct Obj put_in_temp(struct Obj n) { 
    struct Obj value=n;
    strcpy(value.registerName,result_name);
    result_name[1]++;
    //printf("%d",n.integer_value);
    printf("LD %s,%d\n",value.registerName,value.integer_value);
    fprintf(quadruples_file,"LD %s,%d\n",value.registerName,value.integer_value);
    //printf("LD R2,%s\n",Quadruples[q_index].arg2);
    return value;
}
//Labels
void label(){
printf("L%03d:\n", lbl1 = lbl);
fprintf(quadruples_file,"L%03d:\n", lbl1 = lbl++);
}
void label2(){
printf("jnz\tL%03d\n", lbl2 = lbl);
fprintf(quadruples_file,"jnz\tL%03d\n", lbl2 = lbl++);
}
void label3(){
    printf("jmp\tL%03d\n", lbl1); 
    fprintf(quadruples_file,"jmp\tL%03d\n", lbl1); 
    printf("L%03d:\n", lbl2); 
    fprintf(quadruples_file,"L%03d:\n", lbl2); 
}
void labelIf(){
printf("jnz\tL%03d\n", lbl2 = lbl);
fprintf(quadruples_file,"jnz\tL%03d\n", lbl2 = lbl++);
}
void labelElse(){
printf("jmp\tL%03d\n", lbl2 = lbl);
fprintf(quadruples_file,"jmp\tL%03d\n", lbl2 = lbl++);
}
void labelIf2(){
 printf("L%03d:\n", lbl2-1);
fprintf(quadruples_file,"L%03d:\n", lbl2-1);
}
void labelif22(){
printf("L%03d:\n", lbl2);
fprintf(quadruples_file,"L%03d:\n", lbl2);
}
/*void labelRpt1(){
     printf("L%03d:\n", lbl2-1);
fprintf(quadruples_file,"L%03d:\n", lbl2-1);
}
void labelRpt2(){
    printf("jnz\tL%03d\n", lbl2 = lbl);
fprintf(quadruples_file,"jnz\tL%03d\n", lbl2 = lbl++);
}*/

void get_variable_object(int type,struct Obj coming){
        push(parameters, type);
        strlist_append(param_names,coming.name);
        no_parameters++;
}

void get_variable_object_type(struct Obj coming){
        int index=CHECK_DECLARATION(coming);
        printf("push %s\n",coming.registerName);
        fprintf(quadruples_file,"push %s\n",coming.registerName);
        if(index!=-1){
            push(parameters, ARRAY[index].set_type);
            }
        else push(parameters, coming.set_type);
        //printf("da5al %d",coming.set_type);
        no_parameters++;
}

void initialize_stack(int type){
    no_parameters=0;
    parameters=createStack(100);
    param_names=strlist_create();
    returned=false;
    function_type=type;
}
void initialize_stack_void(int type){
    returned=true;
    no_parameters=0;
    parameters=createStack(100);
    function_type=type;
}
void initialize_function(int type, struct Obj in) { //heena byhsal feeha el two function el ablha 3latouul
  if(!returned) {
      //yyerror("The function has no return");
      fprintf(sementic_errors_file,"The function has no return");
      }
  FUNCTION_DECLARATION(type, in);
}

bool FUNCTION_DECLARATION(int type, struct Obj coming) { //awel may3rf variable ok m3aia
int check=CHECK_DECLARATION(coming);
    if(check != -1){
        //yyerror("Function already declared!"); //already declared
        fprintf(sementic_errors_file,"Function already declared!"); //already declared
        return false;
    }
    if (check == -1) { //so declare it
        ARRAY[index_ok].set_type = type; strcpy(ARRAY[index_ok].name, coming.name);
        ARRAY[index_ok].is_initialized = false;
        ARRAY[index_ok].label=lbl_function;
        ARRAY[index_ok].is_function=true;
        int i=no_parameters-1;
        while(!isEmpty(parameters)){
            int x=pop(parameters);
            ARRAY[index_ok].parameters[i]=x;
            i--;
         }
        ARRAY[index_ok].no_arguments=no_parameters;
        index_ok++;
        return true;
    }
    return false;
}
struct Obj get_function(struct Obj var){
    struct Obj result;
    int index=CHECK_DECLARATION(var);
    if(index==-1||!ARRAY[index].is_function){
        //yyerror("The function is not declared\n"); //can't declare x to this y value
        fprintf(sementic_errors_file,"The function is not declared\n"); //can't declare x to this y value
    }
    else{
    struct Obj x=ARRAY[index];
    if(no_parameters!=x.no_arguments) {
        //yyerror("wrong number of paramters\n");
        fprintf(sementic_errors_file,"wrong number of paramters\n");
        }
    int i=no_parameters-1;
        while(!isEmpty(parameters)){
            int x=pop(parameters);
            if(ARRAY[index].parameters[i]!=x){
               //yyerror("Wrong paramter types\n"); 
               fprintf(sementic_errors_file,"Wrong paramter types\n"); 
               //return NULL;
            }
            i--;
         }
    }
    result.set_type = ARRAY[index].set_type;
    result.is_initialized = true;
    printf("LD %s ,L%03d\n", result_name,lbl);
    fprintf(quadruples_file,"LD %s ,L%03d\n", result_name,lbl);
    printf("push %s\n",result_name);
    fprintf(quadruples_file,"push %s\n",result_name);
    printf("JMP L%03d\n",ARRAY[index].label);
    fprintf(quadruples_file,"JMP L%03d\n",ARRAY[index].label);
    printf("L%03d:\n", lbl);
    fprintf(quadruples_file,"L%03d:\n", lbl++);
    printf("pop %s\n",result_name);
    fprintf(quadruples_file,"pop %s\n",result_name);
    strcpy(result.registerName,result_name);
    return result;
}
bool check_return_type(struct Obj var){
if(var.set_type!=function_type){
    //yyerror("return type is wrong\n");
    fprintf(sementic_errors_file,"return type is wrong\n");
    }
else {
    returned=true;
    //printf("pop %s\n",result_name);
    printf("push %s\n",var.registerName);
    fprintf(quadruples_file,"push %s\n",var.registerName);
    printf("JMP %s\n",address_register_name);
    fprintf(quadruples_file,"JMP %s\n",address_register_name);
    }
}
bool check_return_type_void(){
if(VOID!=function_type){
    //yyerror("return type is wrong\n");
    fprintf(sementic_errors_file,"return type is wrong\n");
    }
else returned=true;
}
void pop_paramters(){
    char* param_name;
    param_name=strlist_pop(param_names);
    while(param_name){
        printf("pop %s\n",result_name);
        fprintf(quadruples_file,"pop %s\n",result_name);
        printf("ST %s,%s\n",param_name,result_name);
        fprintf(quadruples_file,"ST %s,%s\n",param_name,result_name);
        param_name=strlist_pop(param_names);
    }
}
void labelSwitch(){
printf("L%03d:\n", lbl_switch);
fprintf(quadruples_file,"L%03d:\n", lbl_switch);
}
void labelSwitch2(){
printf("jmp\tL%03d\n", lbl_switch);
fprintf(quadruples_file,"jmp\tL%03d\n",  lbl_switch); 
}
void labelswitch3(struct Obj intval){
printf("LD %s,%s\n",result_name,switchcasevar);
printf("compEQ %s,%d\n",result_name,intval.integer_value);
printf("jnz\tL%03d\n", lbl);
fprintf(quadruples_file,"LD %s,%s\n",result_name,switchcasevar);
fprintf(quadruples_file,"compEQ %s,%d\n",result_name,intval.integer_value);
fprintf(quadruples_file,"jnz\tL%03d\n", lbl);
}
void switchcasevar2(struct Obj var){
    lbl_switch=lbl++;
    strcpy(switchcasevar,var.name);
}
