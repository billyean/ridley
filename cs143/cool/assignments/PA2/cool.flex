/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int comments;
int errors;
int eofs;
%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
LE             <=
ASSIGN         <-
CLASS          [cC][lL][aA][sS][sS]
ELSE           [eE][lL][sS][eE]
FI             [fF][iI]
IF             [iI][fF] 
IN             [iI][nN]
INHERITS       [iI][nN][hH][eE][rR][iI][tT][sS]
LET            [lL][eE][tT]
LOOP           [lL][oO][oO][pP]
POOL           [pP][oO][oO][lL]
THEN           [tT][hH][eE][nN]
WHILE          [wW][hH][iI][lL][eE]
CASE           [cC][aA][sS][eE]
ESAC           [eE][sS][aA][cC]
OF             [oO][fF]
NEW            [nN][eE][wW]
INT_CONST      [0-9]+
TRUE_CONST     t[rR][uU][eE]
FALSE_CONST    f[aA][lL][sS][eE]
TYPEID         [A-Z][_a-zA-Z0-9]*
OBJECTID       [a-z][_a-zA-Z0-9]*
SPACE          [ \t]+
NOT            [nN][oO][tT]
ISVOID         [iI][sS][vV][oO][iI][dD]

%x COMMENT
%x SINGLE_LINE_COMMENT
%x STRING

%%

 /*
  *  Nested comments
  */

"(*"                    { comments = 1;
                          BEGIN COMMENT; }
<COMMENT>{
  <<EOF>>               { if (eofs == 0 && errors == 0) {
                            cool_yylval.error_msg = "EOF in comment";
                            eofs++;
                            return (ERROR);
                          }
                          return (0); }
  \n                    { curr_lineno++; }
  \\*                   ;
  "(*"                  { comments++; }
  "*)"                  { if (--comments == 0) BEGIN 0; }
  .                     ;
}

"--"                    { BEGIN SINGLE_LINE_COMMENT; }
<SINGLE_LINE_COMMENT>{
  \n                    { curr_lineno++;
                          BEGIN 0;
                        }
  .                     ;  
}
 
 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
{LE}                    { return (LE); } 
{ASSIGN}                { return (ASSIGN); } 
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}			{ return (CLASS); }
{ELSE}			{ return (ELSE); }
{FI}			{ return (FI); }
{IF}			{ return (IF); }
{IN}			{ return (IN); }
{INHERITS}		{ return (INHERITS); }
{LET}			{ return (LET); }
{LOOP}			{ return (LOOP); }
{POOL}			{ return (POOL); }
{THEN}			{ return (THEN); }
{WHILE}                 { return (WHILE); }
{CASE}                  { return (CASE); } 
{ESAC}                  { return (ESAC); } 
{OF}                    { return (OF); } 
{NEW}                   { return (NEW); } 
{NOT}                   { return (NOT); } 
{ISVOID}                { return (ISVOID); } 
{TRUE_CONST}            { cool_yylval.boolean = 1;
                          return (BOOL_CONST); } 
{FALSE_CONST}           { cool_yylval.boolean = 0;
                          return (BOOL_CONST); } 

{TYPEID}                { cool_yylval.symbol = idtable.add_string(yytext);
                          return (TYPEID); } 
{OBJECTID}              { cool_yylval.symbol = idtable.add_string(yytext);
                          return (OBJECTID); } 


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
"\""                     { string_buf_ptr = string_buf;
                           errors = 0;
                           BEGIN STRING; }
<STRING>{
  \n                     { BEGIN 0;
                           if (errors == 0) {
                             cool_yylval.error_msg = "Unterminated string constant";
                           }
                           curr_lineno++;
                           return(ERROR); 
                         }
  \0                     { errors++;
                           cool_yylval.error_msg = "String contains null character.";
                         }
  \\\n                   { if (string_buf_ptr >= string_buf + MAX_STR_CONST - 1) {
                             cool_yylval.error_msg = "String constant too long";
                             errors++;
                            } else {
                             *string_buf_ptr++ = '\n';
                            }
                            curr_lineno++;
                         }
  \\b                    { *string_buf_ptr++ = '\b'; }
  \\t                    { *string_buf_ptr++ = '\t'; }
  \\n                    { //curr_lineno++;
                           if (string_buf_ptr >= string_buf + MAX_STR_CONST - 1) {
                             cool_yylval.error_msg = "String constant too long";
                             errors++;
                            } else {
                             *string_buf_ptr++ = '\n';
                            }
                         }
  \\f                    { *string_buf_ptr++ = '\f'; }
  \\.                    {  if (string_buf_ptr >= string_buf + MAX_STR_CONST - 1) {
                              cool_yylval.error_msg = "String constant too long";
                              errors++;
                            } else if (yytext[1] == '\0') {
                              errors++;
                              cool_yylval.error_msg = "String contains escaped null character.";
                            } else {
                              *string_buf_ptr++ = yytext[1]; 
                            }
                         }
  \"                     {
                           BEGIN 0;
                           if (errors == 0) {
                             *string_buf_ptr++ = '\0';
                             cool_yylval.symbol = stringtable.add_string(string_buf);
                             return STR_CONST;
                           } else {
                             return ERROR;
                           }
                         }
  <<EOF>>                { if (eofs == 0 && errors == 0) {
                             cool_yylval.error_msg = "EOF in string constant";
                             eofs++; 
                             return (ERROR);
                           }
                           return (0); }
  .                      { if (string_buf_ptr >= string_buf + MAX_STR_CONST - 1) {
                             cool_yylval.error_msg = "String constant too long";
                             errors++;
                            } else {
                             *string_buf_ptr++ = yytext[0]; 
                           }
                         }
}

{INT_CONST}             { cool_yylval.symbol = inttable.add_string(yytext);
                          return (INT_CONST); } 
[+/\-*=<.~,;:()@{}]     { return yytext[0]; }
{SPACE}                 ;
\013                    ;
\014                    ;
\015                    ;
\n                      { curr_lineno++; }
"*)"                    { cool_yylval.error_msg = "Unmatched *)";
                          return (ERROR); }
.                       { cool_yylval.error_msg = yytext;
                          return (ERROR); }

%%
