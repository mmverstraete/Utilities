FUNCTION strstr, $
   arg, $
   DEBUG = debug, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function converts the value of the alphanumeric
   ;  positional parameter arg into a string without any white space in
   ;  the front or at the back.
   ;
   ;  ALGORITHM: This routine converts the input positional parameter arg
   ;  to a STRING and strips any white space in the front or back.
   ;
   ;  SYNTAX: res = strstr(arg, DEBUG = debug, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   arg {alphanumeric} [I]: The alphanumeric input variable to
   ;      process.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   DEBUG = debug {INT} [I] (Default value: 0): Flag to activate (1)
   ;      or skip (0) debugging tests.
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: STRING.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns the string representation of the input positional
   ;      parameter arg to the calling routine, and the keyword parameter
   ;      excpt_cond is set to a null string, if the optional input
   ;      keyword parameter DEBUG is set and if the optional output
   ;      keyword parameter EXCPT_COND is provided.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a null string and the keyword parameter excpt_cond
   ;      contains a message about the exception condition encountered, if
   ;      the optional input keyword parameter DEBUG is set and if the
   ;      optional output keyword parameter EXCPT_COND is provided.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Positional parameter arg is not of type alphanumeric.
   ;
   ;  *   Error 200: Unexpected condition, check the type of input
   ;      positional parameter arg.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   is_alphanum.pro
   ;
   ;  *   is_numeric.pro
   ;
   ;  *   is_string.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: The input positional parameter arg can be an array, in
   ;      which case each array element is converted into a string without
   ;      any blank space in the front or at the back.
   ;
   ;  *   NOTE 2: Note that if an exception condition is encountered, this
   ;      function calls itself recursively to output the corresponding
   ;      message.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> pi = 3.14159
   ;      IDL> PRINT, pi
   ;            3.14159
   ;      IDL> res = strstr(pi)
   ;      IDL> PRINT, res
   ;      3.14159
   ;
   ;      IDL> a = '   Hello   '
   ;      IDL> PRINT, '>' + a + '<'
   ;      >   Hello   <
   ;      IDL> res = strstr(a)
   ;      IDL> PRINT, '>' + res + '<'
   ;      >Hello<
   ;
   ;      IDL> a = CREATE_STRUCT('A', 1, 'B', 'xxx')
   ;      IDL> res = strstr(a, /DEBUG, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, '>' + res + '<'
   ;      ><
   ;      IDL> PRINT, excpt_cond
   ;      Error 110 in routine STRSTR: Input positional
   ;         parameter arg is not an alphanumeric expression.
   ;
   ;      IDL> b = ['   Hello   ', '   World   ']
   ;      IDL> res = strstr(b)
   ;      IDL> PRINT, '>' + res[0] + '<' + ' ' + '>' + res[1] + '<'
   ;      >Hello< >World<
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2017–07–05: Version 0.9 — Initial release.
   ;
   ;  *   2017–11–20: Version 1.0 — Initial public release.
   ;
   ;  *   2018–01–15: Version 1.1 — Implement optional debugging.
   ;
   ;  *   2018–06–01: Version 1.5 — Implement new coding standards.
   ;
   ;  *   2019–01–28: Version 2.00 — Systematic update of all routines to
   ;      implement stricter coding standards and improve documentation.
   ;
   ;  *   2019–08–20: Version 2.1.0 — Adopt revised coding and
   ;      documentation standards (in particular regarding the assignment
   ;      of numeric return codes), and switch to 3-parts version
   ;      identifiers.
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017-2020 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following three
   ;      conditions:
   ;
   ;      1. The above copyright notice and this permission notice shall
   ;      be included in their entirety in all copies or substantial
   ;      portions of the Software.
   ;
   ;      2. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
   ;      KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
   ;      WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
   ;      AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;      3. The current version of this Software is freely available from
   ;
   ;      https://github.com/mmverstraete.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com
   ;Sec-Cod

   COMPILE_OPT idl2, HIDDEN

   ;  Get the name of this routine:
   info = SCOPE_TRACEBACK(/STRUCTURE)
   rout_name = info[N_ELEMENTS(info) - 1].ROUTINE

   ;  Initialize the default return code:
   return_code = ''

   ;  Set the default values of flags and essential keyword parameters:
   IF (KEYWORD_SET(debug)) THEN debug = 1 ELSE debug = 0
   excpt_cond = ''

   IF (debug) THEN BEGIN

   ;  Return to the calling routine with an error message if one or more
   ;  positional parameters are missing:
      n_reqs = 1
      IF (N_PARAMS() NE n_reqs) THEN BEGIN
         error_code = 100
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Routine must be called with ' + strstr(n_reqs) + $
            ' positional parameter(s): arg.'
         RETURN, return_code
      ENDIF

   ;  Return to the calling routine with an error message if the input
   ;  positional parameter 'arg' is not an alphanumeric expression:
      IF (is_alphanum(arg) NE 1) THEN BEGIN
         error_code = 110
         excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
            ': Input positional parameter arg is not an alphanumeric expression.'
         RETURN, return_code
      ENDIF
   ENDIF

   ;  If arg is a string, return it without any extraneous white space:
   IF (is_string(arg) EQ 1) THEN RETURN, STRTRIM(arg, 2)

   ;  If arg is of numeric type, return its string representation:
   IF (is_numeric(arg) EQ 1) THEN RETURN, STRTRIM(STRING(arg), 2)

   ;  Otherwise return to the calling routine with an error message:
   error_code = 200
   excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
      ': Unexpected condition, check the type of input positional ' + $
      'parameter arg, which must be alphanumeric.'
   RETURN, return_code

END
