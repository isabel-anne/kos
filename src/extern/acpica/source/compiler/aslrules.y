NoEcho('
/******************************************************************************
 *
 * Module Name: aslrules.y - Bison/Yacc production rules
 *
 *****************************************************************************/

/******************************************************************************
 *
 * 1. Copyright Notice
 *
 * Some or all of this work - Copyright (c) 1999 - 2015, Intel Corp.
 * All rights reserved.
 *
 * 2. License
 *
 * 2.1. This is your license from Intel Corp. under its intellectual property
 * rights. You may have additional license terms from the party that provided
 * you this software, covering your right to use that party's intellectual
 * property rights.
 *
 * 2.2. Intel grants, free of charge, to any person ("Licensee") obtaining a
 * copy of the source code appearing in this file ("Covered Code") an
 * irrevocable, perpetual, worldwide license under Intel's copyrights in the
 * base code distributed originally by Intel ("Original Intel Code") to copy,
 * make derivatives, distribute, use and display any portion of the Covered
 * Code in any form, with the right to sublicense such rights; and
 *
 * 2.3. Intel grants Licensee a non-exclusive and non-transferable patent
 * license (with the right to sublicense), under only those claims of Intel
 * patents that are infringed by the Original Intel Code, to make, use, sell,
 * offer to sell, and import the Covered Code and derivative works thereof
 * solely to the minimum extent necessary to exercise the above copyright
 * license, and in no event shall the patent license extend to any additions
 * to or modifications of the Original Intel Code. No other license or right
 * is granted directly or by implication, estoppel or otherwise;
 *
 * The above copyright and patent license is granted only if the following
 * conditions are met:
 *
 * 3. Conditions
 *
 * 3.1. Redistribution of Source with Rights to Further Distribute Source.
 * Redistribution of source code of any substantial portion of the Covered
 * Code or modification with rights to further distribute source must include
 * the above Copyright Notice, the above License, this list of Conditions,
 * and the following Disclaimer and Export Compliance provision. In addition,
 * Licensee must cause all Covered Code to which Licensee contributes to
 * contain a file documenting the changes Licensee made to create that Covered
 * Code and the date of any change. Licensee must include in that file the
 * documentation of any changes made by any predecessor Licensee. Licensee
 * must include a prominent statement that the modification is derived,
 * directly or indirectly, from Original Intel Code.
 *
 * 3.2. Redistribution of Source with no Rights to Further Distribute Source.
 * Redistribution of source code of any substantial portion of the Covered
 * Code or modification without rights to further distribute source must
 * include the following Disclaimer and Export Compliance provision in the
 * documentation and/or other materials provided with distribution. In
 * addition, Licensee may not authorize further sublicense of source of any
 * portion of the Covered Code, and must include terms to the effect that the
 * license from Licensee to its licensee is limited to the intellectual
 * property embodied in the software Licensee provides to its licensee, and
 * not to intellectual property embodied in modifications its licensee may
 * make.
 *
 * 3.3. Redistribution of Executable. Redistribution in executable form of any
 * substantial portion of the Covered Code or modification must reproduce the
 * above Copyright Notice, and the following Disclaimer and Export Compliance
 * provision in the documentation and/or other materials provided with the
 * distribution.
 *
 * 3.4. Intel retains all right, title, and interest in and to the Original
 * Intel Code.
 *
 * 3.5. Neither the name Intel nor any other trademark owned or controlled by
 * Intel shall be used in advertising or otherwise to promote the sale, use or
 * other dealings in products derived from or relating to the Covered Code
 * without prior written authorization from Intel.
 *
 * 4. Disclaimer and Export Compliance
 *
 * 4.1. INTEL MAKES NO WARRANTY OF ANY KIND REGARDING ANY SOFTWARE PROVIDED
 * HERE. ANY SOFTWARE ORIGINATING FROM INTEL OR DERIVED FROM INTEL SOFTWARE
 * IS PROVIDED "AS IS," AND INTEL WILL NOT PROVIDE ANY SUPPORT, ASSISTANCE,
 * INSTALLATION, TRAINING OR OTHER SERVICES. INTEL WILL NOT PROVIDE ANY
 * UPDATES, ENHANCEMENTS OR EXTENSIONS. INTEL SPECIFICALLY DISCLAIMS ANY
 * IMPLIED WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT AND FITNESS FOR A
 * PARTICULAR PURPOSE.
 *
 * 4.2. IN NO EVENT SHALL INTEL HAVE ANY LIABILITY TO LICENSEE, ITS LICENSEES
 * OR ANY OTHER THIRD PARTY, FOR ANY LOST PROFITS, LOST DATA, LOSS OF USE OR
 * COSTS OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, OR FOR ANY INDIRECT,
 * SPECIAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THIS AGREEMENT, UNDER ANY
 * CAUSE OF ACTION OR THEORY OF LIABILITY, AND IRRESPECTIVE OF WHETHER INTEL
 * HAS ADVANCE NOTICE OF THE POSSIBILITY OF SUCH DAMAGES. THESE LIMITATIONS
 * SHALL APPLY NOTWITHSTANDING THE FAILURE OF THE ESSENTIAL PURPOSE OF ANY
 * LIMITED REMEDY.
 *
 * 4.3. Licensee shall not export, either directly or indirectly, any of this
 * software or system incorporating such software without first obtaining any
 * required license or other approval from the U. S. Department of Commerce or
 * any other agency or department of the United States Government. In the
 * event Licensee exports any such software from the United States or
 * re-exports any such software from a foreign destination, Licensee shall
 * ensure that the distribution and export/re-export of the software is in
 * compliance with all laws, regulations, orders, or other restrictions of the
 * U.S. Export Administration Regulations. Licensee agrees that neither it nor
 * any of its subsidiaries will export/re-export any technical data, process,
 * software, or service, directly or indirectly, to any country for which the
 * United States government or any agency thereof requires an export license,
 * other governmental approval, or letter of assurance, without first obtaining
 * such license, approval or letter.
 *
 *****************************************************************************/

')

/*******************************************************************************
 *
 * Production rules start here
 *
 ******************************************************************************/

/*
 * ASL Names
 *
 * Root rule. Allow multiple #line directives before the definition block
 * to handle output from preprocessors
 */
ASLCode
    : DefinitionBlockTerm
    | error                         {YYABORT; $$ = NULL;}
    ;

/*
 * Blocks, Data, and Opcodes
 */

/*
 * Note concerning support for "module-level code".
 *
 * ACPI 1.0 allowed Type1 and Type2 executable opcodes outside of control
 * methods (the so-called module-level code.) This support was explicitly
 * removed in ACPI 2.0, but this type of code continues to be created by
 * BIOS vendors. In order to support the disassembly and recompilation of
 * such code (and the porting of ASL code to iASL), iASL supports this
 * code in violation of the current ACPI specification.
 *
 * The grammar change to support module-level code is to revert the
 * {ObjectList} portion of the DefinitionBlockTerm in ACPI 2.0 to the
 * original use of {TermList} instead (see below.) This allows the use
 * of Type1 and Type2 opcodes at module level.
 */
DefinitionBlockTerm
    : PARSEOP_DEFINITIONBLOCK '('   {$<n>$ = TrCreateLeafNode (PARSEOP_DEFINITIONBLOCK);}
        String ','
        String ','
        ByteConst ','
        String ','
        String ','
        DWordConst
        ')'                         {TrSetEndLineNumber ($<n>3);}
            '{' TermList '}'        {$$ = TrLinkChildren ($<n>3,7,$4,$6,$8,$10,$12,$14,$18);}
    ;

    /*
     * ASL Extensions: C-style math/logical operators and expressions.
     * The implementation transforms these operators into the standard
     * AML opcodes and syntax.
     *
     * Supported operators and precedence rules (high-to-low)
     *
     * NOTE: The operator precedence and associativity rules are
     * implemented by the tokens in asltokens.y
     *
     * (left-to-right):
     *  1)      ( ) expr++ expr--
     *
     * (right-to-left):
     *  2)      ! ~
     *
     * (left-to-right):
     *  3)      *   /   %
     *  4)      +   -
     *  5)      >>  <<
     *  6)      <   >   <=  >=
     *  7)      ==  !=
     *  8)      &
     *  9)      ^
     *  10)     |
     *  11)     &&
     *  12)     ||
     *
     * (right-to-left):
     *  13)     = += -= *= /= %= <<= >>= &= ^= |=
     */
Expression

    /* Unary operators */

    : PARSEOP_EXP_LOGICAL_NOT           {$<n>$ = TrCreateLeafNode (PARSEOP_LNOT);}
        TermArg                         {$$ = TrLinkChildren ($<n>2,1,$3);}
    | PARSEOP_EXP_NOT                   {$<n>$ = TrCreateLeafNode (PARSEOP_NOT);}
        TermArg                         {$$ = TrLinkChildren ($<n>2,2,$3,TrCreateNullTarget ());}

    | SuperName PARSEOP_EXP_INCREMENT   {$<n>$ = TrCreateLeafNode (PARSEOP_INCREMENT);}
                                        {$$ = TrLinkChildren ($<n>3,1,$1);}
    | SuperName PARSEOP_EXP_DECREMENT   {$<n>$ = TrCreateLeafNode (PARSEOP_DECREMENT);}
                                        {$$ = TrLinkChildren ($<n>3,1,$1);}

    /* Binary operators: math and logical */

    | TermArg PARSEOP_EXP_ADD           {$<n>$ = TrCreateLeafNode (PARSEOP_ADD);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_DIVIDE        {$<n>$ = TrCreateLeafNode (PARSEOP_DIVIDE);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,4,$1,$4,TrCreateNullTarget (),
                                            TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_MODULO        {$<n>$ = TrCreateLeafNode (PARSEOP_MOD);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_MULTIPLY      {$<n>$ = TrCreateLeafNode (PARSEOP_MULTIPLY);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_SHIFT_LEFT    {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTLEFT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_SHIFT_RIGHT   {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTRIGHT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_SUBTRACT      {$<n>$ = TrCreateLeafNode (PARSEOP_SUBTRACT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}

    | TermArg PARSEOP_EXP_AND           {$<n>$ = TrCreateLeafNode (PARSEOP_AND);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_OR            {$<n>$ = TrCreateLeafNode (PARSEOP_OR);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}
    | TermArg PARSEOP_EXP_XOR           {$<n>$ = TrCreateLeafNode (PARSEOP_XOR);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,TrCreateNullTarget ());}

    | TermArg PARSEOP_EXP_GREATER       {$<n>$ = TrCreateLeafNode (PARSEOP_LGREATER);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}
    | TermArg PARSEOP_EXP_GREATER_EQUAL {$<n>$ = TrCreateLeafNode (PARSEOP_LGREATEREQUAL);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}
    | TermArg PARSEOP_EXP_LESS          {$<n>$ = TrCreateLeafNode (PARSEOP_LLESS);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}
    | TermArg PARSEOP_EXP_LESS_EQUAL    {$<n>$ = TrCreateLeafNode (PARSEOP_LLESSEQUAL);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}

    | TermArg PARSEOP_EXP_EQUAL         {$<n>$ = TrCreateLeafNode (PARSEOP_LEQUAL);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}
    | TermArg PARSEOP_EXP_NOT_EQUAL     {$<n>$ = TrCreateLeafNode (PARSEOP_LNOTEQUAL);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}

    | TermArg PARSEOP_EXP_LOGICAL_AND   {$<n>$ = TrCreateLeafNode (PARSEOP_LAND);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}
    | TermArg PARSEOP_EXP_LOGICAL_OR    {$<n>$ = TrCreateLeafNode (PARSEOP_LOR);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,2,$1,$4);}

      /* Parentheses */

    | '(' TermArg ')'                   { $$ = $2;}
    ;

EqualsTerm

    /* All assignment-type operations */

    : SuperName PARSEOP_EXP_EQUALS
        TermArg                         {$$ = TrCreateAssignmentNode ($1, $3);}

    | TermArg PARSEOP_EXP_ADD_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_ADD);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_DIV_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_DIVIDE);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,4,$1,$4,TrCreateNullTarget (),
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_MOD_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_MOD);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_MUL_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_MULTIPLY);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_SHL_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTLEFT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_SHR_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTRIGHT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_SUB_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_SUBTRACT);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_AND_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_AND);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_OR_EQ         {$<n>$ = TrCreateLeafNode (PARSEOP_OR);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}

    | TermArg PARSEOP_EXP_XOR_EQ        {$<n>$ = TrCreateLeafNode (PARSEOP_XOR);}
        TermArg                         {$$ = TrLinkChildren ($<n>3,3,$1,$4,
                                            TrSetNodeFlags (TrCreateTargetOperand ($1, NULL), NODE_IS_TARGET));}
    ;


/* ACPI 3.0 -- allow semicolons between terms */

TermList
    :                               {$$ = NULL;}
    | TermList Term                 {$$ = TrLinkPeerNode (TrSetNodeFlags ($1, NODE_RESULT_NOT_USED),$2);}
    | TermList Term ';'             {$$ = TrLinkPeerNode (TrSetNodeFlags ($1, NODE_RESULT_NOT_USED),$2);}
    | TermList ';' Term             {$$ = TrLinkPeerNode (TrSetNodeFlags ($1, NODE_RESULT_NOT_USED),$3);}
    | TermList ';' Term ';'         {$$ = TrLinkPeerNode (TrSetNodeFlags ($1, NODE_RESULT_NOT_USED),$3);}
    ;

Term
    : Object                        {}
    | Type1Opcode                   {}
    | Type2Opcode                   {}
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Type2StringOpcode             {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Type2BufferOpcode             {}
    | Type2BufferOrStringOpcode     {}
    | error                         {$$ = AslDoError(); yyclearin;}
    ;

CompilerDirective
    : IncludeTerm                   {}
    | ExternalTerm                  {}
    ;

ObjectList
    :                               {$$ = NULL;}
    | ObjectList Object             {$$ = TrLinkPeerNode ($1,$2);}
    | error                         {$$ = AslDoError(); yyclearin;}
    ;

Object
    : CompilerDirective             {}
    | NamedObject                   {}
    | NameSpaceModifier             {}
    ;

DataObject
    : BufferData                    {}
    | PackageData                   {}
    | IntegerData                   {}
    | StringData                    {}
    ;

BufferData
    : Type5Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Type2BufferOrStringOpcode     {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Type2BufferOpcode             {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | BufferTerm                    {}
    ;

PackageData
    : PackageTerm                   {}
    ;

IntegerData
    : Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Type3Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | Integer                       {}
    | ConstTerm                     {}
    ;

StringData
    : Type2StringOpcode             {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | String                        {}
    ;

NamedObject
    : BankFieldTerm                 {}
    | CreateBitFieldTerm            {}
    | CreateByteFieldTerm           {}
    | CreateDWordFieldTerm          {}
    | CreateFieldTerm               {}
    | CreateQWordFieldTerm          {}
    | CreateWordFieldTerm           {}
    | DataRegionTerm                {}
    | DeviceTerm                    {}
    | EventTerm                     {}
    | FieldTerm                     {}
    | FunctionTerm                  {}
    | IndexFieldTerm                {}
    | MethodTerm                    {}
    | MutexTerm                     {}
    | OpRegionTerm                  {}
    | PowerResTerm                  {}
    | ProcessorTerm                 {}
    | ThermalZoneTerm               {}
    ;

NameSpaceModifier
    : AliasTerm                     {}
    | NameTerm                      {}
    | ScopeTerm                     {}
    ;

MethodInvocationTerm
    : NameString '('                {TrUpdateNode (PARSEOP_METHODCALL, $1);}
        ArgList ')'                 {$$ = TrLinkChildNode ($1,$4);}
    ;

ArgList
    :                               {$$ = NULL;}
    | TermArg
    | ArgList ','                   /* Allows a trailing comma at list end */
    | ArgList ','
        TermArg                     {$$ = TrLinkPeerNode ($1,$3);}
    ;

/*
Removed from TermArg due to reduce/reduce conflicts
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | Type2StringOpcode             {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | Type2BufferOpcode             {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | Type2BufferOrStringOpcode     {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}

*/

TermArg
    : Type2Opcode                   {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | DataObject                    {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | NameString                    {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | ArgTerm                       {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    | LocalTerm                     {$$ = TrSetNodeFlags ($1, NODE_IS_TERM_ARG);}
    ;

Target
    :                               {$$ = TrCreateNullTarget ();} /* Placeholder is a ZeroOp object */
    | ','                           {$$ = TrCreateNullTarget ();} /* Placeholder is a ZeroOp object */
    | ',' SuperName                 {$$ = TrSetNodeFlags ($2, NODE_IS_TARGET);}
    ;

RequiredTarget
    : ',' SuperName                 {$$ = TrSetNodeFlags ($2, NODE_IS_TARGET);}
    ;

SimpleTarget
    : NameString                    {}
    | LocalTerm                     {}
    | ArgTerm                       {}
    ;

/* Rules for specifying the type of one method argument or return value */

ParameterTypePackage
    :                               {$$ = NULL;}
    | ObjectTypeKeyword             {$$ = $1;}
    | ParameterTypePackage ','
        ObjectTypeKeyword           {$$ = TrLinkPeerNodes (2,$1,$3);}
    ;

ParameterTypePackageList
    :                               {$$ = NULL;}
    | ObjectTypeKeyword             {$$ = $1;}
    | '{' ParameterTypePackage '}'  {$$ = $2;}
    ;

OptionalParameterTypePackage
    :                               {$$ = TrCreateLeafNode (PARSEOP_DEFAULT_ARG);}
    | ',' ParameterTypePackageList  {$$ = TrLinkChildren (TrCreateLeafNode (PARSEOP_DEFAULT_ARG),1,$2);}
    ;

/* Rules for specifying the types for method arguments */

ParameterTypesPackage
    : ParameterTypePackageList      {$$ = $1;}
    | ParameterTypesPackage ','
        ParameterTypePackageList    {$$ = TrLinkPeerNodes (2,$1,$3);}
    ;

ParameterTypesPackageList
    :                               {$$ = NULL;}
    | ObjectTypeKeyword             {$$ = $1;}
    | '{' ParameterTypesPackage '}' {$$ = $2;}
    ;

OptionalParameterTypesPackage
    :                               {$$ = TrCreateLeafNode (PARSEOP_DEFAULT_ARG);}
    | ',' ParameterTypesPackageList {$$ = TrLinkChildren (TrCreateLeafNode (PARSEOP_DEFAULT_ARG),1,$2);}
    ;


/* Opcode types */

Type1Opcode
    : BreakTerm                     {}
    | BreakPointTerm                {}
    | ContinueTerm                  {}
    | FatalTerm                     {}
    | IfElseTerm                    {}
    | LoadTerm                      {}
    | NoOpTerm                      {}
    | NotifyTerm                    {}
    | ReleaseTerm                   {}
    | ResetTerm                     {}
    | ReturnTerm                    {}
    | SignalTerm                    {}
    | SleepTerm                     {}
    | StallTerm                     {}
    | SwitchTerm                    {}
    | UnloadTerm                    {}
    | WhileTerm                     {}
    ;

Type2Opcode
    : AcquireTerm                   {}
    | CondRefOfTerm                 {}
    | CopyObjectTerm                {}
    | DerefOfTerm                   {}
    | ObjectTypeTerm                {}
    | RefOfTerm                     {}
    | SizeOfTerm                    {}
    | StoreTerm                     {}
    | EqualsTerm                    {}
    | TimerTerm                     {}
    | WaitTerm                      {}
    | MethodInvocationTerm          {}
    ;

/*
 * Type 3/4/5 opcodes
 */

Type2IntegerOpcode                  /* "Type3" opcodes */
    : Expression                    {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | AddTerm                       {}
    | AndTerm                       {}
    | DecTerm                       {}
    | DivideTerm                    {}
    | FindSetLeftBitTerm            {}
    | FindSetRightBitTerm           {}
    | FromBCDTerm                   {}
    | IncTerm                       {}
    | IndexTerm                     {}
    | LAndTerm                      {}
    | LEqualTerm                    {}
    | LGreaterTerm                  {}
    | LGreaterEqualTerm             {}
    | LLessTerm                     {}
    | LLessEqualTerm                {}
    | LNotTerm                      {}
    | LNotEqualTerm                 {}
    | LoadTableTerm                 {}
    | LOrTerm                       {}
    | MatchTerm                     {}
    | ModTerm                       {}
    | MultiplyTerm                  {}
    | NAndTerm                      {}
    | NOrTerm                       {}
    | NotTerm                       {}
    | OrTerm                        {}
    | ShiftLeftTerm                 {}
    | ShiftRightTerm                {}
    | SubtractTerm                  {}
    | ToBCDTerm                     {}
    | ToIntegerTerm                 {}
    | XOrTerm                       {}
    ;

Type2StringOpcode                   /* "Type4" Opcodes */
    : ToDecimalStringTerm           {}
    | ToHexStringTerm               {}
    | ToStringTerm                  {}
    ;

Type2BufferOpcode                   /* "Type5" Opcodes */
    : ToBufferTerm                  {}
    | ConcatResTerm                 {}
    ;

Type2BufferOrStringOpcode
    : ConcatTerm                    {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST);}
    | PrintfTerm                    {}
    | FprintfTerm                   {}
    | MidTerm                       {}
    ;

/*
 * A type 3 opcode evaluates to an Integer and cannot have a destination operand
 */

Type3Opcode
    : EISAIDTerm                    {}
    ;

/* Obsolete
Type4Opcode
    : ConcatTerm                    {}
    | ToDecimalStringTerm           {}
    | ToHexStringTerm               {}
    | MidTerm                       {}
    | ToStringTerm                  {}
    ;
*/


Type5Opcode
    : ResourceTemplateTerm          {}
    | UnicodeTerm                   {}
    | ToPLDTerm                     {}
    | ToUUIDTerm                    {}
    ;

Type6Opcode
    : RefOfTerm                     {}
    | DerefOfTerm                   {}
    | IndexTerm                     {}
    | MethodInvocationTerm          {}
    ;

IncludeTerm
    : PARSEOP_INCLUDE '('           {$<n>$ = TrCreateLeafNode (PARSEOP_INCLUDE);}
        String  ')'                 {TrLinkChildren ($<n>3,1,$4);FlOpenIncludeFile ($4);}
        TermList
        IncludeEndTerm              {$$ = TrLinkPeerNodes (3,$<n>3,$7,$8);}
    ;

IncludeEndTerm
    : PARSEOP_INCLUDE_END           {$$ = TrCreateLeafNode (PARSEOP_INCLUDE_END);}
    ;

ExternalTerm
    : PARSEOP_EXTERNAL '('
        NameString
        OptionalObjectTypeKeyword
        OptionalParameterTypePackage
        OptionalParameterTypesPackage
        ')'                         {$$ = TrCreateNode (PARSEOP_EXTERNAL,4,$3,$4,$5,$6);}
    | PARSEOP_EXTERNAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Named Objects *******************************************************/


BankFieldTerm
    : PARSEOP_BANKFIELD '('         {$<n>$ = TrCreateLeafNode (PARSEOP_BANKFIELD);}
        NameString
        NameStringItem
        TermArgItem
        ',' AccessTypeKeyword
        ',' LockRuleKeyword
        ',' UpdateRuleKeyword
        ')' '{'
            FieldUnitList '}'       {$$ = TrLinkChildren ($<n>3,7,$4,$5,$6,$8,$10,$12,$15);}
    | PARSEOP_BANKFIELD '('
        error ')' '{' error '}'     {$$ = AslDoError(); yyclearin;}
    ;

FieldUnitList
    :                               {$$ = NULL;}
    | FieldUnit
    | FieldUnitList ','             /* Allows a trailing comma at list end */
    | FieldUnitList ','
        FieldUnit                   {$$ = TrLinkPeerNode ($1,$3);}
    ;

FieldUnit
    : FieldUnitEntry                {}
    | OffsetTerm                    {}
    | AccessAsTerm                  {}
    | ConnectionTerm                {}
    ;

FieldUnitEntry
    : ',' AmlPackageLengthTerm      {$$ = TrCreateNode (PARSEOP_RESERVED_BYTES,1,$2);}
    | NameSeg ','
        AmlPackageLengthTerm        {$$ = TrLinkChildNode ($1,$3);}
    ;

OffsetTerm
    : PARSEOP_OFFSET '('
        AmlPackageLengthTerm
        ')'                         {$$ = TrCreateNode (PARSEOP_OFFSET,1,$3);}
    | PARSEOP_OFFSET '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

AccessAsTerm
    : PARSEOP_ACCESSAS '('
        AccessTypeKeyword
        OptionalAccessAttribTerm
        ')'                         {$$ = TrCreateNode (PARSEOP_ACCESSAS,2,$3,$4);}
    | PARSEOP_ACCESSAS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ConnectionTerm
    : PARSEOP_CONNECTION '('
        NameString
        ')'                         {$$ = TrCreateNode (PARSEOP_CONNECTION,1,$3);}
    | PARSEOP_CONNECTION '('        {$<n>$ = TrCreateLeafNode (PARSEOP_CONNECTION);}
        ResourceMacroTerm
        ')'                         {$$ = TrLinkChildren ($<n>3, 1,
                                            TrLinkChildren (TrCreateLeafNode (PARSEOP_RESOURCETEMPLATE), 3,
                                                TrCreateLeafNode (PARSEOP_DEFAULT_ARG),
                                                TrCreateLeafNode (PARSEOP_DEFAULT_ARG),
                                                $4));}
    | PARSEOP_CONNECTION '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateBitFieldTerm
    : PARSEOP_CREATEBITFIELD '('    {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEBITFIELD);}
        TermArg
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,TrSetNodeFlags ($6, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEBITFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateByteFieldTerm
    : PARSEOP_CREATEBYTEFIELD '('   {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEBYTEFIELD);}
        TermArg
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,TrSetNodeFlags ($6, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEBYTEFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateDWordFieldTerm
    : PARSEOP_CREATEDWORDFIELD '('  {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEDWORDFIELD);}
        TermArg
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,TrSetNodeFlags ($6, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEDWORDFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateFieldTerm
    : PARSEOP_CREATEFIELD '('       {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEFIELD);}
        TermArg
        TermArgItem
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,4,$4,$5,$6,TrSetNodeFlags ($7, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateQWordFieldTerm
    : PARSEOP_CREATEQWORDFIELD '('  {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEQWORDFIELD);}
        TermArg
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,TrSetNodeFlags ($6, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEQWORDFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CreateWordFieldTerm
    : PARSEOP_CREATEWORDFIELD '('   {$<n>$ = TrCreateLeafNode (PARSEOP_CREATEWORDFIELD);}
        TermArg
        TermArgItem
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,TrSetNodeFlags ($6, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_CREATEWORDFIELD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DataRegionTerm
    : PARSEOP_DATATABLEREGION '('   {$<n>$ = TrCreateLeafNode (PARSEOP_DATATABLEREGION);}
        NameString
        TermArgItem
        TermArgItem
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,4,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$5,$6,$7);}
    | PARSEOP_DATATABLEREGION '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DeviceTerm
    : PARSEOP_DEVICE '('            {$<n>$ = TrCreateLeafNode (PARSEOP_DEVICE);}
        NameString
        ')' '{'
            ObjectList '}'          {$$ = TrLinkChildren ($<n>3,2,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$7);}
    | PARSEOP_DEVICE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

EventTerm
    : PARSEOP_EVENT '('             {$<n>$ = TrCreateLeafNode (PARSEOP_EVENT);}
        NameString
        ')'                         {$$ = TrLinkChildren ($<n>3,1,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_EVENT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FieldTerm
    : PARSEOP_FIELD '('             {$<n>$ = TrCreateLeafNode (PARSEOP_FIELD);}
        NameString
        ',' AccessTypeKeyword
        ',' LockRuleKeyword
        ',' UpdateRuleKeyword
        ')' '{'
            FieldUnitList '}'       {$$ = TrLinkChildren ($<n>3,5,$4,$6,$8,$10,$13);}
    | PARSEOP_FIELD '('
        error ')' '{' error '}'     {$$ = AslDoError(); yyclearin;}
    ;

FunctionTerm
    : PARSEOP_FUNCTION '('          {$<n>$ = TrCreateLeafNode (PARSEOP_METHOD);}
        NameString
        OptionalParameterTypePackage
        OptionalParameterTypesPackage
        ')' '{'
            TermList '}'            {$$ = TrLinkChildren ($<n>3,7,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),
                                        TrCreateValuedLeafNode (PARSEOP_BYTECONST, 0),
                                        TrCreateLeafNode (PARSEOP_SERIALIZERULE_NOTSERIAL),
                                        TrCreateValuedLeafNode (PARSEOP_BYTECONST, 0),$5,$6,$9);}
    | PARSEOP_FUNCTION '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IndexFieldTerm
    : PARSEOP_INDEXFIELD '('        {$<n>$ = TrCreateLeafNode (PARSEOP_INDEXFIELD);}
        NameString
        NameStringItem
        ',' AccessTypeKeyword
        ',' LockRuleKeyword
        ',' UpdateRuleKeyword
        ')' '{'
            FieldUnitList '}'       {$$ = TrLinkChildren ($<n>3,6,$4,$5,$7,$9,$11,$14);}
    | PARSEOP_INDEXFIELD '('
        error ')' '{' error '}'     {$$ = AslDoError(); yyclearin;}
    ;

MethodTerm
    : PARSEOP_METHOD  '('           {$<n>$ = TrCreateLeafNode (PARSEOP_METHOD);}
        NameString
        OptionalByteConstExpr       {UtCheckIntegerRange ($5, 0, 7);}
        OptionalSerializeRuleKeyword
        OptionalByteConstExpr
        OptionalParameterTypePackage
        OptionalParameterTypesPackage
        ')' '{'
            TermList '}'            {$$ = TrLinkChildren ($<n>3,7,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$5,$7,$8,$9,$10,$13);}
    | PARSEOP_METHOD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

MutexTerm
    : PARSEOP_MUTEX '('             {$<n>$ = TrCreateLeafNode (PARSEOP_MUTEX);}
        NameString
        ',' ByteConstExpr
        ')'                         {$$ = TrLinkChildren ($<n>3,2,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$6);}
    | PARSEOP_MUTEX '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

OpRegionTerm
    : PARSEOP_OPERATIONREGION '('   {$<n>$ = TrCreateLeafNode (PARSEOP_OPERATIONREGION);}
        NameString
        ',' OpRegionSpaceIdTerm
        TermArgItem
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,4,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$6,$7,$8);}
    | PARSEOP_OPERATIONREGION '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

OpRegionSpaceIdTerm
    : RegionSpaceKeyword            {}
    | ByteConst                     {$$ = UtCheckIntegerRange ($1, 0x80, 0xFF);}
    ;

PowerResTerm
    : PARSEOP_POWERRESOURCE '('     {$<n>$ = TrCreateLeafNode (PARSEOP_POWERRESOURCE);}
        NameString
        ',' ByteConstExpr
        ',' WordConstExpr
        ')' '{'
            ObjectList '}'          {$$ = TrLinkChildren ($<n>3,4,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$6,$8,$11);}
    | PARSEOP_POWERRESOURCE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ProcessorTerm
    : PARSEOP_PROCESSOR '('         {$<n>$ = TrCreateLeafNode (PARSEOP_PROCESSOR);}
        NameString
        ',' ByteConstExpr
        OptionalDWordConstExpr
        OptionalByteConstExpr
        ')' '{'
            ObjectList '}'          {$$ = TrLinkChildren ($<n>3,5,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$6,$7,$8,$11);}
    | PARSEOP_PROCESSOR '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ThermalZoneTerm
    : PARSEOP_THERMALZONE '('       {$<n>$ = TrCreateLeafNode (PARSEOP_THERMALZONE);}
        NameString
        ')' '{'
            ObjectList '}'          {$$ = TrLinkChildren ($<n>3,2,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$7);}
    | PARSEOP_THERMALZONE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Namespace modifiers *************************************************/


AliasTerm
    : PARSEOP_ALIAS '('             {$<n>$ = TrCreateLeafNode (PARSEOP_ALIAS);}
        NameString
        NameStringItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,TrSetNodeFlags ($5, NODE_IS_NAME_DECLARATION));}
    | PARSEOP_ALIAS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

NameTerm
    : PARSEOP_NAME '('              {$<n>$ = TrCreateLeafNode (PARSEOP_NAME);}
        NameString
        ',' DataObject
        ')'                         {$$ = TrLinkChildren ($<n>3,2,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$6);}
    | PARSEOP_NAME '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ScopeTerm
    : PARSEOP_SCOPE '('             {$<n>$ = TrCreateLeafNode (PARSEOP_SCOPE);}
        NameString
        ')' '{'
            ObjectList '}'          {$$ = TrLinkChildren ($<n>3,2,TrSetNodeFlags ($4, NODE_IS_NAME_DECLARATION),$7);}
    | PARSEOP_SCOPE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Type 1 opcodes *******************************************************/


BreakTerm
    : PARSEOP_BREAK                 {$$ = TrCreateNode (PARSEOP_BREAK, 0);}
    ;

BreakPointTerm
    : PARSEOP_BREAKPOINT            {$$ = TrCreateNode (PARSEOP_BREAKPOINT, 0);}
    ;

ContinueTerm
    : PARSEOP_CONTINUE              {$$ = TrCreateNode (PARSEOP_CONTINUE, 0);}
    ;

FatalTerm
    : PARSEOP_FATAL '('             {$<n>$ = TrCreateLeafNode (PARSEOP_FATAL);}
        ByteConstExpr
        ',' DWordConstExpr
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$6,$7);}
    | PARSEOP_FATAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IfElseTerm
    : IfTerm ElseTerm               {$$ = TrLinkPeerNode ($1,$2);}
    ;

IfTerm
    : PARSEOP_IF '('                {$<n>$ = TrCreateLeafNode (PARSEOP_IF);}
        TermArg
        ')' '{'
            TermList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}

    | PARSEOP_IF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ElseTerm
    :                               {$$ = NULL;}
    | PARSEOP_ELSE '{'              {$<n>$ = TrCreateLeafNode (PARSEOP_ELSE);}
        TermList '}'                {$$ = TrLinkChildren ($<n>3,1,$4);}

    | PARSEOP_ELSE '{'
        error '}'                   {$$ = AslDoError(); yyclearin;}

    | PARSEOP_ELSE
        error                       {$$ = AslDoError(); yyclearin;}

    | PARSEOP_ELSEIF '('            {$<n>$ = TrCreateLeafNode (PARSEOP_ELSE);}
        TermArg                     {$<n>$ = TrCreateLeafNode (PARSEOP_IF);}
        ')' '{'
            TermList '}'            {TrLinkChildren ($<n>5,2,$4,$8);}
        ElseTerm                    {TrLinkPeerNode ($<n>5,$11);}
                                    {$$ = TrLinkChildren ($<n>3,1,$<n>5);}

    | PARSEOP_ELSEIF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}

    | PARSEOP_ELSEIF
        error                       {$$ = AslDoError(); yyclearin;}
    ;

LoadTerm
    : PARSEOP_LOAD '('              {$<n>$ = TrCreateLeafNode (PARSEOP_LOAD);}
        NameString
        RequiredTarget
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LOAD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

NoOpTerm
    : PARSEOP_NOOP                  {$$ = TrCreateNode (PARSEOP_NOOP, 0);}
    ;

NotifyTerm
    : PARSEOP_NOTIFY '('            {$<n>$ = TrCreateLeafNode (PARSEOP_NOTIFY);}
        SuperName
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_NOTIFY '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ReleaseTerm
    : PARSEOP_RELEASE '('           {$<n>$ = TrCreateLeafNode (PARSEOP_RELEASE);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_RELEASE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ResetTerm
    : PARSEOP_RESET '('             {$<n>$ = TrCreateLeafNode (PARSEOP_RESET);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_RESET '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ReturnTerm
    : PARSEOP_RETURN '('            {$<n>$ = TrCreateLeafNode (PARSEOP_RETURN);}
        OptionalReturnArg
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_RETURN                {$$ = TrLinkChildren (TrCreateLeafNode (PARSEOP_RETURN),1,TrSetNodeFlags (TrCreateLeafNode (PARSEOP_ZERO), NODE_IS_NULL_RETURN));}
    | PARSEOP_RETURN '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SignalTerm
    : PARSEOP_SIGNAL '('            {$<n>$ = TrCreateLeafNode (PARSEOP_SIGNAL);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_SIGNAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SleepTerm
    : PARSEOP_SLEEP '('             {$<n>$ = TrCreateLeafNode (PARSEOP_SLEEP);}
        TermArg
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_SLEEP '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

StallTerm
    : PARSEOP_STALL '('             {$<n>$ = TrCreateLeafNode (PARSEOP_STALL);}
        TermArg
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_STALL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SwitchTerm
    : PARSEOP_SWITCH '('            {$<n>$ = TrCreateLeafNode (PARSEOP_SWITCH);}
        TermArg
        ')' '{'
            CaseDefaultTermList '}'
                                    {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_SWITCH '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

/*
 * Case-Default list; allow only one Default term and unlimited Case terms
 */

CaseDefaultTermList
    :                               {$$ = NULL;}
    | CaseTerm  {}
    | DefaultTerm   {}
    | CaseDefaultTermList
        CaseTerm                    {$$ = TrLinkPeerNode ($1,$2);}
    | CaseDefaultTermList
        DefaultTerm                 {$$ = TrLinkPeerNode ($1,$2);}

/* Original - attempts to force zero or one default term within the switch */

/*
CaseDefaultTermList
    :                               {$$ = NULL;}
    | CaseTermList
        DefaultTerm
        CaseTermList                {$$ = TrLinkPeerNode ($1,TrLinkPeerNode ($2, $3));}
    | CaseTermList
        CaseTerm                    {$$ = TrLinkPeerNode ($1,$2);}
    ;

CaseTermList
    :                               {$$ = NULL;}
    | CaseTerm                      {}
    | CaseTermList
        CaseTerm                    {$$ = TrLinkPeerNode ($1,$2);}
    ;
*/

CaseTerm
    : PARSEOP_CASE '('              {$<n>$ = TrCreateLeafNode (PARSEOP_CASE);}
        DataObject
        ')' '{'
            TermList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_CASE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DefaultTerm
    : PARSEOP_DEFAULT '{'           {$<n>$ = TrCreateLeafNode (PARSEOP_DEFAULT);}
        TermList '}'                {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_DEFAULT '{'
        error '}'                   {$$ = AslDoError(); yyclearin;}
    ;

UnloadTerm
    : PARSEOP_UNLOAD '('            {$<n>$ = TrCreateLeafNode (PARSEOP_UNLOAD);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_UNLOAD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

WhileTerm
    : PARSEOP_WHILE '('             {$<n>$ = TrCreateLeafNode (PARSEOP_WHILE);}
        TermArg
        ')' '{' TermList '}'
                                    {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_WHILE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Type 2 opcodes *******************************************************/

AcquireTerm
    : PARSEOP_ACQUIRE '('           {$<n>$ = TrCreateLeafNode (PARSEOP_ACQUIRE);}
        SuperName
        ',' WordConstExpr
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$6);}
    | PARSEOP_ACQUIRE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

AddTerm
    : PARSEOP_ADD '('               {$<n>$ = TrCreateLeafNode (PARSEOP_ADD);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_ADD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

AndTerm
    : PARSEOP_AND '('               {$<n>$ = TrCreateLeafNode (PARSEOP_AND);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_AND '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ConcatTerm
    : PARSEOP_CONCATENATE '('       {$<n>$ = TrCreateLeafNode (PARSEOP_CONCATENATE);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_CONCATENATE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ConcatResTerm
    : PARSEOP_CONCATENATERESTEMPLATE '('    {$<n>$ = TrCreateLeafNode (PARSEOP_CONCATENATERESTEMPLATE);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_CONCATENATERESTEMPLATE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CondRefOfTerm
    : PARSEOP_CONDREFOF '('         {$<n>$ = TrCreateLeafNode (PARSEOP_CONDREFOF);}
        SuperName
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_CONDREFOF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

CopyObjectTerm
    : PARSEOP_COPYOBJECT '('        {$<n>$ = TrCreateLeafNode (PARSEOP_COPYOBJECT);}
        TermArg
        ',' SimpleTarget
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,TrSetNodeFlags ($6, NODE_IS_TARGET));}
    | PARSEOP_COPYOBJECT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DecTerm
    : PARSEOP_DECREMENT '('         {$<n>$ = TrCreateLeafNode (PARSEOP_DECREMENT);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_DECREMENT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DerefOfTerm
    : PARSEOP_DEREFOF '('           {$<n>$ = TrCreateLeafNode (PARSEOP_DEREFOF);}
        TermArg
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_DEREFOF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DivideTerm
    : PARSEOP_DIVIDE '('            {$<n>$ = TrCreateLeafNode (PARSEOP_DIVIDE);}
        TermArg
        TermArgItem
        Target
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,4,$4,$5,$6,$7);}
    | PARSEOP_DIVIDE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FindSetLeftBitTerm
    : PARSEOP_FINDSETLEFTBIT '('    {$<n>$ = TrCreateLeafNode (PARSEOP_FINDSETLEFTBIT);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_FINDSETLEFTBIT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FindSetRightBitTerm
    : PARSEOP_FINDSETRIGHTBIT '('   {$<n>$ = TrCreateLeafNode (PARSEOP_FINDSETRIGHTBIT);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_FINDSETRIGHTBIT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FromBCDTerm
    : PARSEOP_FROMBCD '('           {$<n>$ = TrCreateLeafNode (PARSEOP_FROMBCD);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_FROMBCD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IncTerm
    : PARSEOP_INCREMENT '('         {$<n>$ = TrCreateLeafNode (PARSEOP_INCREMENT);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_INCREMENT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IndexTerm
    : PARSEOP_INDEX '('             {$<n>$ = TrCreateLeafNode (PARSEOP_INDEX);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_INDEX '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LAndTerm
    : PARSEOP_LAND '('              {$<n>$ = TrCreateLeafNode (PARSEOP_LAND);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LAND '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LEqualTerm
    : PARSEOP_LEQUAL '('            {$<n>$ = TrCreateLeafNode (PARSEOP_LEQUAL);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LEQUAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LGreaterTerm
    : PARSEOP_LGREATER '('          {$<n>$ = TrCreateLeafNode (PARSEOP_LGREATER);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LGREATER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LGreaterEqualTerm
    : PARSEOP_LGREATEREQUAL '('     {$<n>$ = TrCreateLeafNode (PARSEOP_LLESS);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrCreateNode (PARSEOP_LNOT, 1, TrLinkChildren ($<n>3,2,$4,$5));}
    | PARSEOP_LGREATEREQUAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LLessTerm
    : PARSEOP_LLESS '('             {$<n>$ = TrCreateLeafNode (PARSEOP_LLESS);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LLESS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LLessEqualTerm
    : PARSEOP_LLESSEQUAL '('        {$<n>$ = TrCreateLeafNode (PARSEOP_LGREATER);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrCreateNode (PARSEOP_LNOT, 1, TrLinkChildren ($<n>3,2,$4,$5));}
    | PARSEOP_LLESSEQUAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LNotTerm
    : PARSEOP_LNOT '('              {$<n>$ = TrCreateLeafNode (PARSEOP_LNOT);}
        TermArg
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_LNOT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LNotEqualTerm
    : PARSEOP_LNOTEQUAL '('         {$<n>$ = TrCreateLeafNode (PARSEOP_LEQUAL);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrCreateNode (PARSEOP_LNOT, 1, TrLinkChildren ($<n>3,2,$4,$5));}
    | PARSEOP_LNOTEQUAL '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LoadTableTerm
    : PARSEOP_LOADTABLE '('         {$<n>$ = TrCreateLeafNode (PARSEOP_LOADTABLE);}
        TermArg
        TermArgItem
        TermArgItem
        OptionalListString
        OptionalListString
        OptionalReference
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$5,$6,$7,$8,$9);}
    | PARSEOP_LOADTABLE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

LOrTerm
    : PARSEOP_LOR '('               {$<n>$ = TrCreateLeafNode (PARSEOP_LOR);}
        TermArg
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_LOR '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

MatchTerm
    : PARSEOP_MATCH '('             {$<n>$ = TrCreateLeafNode (PARSEOP_MATCH);}
        TermArg
        ',' MatchOpKeyword
        TermArgItem
        ',' MatchOpKeyword
        TermArgItem
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$6,$7,$9,$10,$11);}
    | PARSEOP_MATCH '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

MidTerm
    : PARSEOP_MID '('               {$<n>$ = TrCreateLeafNode (PARSEOP_MID);}
        TermArg
        TermArgItem
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,4,$4,$5,$6,$7);}
    | PARSEOP_MID '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ModTerm
    : PARSEOP_MOD '('               {$<n>$ = TrCreateLeafNode (PARSEOP_MOD);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_MOD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

MultiplyTerm
    : PARSEOP_MULTIPLY '('          {$<n>$ = TrCreateLeafNode (PARSEOP_MULTIPLY);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_MULTIPLY '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

NAndTerm
    : PARSEOP_NAND '('              {$<n>$ = TrCreateLeafNode (PARSEOP_NAND);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_NAND '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

NOrTerm
    : PARSEOP_NOR '('               {$<n>$ = TrCreateLeafNode (PARSEOP_NOR);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_NOR '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

NotTerm
    : PARSEOP_NOT '('               {$<n>$ = TrCreateLeafNode (PARSEOP_NOT);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_NOT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ObjectTypeTerm
    : PARSEOP_OBJECTTYPE '('        {$<n>$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE);}
        ObjectTypeName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_OBJECTTYPE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

OrTerm
    : PARSEOP_OR '('                {$<n>$ = TrCreateLeafNode (PARSEOP_OR);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_OR '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

/*
 * In RefOf, the node isn't really a target, but we can't keep track of it after
 * we've taken a pointer to it. (hard to tell if a local becomes initialized this way.)
 */
RefOfTerm
    : PARSEOP_REFOF '('             {$<n>$ = TrCreateLeafNode (PARSEOP_REFOF);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,TrSetNodeFlags ($4, NODE_IS_TARGET));}
    | PARSEOP_REFOF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ShiftLeftTerm
    : PARSEOP_SHIFTLEFT '('         {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTLEFT);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_SHIFTLEFT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ShiftRightTerm
    : PARSEOP_SHIFTRIGHT '('        {$<n>$ = TrCreateLeafNode (PARSEOP_SHIFTRIGHT);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_SHIFTRIGHT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SizeOfTerm
    : PARSEOP_SIZEOF '('            {$<n>$ = TrCreateLeafNode (PARSEOP_SIZEOF);}
        SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_SIZEOF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

StoreTerm
    : PARSEOP_STORE '('             {$<n>$ = TrCreateLeafNode (PARSEOP_STORE);}
        TermArg
        ',' SuperName
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,TrSetNodeFlags ($6, NODE_IS_TARGET));}
    | PARSEOP_STORE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SubtractTerm
    : PARSEOP_SUBTRACT '('          {$<n>$ = TrCreateLeafNode (PARSEOP_SUBTRACT);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_SUBTRACT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

TimerTerm
    : PARSEOP_TIMER '('             {$<n>$ = TrCreateLeafNode (PARSEOP_TIMER);}
        ')'                         {$$ = TrLinkChildren ($<n>3,0);}
    | PARSEOP_TIMER                 {$$ = TrLinkChildren (TrCreateLeafNode (PARSEOP_TIMER),0);}
    | PARSEOP_TIMER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToBCDTerm
    : PARSEOP_TOBCD '('             {$<n>$ = TrCreateLeafNode (PARSEOP_TOBCD);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_TOBCD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToBufferTerm
    : PARSEOP_TOBUFFER '('          {$<n>$ = TrCreateLeafNode (PARSEOP_TOBUFFER);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_TOBUFFER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToDecimalStringTerm
    : PARSEOP_TODECIMALSTRING '('   {$<n>$ = TrCreateLeafNode (PARSEOP_TODECIMALSTRING);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_TODECIMALSTRING '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToHexStringTerm
    : PARSEOP_TOHEXSTRING '('       {$<n>$ = TrCreateLeafNode (PARSEOP_TOHEXSTRING);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_TOHEXSTRING '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToIntegerTerm
    : PARSEOP_TOINTEGER '('         {$<n>$ = TrCreateLeafNode (PARSEOP_TOINTEGER);}
        TermArg
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_TOINTEGER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

PldKeyword
    : PARSEOP_PLD_REVISION          {$$ = TrCreateLeafNode (PARSEOP_PLD_REVISION);}
    | PARSEOP_PLD_IGNORECOLOR       {$$ = TrCreateLeafNode (PARSEOP_PLD_IGNORECOLOR);}
    | PARSEOP_PLD_RED               {$$ = TrCreateLeafNode (PARSEOP_PLD_RED);}
    | PARSEOP_PLD_GREEN             {$$ = TrCreateLeafNode (PARSEOP_PLD_GREEN);}
    | PARSEOP_PLD_BLUE              {$$ = TrCreateLeafNode (PARSEOP_PLD_BLUE);}
    | PARSEOP_PLD_WIDTH             {$$ = TrCreateLeafNode (PARSEOP_PLD_WIDTH);}
    | PARSEOP_PLD_HEIGHT            {$$ = TrCreateLeafNode (PARSEOP_PLD_HEIGHT);}
    | PARSEOP_PLD_USERVISIBLE       {$$ = TrCreateLeafNode (PARSEOP_PLD_USERVISIBLE);}
    | PARSEOP_PLD_DOCK              {$$ = TrCreateLeafNode (PARSEOP_PLD_DOCK);}
    | PARSEOP_PLD_LID               {$$ = TrCreateLeafNode (PARSEOP_PLD_LID);}
    | PARSEOP_PLD_PANEL             {$$ = TrCreateLeafNode (PARSEOP_PLD_PANEL);}
    | PARSEOP_PLD_VERTICALPOSITION  {$$ = TrCreateLeafNode (PARSEOP_PLD_VERTICALPOSITION);}
    | PARSEOP_PLD_HORIZONTALPOSITION {$$ = TrCreateLeafNode (PARSEOP_PLD_HORIZONTALPOSITION);}
    | PARSEOP_PLD_SHAPE             {$$ = TrCreateLeafNode (PARSEOP_PLD_SHAPE);}
    | PARSEOP_PLD_GROUPORIENTATION  {$$ = TrCreateLeafNode (PARSEOP_PLD_GROUPORIENTATION);}
    | PARSEOP_PLD_GROUPTOKEN        {$$ = TrCreateLeafNode (PARSEOP_PLD_GROUPTOKEN);}
    | PARSEOP_PLD_GROUPPOSITION     {$$ = TrCreateLeafNode (PARSEOP_PLD_GROUPPOSITION);}
    | PARSEOP_PLD_BAY               {$$ = TrCreateLeafNode (PARSEOP_PLD_BAY);}
    | PARSEOP_PLD_EJECTABLE         {$$ = TrCreateLeafNode (PARSEOP_PLD_EJECTABLE);}
    | PARSEOP_PLD_EJECTREQUIRED     {$$ = TrCreateLeafNode (PARSEOP_PLD_EJECTREQUIRED);}
    | PARSEOP_PLD_CABINETNUMBER     {$$ = TrCreateLeafNode (PARSEOP_PLD_CABINETNUMBER);}
    | PARSEOP_PLD_CARDCAGENUMBER    {$$ = TrCreateLeafNode (PARSEOP_PLD_CARDCAGENUMBER);}
    | PARSEOP_PLD_REFERENCE         {$$ = TrCreateLeafNode (PARSEOP_PLD_REFERENCE);}
    | PARSEOP_PLD_ROTATION          {$$ = TrCreateLeafNode (PARSEOP_PLD_ROTATION);}
    | PARSEOP_PLD_ORDER             {$$ = TrCreateLeafNode (PARSEOP_PLD_ORDER);}
    | PARSEOP_PLD_RESERVED          {$$ = TrCreateLeafNode (PARSEOP_PLD_RESERVED);}
    | PARSEOP_PLD_VERTICALOFFSET    {$$ = TrCreateLeafNode (PARSEOP_PLD_VERTICALOFFSET);}
    | PARSEOP_PLD_HORIZONTALOFFSET  {$$ = TrCreateLeafNode (PARSEOP_PLD_HORIZONTALOFFSET);}
    ;

PldKeywordList
    :                               {$$ = NULL;}
    | PldKeyword
        PARSEOP_EXP_EQUALS Integer  {$$ = TrLinkChildren ($1,1,$3);}
    | PldKeyword
        PARSEOP_EXP_EQUALS String   {$$ = TrLinkChildren ($1,1,$3);}
    | PldKeywordList ','            /* Allows a trailing comma at list end */
    | PldKeywordList ','
        PldKeyword
        PARSEOP_EXP_EQUALS Integer  {$$ = TrLinkPeerNode ($1,TrLinkChildren ($3,1,$5));}
    | PldKeywordList ','
        PldKeyword
        PARSEOP_EXP_EQUALS String   {$$ = TrLinkPeerNode ($1,TrLinkChildren ($3,1,$5));}
    ;

ToPLDTerm
    : PARSEOP_TOPLD '('             {$<n>$ = TrCreateLeafNode (PARSEOP_TOPLD);}
        PldKeywordList
        ')'                         {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_TOPLD '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

PrintfArgList
    :                               {$$ = NULL;}
    | TermArg                       {$$ = $1;}
    | PrintfArgList ','
       TermArg                      {$$ = TrLinkPeerNode ($1, $3);}
    ;

PrintfTerm
    : PARSEOP_PRINTF '('            {$<n>$ = TrCreateLeafNode (PARSEOP_PRINTF);}
        StringData
        PrintfArgList
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_PRINTF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FprintfTerm
    : PARSEOP_FPRINTF '('            {$<n>$ = TrCreateLeafNode (PARSEOP_FPRINTF);}
        TermArg ','
        StringData
        PrintfArgList
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$6,$7);}
    | PARSEOP_FPRINTF '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToStringTerm
    : PARSEOP_TOSTRING '('          {$<n>$ = TrCreateLeafNode (PARSEOP_TOSTRING);}
        TermArg
        OptionalCount
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_TOSTRING '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ToUUIDTerm
    : PARSEOP_TOUUID '('
        StringData ')'              {$$ = TrUpdateNode (PARSEOP_TOUUID, $3);}
    | PARSEOP_TOUUID '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

WaitTerm
    : PARSEOP_WAIT '('              {$<n>$ = TrCreateLeafNode (PARSEOP_WAIT);}
        SuperName
        TermArgItem
        ')'                         {$$ = TrLinkChildren ($<n>3,2,$4,$5);}
    | PARSEOP_WAIT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

XOrTerm
    : PARSEOP_XOR '('               {$<n>$ = TrCreateLeafNode (PARSEOP_XOR);}
        TermArg
        TermArgItem
        Target
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$5,$6);}
    | PARSEOP_XOR '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Keywords *************************************************************/


AccessAttribKeyword
    : PARSEOP_ACCESSATTRIB_BLOCK            {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_BLOCK);}
    | PARSEOP_ACCESSATTRIB_BLOCK_CALL       {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_BLOCK_CALL);}
    | PARSEOP_ACCESSATTRIB_BYTE             {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_BYTE);}
    | PARSEOP_ACCESSATTRIB_QUICK            {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_QUICK );}
    | PARSEOP_ACCESSATTRIB_SND_RCV          {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_SND_RCV);}
    | PARSEOP_ACCESSATTRIB_WORD             {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_WORD);}
    | PARSEOP_ACCESSATTRIB_WORD_CALL        {$$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_WORD_CALL);}
    | PARSEOP_ACCESSATTRIB_MULTIBYTE '('    {$<n>$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_MULTIBYTE);}
        ByteConst
        ')'                                 {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_ACCESSATTRIB_RAW_BYTES '('    {$<n>$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_RAW_BYTES);}
        ByteConst
        ')'                                 {$$ = TrLinkChildren ($<n>3,1,$4);}
    | PARSEOP_ACCESSATTRIB_RAW_PROCESS '('  {$<n>$ = TrCreateLeafNode (PARSEOP_ACCESSATTRIB_RAW_PROCESS);}
        ByteConst
        ')'                                 {$$ = TrLinkChildren ($<n>3,1,$4);}
    ;

AccessTypeKeyword
    : PARSEOP_ACCESSTYPE_ANY                {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_ANY);}
    | PARSEOP_ACCESSTYPE_BYTE               {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_BYTE);}
    | PARSEOP_ACCESSTYPE_WORD               {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_WORD);}
    | PARSEOP_ACCESSTYPE_DWORD              {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_DWORD);}
    | PARSEOP_ACCESSTYPE_QWORD              {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_QWORD);}
    | PARSEOP_ACCESSTYPE_BUF                {$$ = TrCreateLeafNode (PARSEOP_ACCESSTYPE_BUF);}
    ;

AddressingModeKeyword
    : PARSEOP_ADDRESSINGMODE_7BIT           {$$ = TrCreateLeafNode (PARSEOP_ADDRESSINGMODE_7BIT);}
    | PARSEOP_ADDRESSINGMODE_10BIT          {$$ = TrCreateLeafNode (PARSEOP_ADDRESSINGMODE_10BIT);}
    ;

AddressKeyword
    : PARSEOP_ADDRESSTYPE_MEMORY            {$$ = TrCreateLeafNode (PARSEOP_ADDRESSTYPE_MEMORY);}
    | PARSEOP_ADDRESSTYPE_RESERVED          {$$ = TrCreateLeafNode (PARSEOP_ADDRESSTYPE_RESERVED);}
    | PARSEOP_ADDRESSTYPE_NVS               {$$ = TrCreateLeafNode (PARSEOP_ADDRESSTYPE_NVS);}
    | PARSEOP_ADDRESSTYPE_ACPI              {$$ = TrCreateLeafNode (PARSEOP_ADDRESSTYPE_ACPI);}
    ;

AddressSpaceKeyword
    : ByteConst                             {$$ = UtCheckIntegerRange ($1, 0x0A, 0xFF);}
    | RegionSpaceKeyword                    {}
    ;

BitsPerByteKeyword
    : PARSEOP_BITSPERBYTE_FIVE              {$$ = TrCreateLeafNode (PARSEOP_BITSPERBYTE_FIVE);}
    | PARSEOP_BITSPERBYTE_SIX               {$$ = TrCreateLeafNode (PARSEOP_BITSPERBYTE_SIX);}
    | PARSEOP_BITSPERBYTE_SEVEN             {$$ = TrCreateLeafNode (PARSEOP_BITSPERBYTE_SEVEN);}
    | PARSEOP_BITSPERBYTE_EIGHT             {$$ = TrCreateLeafNode (PARSEOP_BITSPERBYTE_EIGHT);}
    | PARSEOP_BITSPERBYTE_NINE              {$$ = TrCreateLeafNode (PARSEOP_BITSPERBYTE_NINE);}
    ;

ClockPhaseKeyword
    : PARSEOP_CLOCKPHASE_FIRST              {$$ = TrCreateLeafNode (PARSEOP_CLOCKPHASE_FIRST);}
    | PARSEOP_CLOCKPHASE_SECOND             {$$ = TrCreateLeafNode (PARSEOP_CLOCKPHASE_SECOND);}
    ;

ClockPolarityKeyword
    : PARSEOP_CLOCKPOLARITY_LOW             {$$ = TrCreateLeafNode (PARSEOP_CLOCKPOLARITY_LOW);}
    | PARSEOP_CLOCKPOLARITY_HIGH            {$$ = TrCreateLeafNode (PARSEOP_CLOCKPOLARITY_HIGH);}
    ;

DecodeKeyword
    : PARSEOP_DECODETYPE_POS                {$$ = TrCreateLeafNode (PARSEOP_DECODETYPE_POS);}
    | PARSEOP_DECODETYPE_SUB                {$$ = TrCreateLeafNode (PARSEOP_DECODETYPE_SUB);}
    ;

DevicePolarityKeyword
    : PARSEOP_DEVICEPOLARITY_LOW            {$$ = TrCreateLeafNode (PARSEOP_DEVICEPOLARITY_LOW);}
    | PARSEOP_DEVICEPOLARITY_HIGH           {$$ = TrCreateLeafNode (PARSEOP_DEVICEPOLARITY_HIGH);}
    ;

DMATypeKeyword
    : PARSEOP_DMATYPE_A                     {$$ = TrCreateLeafNode (PARSEOP_DMATYPE_A);}
    | PARSEOP_DMATYPE_COMPATIBILITY         {$$ = TrCreateLeafNode (PARSEOP_DMATYPE_COMPATIBILITY);}
    | PARSEOP_DMATYPE_B                     {$$ = TrCreateLeafNode (PARSEOP_DMATYPE_B);}
    | PARSEOP_DMATYPE_F                     {$$ = TrCreateLeafNode (PARSEOP_DMATYPE_F);}
    ;

EndianKeyword
    : PARSEOP_ENDIAN_LITTLE                 {$$ = TrCreateLeafNode (PARSEOP_ENDIAN_LITTLE);}
    | PARSEOP_ENDIAN_BIG                    {$$ = TrCreateLeafNode (PARSEOP_ENDIAN_BIG);}
    ;

FlowControlKeyword
    : PARSEOP_FLOWCONTROL_HW                {$$ = TrCreateLeafNode (PARSEOP_FLOWCONTROL_HW);}
    | PARSEOP_FLOWCONTROL_NONE              {$$ = TrCreateLeafNode (PARSEOP_FLOWCONTROL_NONE);}
    | PARSEOP_FLOWCONTROL_SW                {$$ = TrCreateLeafNode (PARSEOP_FLOWCONTROL_SW);}
    ;

InterruptLevel
    : PARSEOP_INTLEVEL_ACTIVEBOTH           {$$ = TrCreateLeafNode (PARSEOP_INTLEVEL_ACTIVEBOTH);}
    | PARSEOP_INTLEVEL_ACTIVEHIGH           {$$ = TrCreateLeafNode (PARSEOP_INTLEVEL_ACTIVEHIGH);}
    | PARSEOP_INTLEVEL_ACTIVELOW            {$$ = TrCreateLeafNode (PARSEOP_INTLEVEL_ACTIVELOW);}
    ;

InterruptTypeKeyword
    : PARSEOP_INTTYPE_EDGE                  {$$ = TrCreateLeafNode (PARSEOP_INTTYPE_EDGE);}
    | PARSEOP_INTTYPE_LEVEL                 {$$ = TrCreateLeafNode (PARSEOP_INTTYPE_LEVEL);}
    ;

IODecodeKeyword
    : PARSEOP_IODECODETYPE_16               {$$ = TrCreateLeafNode (PARSEOP_IODECODETYPE_16);}
    | PARSEOP_IODECODETYPE_10               {$$ = TrCreateLeafNode (PARSEOP_IODECODETYPE_10);}
    ;

IoRestrictionKeyword
    : PARSEOP_IORESTRICT_IN                 {$$ = TrCreateLeafNode (PARSEOP_IORESTRICT_IN);}
    | PARSEOP_IORESTRICT_OUT                {$$ = TrCreateLeafNode (PARSEOP_IORESTRICT_OUT);}
    | PARSEOP_IORESTRICT_NONE               {$$ = TrCreateLeafNode (PARSEOP_IORESTRICT_NONE);}
    | PARSEOP_IORESTRICT_PRESERVE           {$$ = TrCreateLeafNode (PARSEOP_IORESTRICT_PRESERVE);}
    ;

LockRuleKeyword
    : PARSEOP_LOCKRULE_LOCK                 {$$ = TrCreateLeafNode (PARSEOP_LOCKRULE_LOCK);}
    | PARSEOP_LOCKRULE_NOLOCK               {$$ = TrCreateLeafNode (PARSEOP_LOCKRULE_NOLOCK);}
    ;

MatchOpKeyword
    : PARSEOP_MATCHTYPE_MTR                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MTR);}
    | PARSEOP_MATCHTYPE_MEQ                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MEQ);}
    | PARSEOP_MATCHTYPE_MLE                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MLE);}
    | PARSEOP_MATCHTYPE_MLT                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MLT);}
    | PARSEOP_MATCHTYPE_MGE                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MGE);}
    | PARSEOP_MATCHTYPE_MGT                 {$$ = TrCreateLeafNode (PARSEOP_MATCHTYPE_MGT);}
    ;

MaxKeyword
    : PARSEOP_MAXTYPE_FIXED                 {$$ = TrCreateLeafNode (PARSEOP_MAXTYPE_FIXED);}
    | PARSEOP_MAXTYPE_NOTFIXED              {$$ = TrCreateLeafNode (PARSEOP_MAXTYPE_NOTFIXED);}
    ;

MemTypeKeyword
    : PARSEOP_MEMTYPE_CACHEABLE             {$$ = TrCreateLeafNode (PARSEOP_MEMTYPE_CACHEABLE);}
    | PARSEOP_MEMTYPE_WRITECOMBINING        {$$ = TrCreateLeafNode (PARSEOP_MEMTYPE_WRITECOMBINING);}
    | PARSEOP_MEMTYPE_PREFETCHABLE          {$$ = TrCreateLeafNode (PARSEOP_MEMTYPE_PREFETCHABLE);}
    | PARSEOP_MEMTYPE_NONCACHEABLE          {$$ = TrCreateLeafNode (PARSEOP_MEMTYPE_NONCACHEABLE);}
    ;

MinKeyword
    : PARSEOP_MINTYPE_FIXED                 {$$ = TrCreateLeafNode (PARSEOP_MINTYPE_FIXED);}
    | PARSEOP_MINTYPE_NOTFIXED              {$$ = TrCreateLeafNode (PARSEOP_MINTYPE_NOTFIXED);}
    ;

ObjectTypeKeyword
    : PARSEOP_OBJECTTYPE_UNK                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_UNK);}
    | PARSEOP_OBJECTTYPE_INT                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_INT);}
    | PARSEOP_OBJECTTYPE_STR                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_STR);}
    | PARSEOP_OBJECTTYPE_BUF                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_BUF);}
    | PARSEOP_OBJECTTYPE_PKG                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_PKG);}
    | PARSEOP_OBJECTTYPE_FLD                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_FLD);}
    | PARSEOP_OBJECTTYPE_DEV                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_DEV);}
    | PARSEOP_OBJECTTYPE_EVT                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_EVT);}
    | PARSEOP_OBJECTTYPE_MTH                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_MTH);}
    | PARSEOP_OBJECTTYPE_MTX                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_MTX);}
    | PARSEOP_OBJECTTYPE_OPR                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_OPR);}
    | PARSEOP_OBJECTTYPE_POW                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_POW);}
    | PARSEOP_OBJECTTYPE_PRO                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_PRO);}
    | PARSEOP_OBJECTTYPE_THZ                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_THZ);}
    | PARSEOP_OBJECTTYPE_BFF                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_BFF);}
    | PARSEOP_OBJECTTYPE_DDB                {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_DDB);}
    ;

ParityTypeKeyword
    : PARSEOP_PARITYTYPE_SPACE              {$$ = TrCreateLeafNode (PARSEOP_PARITYTYPE_SPACE);}
    | PARSEOP_PARITYTYPE_MARK               {$$ = TrCreateLeafNode (PARSEOP_PARITYTYPE_MARK);}
    | PARSEOP_PARITYTYPE_ODD                {$$ = TrCreateLeafNode (PARSEOP_PARITYTYPE_ODD);}
    | PARSEOP_PARITYTYPE_EVEN               {$$ = TrCreateLeafNode (PARSEOP_PARITYTYPE_EVEN);}
    | PARSEOP_PARITYTYPE_NONE               {$$ = TrCreateLeafNode (PARSEOP_PARITYTYPE_NONE);}
    ;

PinConfigByte
    : PinConfigKeyword                      {$$ = $1;}
    | ByteConstExpr                         {$$ = UtCheckIntegerRange ($1, 0x80, 0xFF);}
    ;

PinConfigKeyword
    : PARSEOP_PIN_NOPULL                    {$$ = TrCreateLeafNode (PARSEOP_PIN_NOPULL);}
    | PARSEOP_PIN_PULLDOWN                  {$$ = TrCreateLeafNode (PARSEOP_PIN_PULLDOWN);}
    | PARSEOP_PIN_PULLUP                    {$$ = TrCreateLeafNode (PARSEOP_PIN_PULLUP);}
    | PARSEOP_PIN_PULLDEFAULT               {$$ = TrCreateLeafNode (PARSEOP_PIN_PULLDEFAULT);}
    ;

RangeTypeKeyword
    : PARSEOP_RANGETYPE_ISAONLY             {$$ = TrCreateLeafNode (PARSEOP_RANGETYPE_ISAONLY);}
    | PARSEOP_RANGETYPE_NONISAONLY          {$$ = TrCreateLeafNode (PARSEOP_RANGETYPE_NONISAONLY);}
    | PARSEOP_RANGETYPE_ENTIRE              {$$ = TrCreateLeafNode (PARSEOP_RANGETYPE_ENTIRE);}
    ;

RegionSpaceKeyword
    : PARSEOP_REGIONSPACE_IO                {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_IO);}
    | PARSEOP_REGIONSPACE_MEM               {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_MEM);}
    | PARSEOP_REGIONSPACE_PCI               {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_PCI);}
    | PARSEOP_REGIONSPACE_EC                {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_EC);}
    | PARSEOP_REGIONSPACE_SMBUS             {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_SMBUS);}
    | PARSEOP_REGIONSPACE_CMOS              {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_CMOS);}
    | PARSEOP_REGIONSPACE_PCIBAR            {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_PCIBAR);}
    | PARSEOP_REGIONSPACE_IPMI              {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_IPMI);}
    | PARSEOP_REGIONSPACE_GPIO              {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_GPIO);}
    | PARSEOP_REGIONSPACE_GSBUS             {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_GSBUS);}
    | PARSEOP_REGIONSPACE_PCC               {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_PCC);}
    | PARSEOP_REGIONSPACE_FFIXEDHW          {$$ = TrCreateLeafNode (PARSEOP_REGIONSPACE_FFIXEDHW);}
    ;

ResourceTypeKeyword
    : PARSEOP_RESOURCETYPE_CONSUMER         {$$ = TrCreateLeafNode (PARSEOP_RESOURCETYPE_CONSUMER);}
    | PARSEOP_RESOURCETYPE_PRODUCER         {$$ = TrCreateLeafNode (PARSEOP_RESOURCETYPE_PRODUCER);}
    ;

SerializeRuleKeyword
    : PARSEOP_SERIALIZERULE_SERIAL          {$$ = TrCreateLeafNode (PARSEOP_SERIALIZERULE_SERIAL);}
    | PARSEOP_SERIALIZERULE_NOTSERIAL       {$$ = TrCreateLeafNode (PARSEOP_SERIALIZERULE_NOTSERIAL);}
    ;

ShareTypeKeyword
    : PARSEOP_SHARETYPE_SHARED              {$$ = TrCreateLeafNode (PARSEOP_SHARETYPE_SHARED);}
    | PARSEOP_SHARETYPE_EXCLUSIVE           {$$ = TrCreateLeafNode (PARSEOP_SHARETYPE_EXCLUSIVE);}
    | PARSEOP_SHARETYPE_SHAREDWAKE          {$$ = TrCreateLeafNode (PARSEOP_SHARETYPE_SHAREDWAKE);}
    | PARSEOP_SHARETYPE_EXCLUSIVEWAKE       {$$ = TrCreateLeafNode (PARSEOP_SHARETYPE_EXCLUSIVEWAKE);}
   ;

SlaveModeKeyword
    : PARSEOP_SLAVEMODE_CONTROLLERINIT      {$$ = TrCreateLeafNode (PARSEOP_SLAVEMODE_CONTROLLERINIT);}
    | PARSEOP_SLAVEMODE_DEVICEINIT          {$$ = TrCreateLeafNode (PARSEOP_SLAVEMODE_DEVICEINIT);}
    ;

StopBitsKeyword
    : PARSEOP_STOPBITS_TWO                  {$$ = TrCreateLeafNode (PARSEOP_STOPBITS_TWO);}
    | PARSEOP_STOPBITS_ONEPLUSHALF          {$$ = TrCreateLeafNode (PARSEOP_STOPBITS_ONEPLUSHALF);}
    | PARSEOP_STOPBITS_ONE                  {$$ = TrCreateLeafNode (PARSEOP_STOPBITS_ONE);}
    | PARSEOP_STOPBITS_ZERO                 {$$ = TrCreateLeafNode (PARSEOP_STOPBITS_ZERO);}
    ;

TranslationKeyword
    : PARSEOP_TRANSLATIONTYPE_SPARSE        {$$ = TrCreateLeafNode (PARSEOP_TRANSLATIONTYPE_SPARSE);}
    | PARSEOP_TRANSLATIONTYPE_DENSE         {$$ = TrCreateLeafNode (PARSEOP_TRANSLATIONTYPE_DENSE);}
    ;

TypeKeyword
    : PARSEOP_TYPE_TRANSLATION              {$$ = TrCreateLeafNode (PARSEOP_TYPE_TRANSLATION);}
    | PARSEOP_TYPE_STATIC                   {$$ = TrCreateLeafNode (PARSEOP_TYPE_STATIC);}
    ;

UpdateRuleKeyword
    : PARSEOP_UPDATERULE_PRESERVE           {$$ = TrCreateLeafNode (PARSEOP_UPDATERULE_PRESERVE);}
    | PARSEOP_UPDATERULE_ONES               {$$ = TrCreateLeafNode (PARSEOP_UPDATERULE_ONES);}
    | PARSEOP_UPDATERULE_ZEROS              {$$ = TrCreateLeafNode (PARSEOP_UPDATERULE_ZEROS);}
    ;

WireModeKeyword
    : PARSEOP_WIREMODE_FOUR                 {$$ = TrCreateLeafNode (PARSEOP_WIREMODE_FOUR);}
    | PARSEOP_WIREMODE_THREE                {$$ = TrCreateLeafNode (PARSEOP_WIREMODE_THREE);}
    ;

XferSizeKeyword
    : PARSEOP_XFERSIZE_8                    {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_8,   0);}
    | PARSEOP_XFERSIZE_16                   {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_16,  1);}
    | PARSEOP_XFERSIZE_32                   {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_32,  2);}
    | PARSEOP_XFERSIZE_64                   {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_64,  3);}
    | PARSEOP_XFERSIZE_128                  {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_128, 4);}
    | PARSEOP_XFERSIZE_256                  {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_256, 5);}
    ;

XferTypeKeyword
    : PARSEOP_XFERTYPE_8                    {$$ = TrCreateLeafNode (PARSEOP_XFERTYPE_8);}
    | PARSEOP_XFERTYPE_8_16                 {$$ = TrCreateLeafNode (PARSEOP_XFERTYPE_8_16);}
    | PARSEOP_XFERTYPE_16                   {$$ = TrCreateLeafNode (PARSEOP_XFERTYPE_16);}
    ;


/******* Miscellaneous Types **************************************************/


SuperName
    : NameString                    {}
    | ArgTerm                       {}
    | LocalTerm                     {}
    | DebugTerm                     {}
    | Type6Opcode                   {}

/* For ObjectType: SuperName except for MethodInvocationTerm */

ObjectTypeName
    : NameString                    {}
    | ArgTerm                       {}
    | LocalTerm                     {}
    | DebugTerm                     {}
    | RefOfTerm                     {}
    | DerefOfTerm                   {}
    | IndexTerm                     {}

/*    | MethodInvocationTerm          {} */  /* Caused reduce/reduce with Type6Opcode->MethodInvocationTerm */
    ;

ArgTerm
    : PARSEOP_ARG0                  {$$ = TrCreateLeafNode (PARSEOP_ARG0);}
    | PARSEOP_ARG1                  {$$ = TrCreateLeafNode (PARSEOP_ARG1);}
    | PARSEOP_ARG2                  {$$ = TrCreateLeafNode (PARSEOP_ARG2);}
    | PARSEOP_ARG3                  {$$ = TrCreateLeafNode (PARSEOP_ARG3);}
    | PARSEOP_ARG4                  {$$ = TrCreateLeafNode (PARSEOP_ARG4);}
    | PARSEOP_ARG5                  {$$ = TrCreateLeafNode (PARSEOP_ARG5);}
    | PARSEOP_ARG6                  {$$ = TrCreateLeafNode (PARSEOP_ARG6);}
    ;

LocalTerm
    : PARSEOP_LOCAL0                {$$ = TrCreateLeafNode (PARSEOP_LOCAL0);}
    | PARSEOP_LOCAL1                {$$ = TrCreateLeafNode (PARSEOP_LOCAL1);}
    | PARSEOP_LOCAL2                {$$ = TrCreateLeafNode (PARSEOP_LOCAL2);}
    | PARSEOP_LOCAL3                {$$ = TrCreateLeafNode (PARSEOP_LOCAL3);}
    | PARSEOP_LOCAL4                {$$ = TrCreateLeafNode (PARSEOP_LOCAL4);}
    | PARSEOP_LOCAL5                {$$ = TrCreateLeafNode (PARSEOP_LOCAL5);}
    | PARSEOP_LOCAL6                {$$ = TrCreateLeafNode (PARSEOP_LOCAL6);}
    | PARSEOP_LOCAL7                {$$ = TrCreateLeafNode (PARSEOP_LOCAL7);}
    ;

DebugTerm
    : PARSEOP_DEBUG                 {$$ = TrCreateLeafNode (PARSEOP_DEBUG);}
    ;


ByteConst
    : Integer                       {$$ = TrUpdateNode (PARSEOP_BYTECONST, $1);}
    ;

WordConst
    : Integer                       {$$ = TrUpdateNode (PARSEOP_WORDCONST, $1);}
    ;

DWordConst
    : Integer                       {$$ = TrUpdateNode (PARSEOP_DWORDCONST, $1);}
    ;

QWordConst
    : Integer                       {$$ = TrUpdateNode (PARSEOP_QWORDCONST, $1);}
    ;

Integer
    : PARSEOP_INTEGER               {$$ = TrCreateValuedLeafNode (PARSEOP_INTEGER, AslCompilerlval.i);}
    ;

String
    : PARSEOP_STRING_LITERAL        {$$ = TrCreateValuedLeafNode (PARSEOP_STRING_LITERAL, (ACPI_NATIVE_INT) AslCompilerlval.s);}
    ;

ConstTerm
    : ConstExprTerm                 {}
    | PARSEOP_REVISION              {$$ = TrCreateLeafNode (PARSEOP_REVISION);}
    ;

ConstExprTerm
    : PARSEOP_ZERO                  {$$ = TrCreateValuedLeafNode (PARSEOP_ZERO, 0);}
    | PARSEOP_ONE                   {$$ = TrCreateValuedLeafNode (PARSEOP_ONE, 1);}
    | PARSEOP_ONES                  {$$ = TrCreateValuedLeafNode (PARSEOP_ONES, ACPI_UINT64_MAX);}
    | PARSEOP___DATE__              {$$ = TrCreateConstantLeafNode (PARSEOP___DATE__);}
    | PARSEOP___FILE__              {$$ = TrCreateConstantLeafNode (PARSEOP___FILE__);}
    | PARSEOP___LINE__              {$$ = TrCreateConstantLeafNode (PARSEOP___LINE__);}
    | PARSEOP___PATH__              {$$ = TrCreateConstantLeafNode (PARSEOP___PATH__);}
    ;

/*
 * The NODE_COMPILE_TIME_CONST flag in the following constant expressions
 * enables compile-time constant folding to reduce the Type3Opcodes/Type2IntegerOpcodes
 * to simple integers. It is an error if these types of expressions cannot be
 * reduced, since the AML grammar for ****ConstExpr requires a simple constant.
 * Note: The required byte length of the constant is passed through to the
 * constant folding code in the node AmlLength field.
 */
ByteConstExpr
    : Type3Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 1);}
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 1);}
    | ConstExprTerm                 {$$ = TrUpdateNode (PARSEOP_BYTECONST, $1);}
    | ByteConst                     {}
    ;

WordConstExpr
    : Type3Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 2);}
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 2);}
    | ConstExprTerm                 {$$ = TrUpdateNode (PARSEOP_WORDCONST, $1);}
    | WordConst                     {}
    ;

DWordConstExpr
    : Type3Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 4);}
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 4);}
    | ConstExprTerm                 {$$ = TrUpdateNode (PARSEOP_DWORDCONST, $1);}
    | DWordConst                    {}
    ;

QWordConstExpr
    : Type3Opcode                   {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 8);}
    | Type2IntegerOpcode            {$$ = TrSetNodeFlags ($1, NODE_COMPILE_TIME_CONST); TrSetNodeAmlLength ($1, 8);}
    | ConstExprTerm                 {$$ = TrUpdateNode (PARSEOP_QWORDCONST, $1);}
    | QWordConst                    {}
    ;

/* OptionalCount must appear before ByteList or an incorrect reduction will result */

OptionalCount
    :                               {$$ = TrCreateLeafNode (PARSEOP_ONES);}       /* Placeholder is a OnesOp object */
    | ','                           {$$ = TrCreateLeafNode (PARSEOP_ONES);}       /* Placeholder is a OnesOp object */
    | ',' TermArg                   {$$ = $2;}
    ;

BufferTerm
    : PARSEOP_BUFFER '('            {$<n>$ = TrCreateLeafNode (PARSEOP_BUFFER);}
        OptionalTermArg
        ')' '{'
            BufferTermData '}'      {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_BUFFER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

BufferTermData
    : ByteList                      {}
    | StringData                    {}
    ;

ByteList
    :                               {$$ = NULL;}
    | ByteConstExpr
    | ByteList ','                  /* Allows a trailing comma at list end */
    | ByteList ','
        ByteConstExpr               {$$ = TrLinkPeerNode ($1,$3);}
    ;

DataBufferTerm
    : PARSEOP_DATABUFFER  '('       {$<n>$ = TrCreateLeafNode (PARSEOP_DATABUFFER);}
        OptionalWordConst
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_DATABUFFER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DWordList
    :                               {$$ = NULL;}
    | DWordConstExpr
    | DWordList ','                 /* Allows a trailing comma at list end */
    | DWordList ','
        DWordConstExpr              {$$ = TrLinkPeerNode ($1,$3);}
    ;

PackageTerm
    : PARSEOP_PACKAGE '('           {$<n>$ = TrCreateLeafNode (PARSEOP_VAR_PACKAGE);}
        VarPackageLengthTerm
        ')' '{'
            PackageList '}'         {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_PACKAGE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

PackageList
    :                               {$$ = NULL;}
    | PackageElement
    | PackageList ','               /* Allows a trailing comma at list end */
    | PackageList ','
        PackageElement              {$$ = TrLinkPeerNode ($1,$3);}
    ;

PackageElement
    : DataObject                    {}
    | NameString                    {}
    ;

VarPackageLengthTerm
    :                               {$$ = TrCreateLeafNode (PARSEOP_DEFAULT_ARG);}
    | TermArg                       {$$ = $1;}
    ;


/******* Macros ***********************************************/


EISAIDTerm
    : PARSEOP_EISAID '('
        StringData ')'              {$$ = TrUpdateNode (PARSEOP_EISAID, $3);}
    | PARSEOP_EISAID '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

UnicodeTerm
    : PARSEOP_UNICODE '('           {$<n>$ = TrCreateLeafNode (PARSEOP_UNICODE);}
        StringData
        ')'                         {$$ = TrLinkChildren ($<n>3,2,0,$4);}
    | PARSEOP_UNICODE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Resources and Memory ***********************************************/


/*
 * Note: Create two default nodes to allow conversion to a Buffer AML opcode
 * Also, insert the EndTag at the end of the template.
 */
ResourceTemplateTerm
    : PARSEOP_RESOURCETEMPLATE '(' ')'
        '{'
        ResourceMacroList '}'       {$$ = TrCreateNode (PARSEOP_RESOURCETEMPLATE,4,
                                          TrCreateLeafNode (PARSEOP_DEFAULT_ARG),
                                          TrCreateLeafNode (PARSEOP_DEFAULT_ARG),
                                          $5,
                                          TrCreateLeafNode (PARSEOP_ENDTAG));}
    ;

ResourceMacroList
    :                               {$$ = NULL;}
    | ResourceMacroList
        ResourceMacroTerm           {$$ = TrLinkPeerNode ($1,$2);}
    ;

ResourceMacroTerm
    : DMATerm                       {}
    | DWordIOTerm                   {}
    | DWordMemoryTerm               {}
    | DWordSpaceTerm                {}
    | EndDependentFnTerm            {}
    | ExtendedIOTerm                {}
    | ExtendedMemoryTerm            {}
    | ExtendedSpaceTerm             {}
    | FixedDmaTerm                  {}
    | FixedIOTerm                   {}
    | GpioIntTerm                   {}
    | GpioIoTerm                    {}
    | I2cSerialBusTerm              {}
    | InterruptTerm                 {}
    | IOTerm                        {}
    | IRQNoFlagsTerm                {}
    | IRQTerm                       {}
    | Memory24Term                  {}
    | Memory32FixedTerm             {}
    | Memory32Term                  {}
    | QWordIOTerm                   {}
    | QWordMemoryTerm               {}
    | QWordSpaceTerm                {}
    | RegisterTerm                  {}
    | SpiSerialBusTerm              {}
    | StartDependentFnNoPriTerm     {}
    | StartDependentFnTerm          {}
    | UartSerialBusTerm             {}
    | VendorLongTerm                {}
    | VendorShortTerm               {}
    | WordBusNumberTerm             {}
    | WordIOTerm                    {}
    | WordSpaceTerm                 {}
    ;

DMATerm
    : PARSEOP_DMA '('               {$<n>$ = TrCreateLeafNode (PARSEOP_DMA);}
        DMATypeKeyword
        OptionalBusMasterKeyword
        ',' XferTypeKeyword
        OptionalNameString_Last
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,5,$4,$5,$7,$8,$11);}
    | PARSEOP_DMA '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DWordIOTerm
    : PARSEOP_DWORDIO '('           {$<n>$ = TrCreateLeafNode (PARSEOP_DWORDIO);}
        OptionalResourceType_First
        OptionalMinType
        OptionalMaxType
        OptionalDecodeType
        OptionalRangeType
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString
        OptionalType
        OptionalTranslationType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,15,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$19,$20,$21,$22,$23);}
    | PARSEOP_DWORDIO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DWordMemoryTerm
    : PARSEOP_DWORDMEMORY '('       {$<n>$ = TrCreateLeafNode (PARSEOP_DWORDMEMORY);}
        OptionalResourceType_First
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        OptionalMemType
        ',' OptionalReadWriteKeyword
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString
        OptionalAddressRange
        OptionalType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,16,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$20,$21,$22,$23,$24,$25);}
    | PARSEOP_DWORDMEMORY '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

DWordSpaceTerm
    : PARSEOP_DWORDSPACE '('        {$<n>$ = TrCreateLeafNode (PARSEOP_DWORDSPACE);}
        ByteConstExpr               {UtCheckIntegerRange ($4, 0xC0, 0xFF);}
        OptionalResourceType
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        ',' ByteConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,14,$4,$6,$7,$8,$9,$11,$13,$15,$17,$19,$21,$22,$23,$24);}
    | PARSEOP_DWORDSPACE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


EndDependentFnTerm
    : PARSEOP_ENDDEPENDENTFN '('
        ')'                         {$$ = TrCreateLeafNode (PARSEOP_ENDDEPENDENTFN);}
    | PARSEOP_ENDDEPENDENTFN '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ExtendedIOTerm
    : PARSEOP_EXTENDEDIO '('        {$<n>$ = TrCreateLeafNode (PARSEOP_EXTENDEDIO);}
        OptionalResourceType_First
        OptionalMinType
        OptionalMaxType
        OptionalDecodeType
        OptionalRangeType
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalQWordConstExpr
        OptionalNameString
        OptionalType
        OptionalTranslationType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,14,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$19,$20,$21,$22);}
    | PARSEOP_EXTENDEDIO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ExtendedMemoryTerm
    : PARSEOP_EXTENDEDMEMORY '('    {$<n>$ = TrCreateLeafNode (PARSEOP_EXTENDEDMEMORY);}
        OptionalResourceType_First
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        OptionalMemType
        ',' OptionalReadWriteKeyword
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalQWordConstExpr
        OptionalNameString
        OptionalAddressRange
        OptionalType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,15,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$20,$21,$22,$23,$24);}
    | PARSEOP_EXTENDEDMEMORY '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

ExtendedSpaceTerm
    : PARSEOP_EXTENDEDSPACE '('     {$<n>$ = TrCreateLeafNode (PARSEOP_EXTENDEDSPACE);}
        ByteConstExpr               {UtCheckIntegerRange ($4, 0xC0, 0xFF);}
        OptionalResourceType
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        ',' ByteConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalQWordConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,13,$4,$6,$7,$8,$9,$11,$13,$15,$17,$19,$21,$22,$23);}
    | PARSEOP_EXTENDEDSPACE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FixedDmaTerm
    : PARSEOP_FIXEDDMA '('          {$<n>$ = TrCreateLeafNode (PARSEOP_FIXEDDMA);}
        WordConstExpr               /* 04: DMA RequestLines */
        ',' WordConstExpr           /* 06: DMA Channels */
        OptionalXferSize            /* 07: DMA TransferSize */
        OptionalNameString          /* 08: DescriptorName */
        ')'                         {$$ = TrLinkChildren ($<n>3,4,$4,$6,$7,$8);}
    | PARSEOP_FIXEDDMA '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

FixedIOTerm
    : PARSEOP_FIXEDIO '('           {$<n>$ = TrCreateLeafNode (PARSEOP_FIXEDIO);}
        WordConstExpr
        ',' ByteConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,3,$4,$6,$7);}
    | PARSEOP_FIXEDIO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

GpioIntTerm
    : PARSEOP_GPIO_INT '('          {$<n>$ = TrCreateLeafNode (PARSEOP_GPIO_INT);}
        InterruptTypeKeyword        /* 04: InterruptType */
        ',' InterruptLevel          /* 06: InterruptLevel */
        OptionalShareType           /* 07: SharedType */
        ',' PinConfigByte           /* 09: PinConfig */
        OptionalWordConstExpr       /* 10: DebounceTimeout */
        ',' StringData              /* 12: ResourceSource */
        OptionalByteConstExpr       /* 13: ResourceSourceIndex */
        OptionalResourceType        /* 14: ResourceType */
        OptionalNameString          /* 15: DescriptorName */
        OptionalBuffer_Last         /* 16: VendorData */
        ')' '{'
            DWordConstExpr '}'      {$$ = TrLinkChildren ($<n>3,11,$4,$6,$7,$9,$10,$12,$13,$14,$15,$16,$19);}
    | PARSEOP_GPIO_INT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

GpioIoTerm
    : PARSEOP_GPIO_IO '('           {$<n>$ = TrCreateLeafNode (PARSEOP_GPIO_IO);}
        OptionalShareType_First     /* 04: SharedType */
        ',' PinConfigByte           /* 06: PinConfig */
        OptionalWordConstExpr       /* 07: DebounceTimeout */
        OptionalWordConstExpr       /* 08: DriveStrength */
        OptionalIoRestriction       /* 09: IoRestriction */
        ',' StringData              /* 11: ResourceSource */
        OptionalByteConstExpr       /* 12: ResourceSourceIndex */
        OptionalResourceType        /* 13: ResourceType */
        OptionalNameString          /* 14: DescriptorName */
        OptionalBuffer_Last         /* 15: VendorData */
        ')' '{'
            DWordList '}'           {$$ = TrLinkChildren ($<n>3,11,$4,$6,$7,$8,$9,$11,$12,$13,$14,$15,$18);}
    | PARSEOP_GPIO_IO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

I2cSerialBusTerm
    : PARSEOP_I2C_SERIALBUS '('     {$<n>$ = TrCreateLeafNode (PARSEOP_I2C_SERIALBUS);}
        WordConstExpr               /* 04: SlaveAddress */
        OptionalSlaveMode           /* 05: SlaveMode */
        ',' DWordConstExpr          /* 07: ConnectionSpeed */
        OptionalAddressingMode      /* 08: AddressingMode */
        ',' StringData              /* 10: ResourceSource */
        OptionalByteConstExpr       /* 11: ResourceSourceIndex */
        OptionalResourceType        /* 12: ResourceType */
        OptionalNameString          /* 13: DescriptorName */
        OptionalBuffer_Last         /* 14: VendorData */
        ')'                         {$$ = TrLinkChildren ($<n>3,9,$4,$5,$7,$8,$10,$11,$12,$13,$14);}
    | PARSEOP_I2C_SERIALBUS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

InterruptTerm
    : PARSEOP_INTERRUPT '('         {$<n>$ = TrCreateLeafNode (PARSEOP_INTERRUPT);}
        OptionalResourceType_First
        ',' InterruptTypeKeyword
        ',' InterruptLevel
        OptionalShareType
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString_Last
        ')' '{'
            DWordList '}'           {$$ = TrLinkChildren ($<n>3,8,$4,$6,$8,$9,$10,$11,$12,$15);}
    | PARSEOP_INTERRUPT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IOTerm
    : PARSEOP_IO '('                {$<n>$ = TrCreateLeafNode (PARSEOP_IO);}
        IODecodeKeyword
        ',' WordConstExpr
        ',' WordConstExpr
        ',' ByteConstExpr
        ',' ByteConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$6,$8,$10,$12,$13);}
    | PARSEOP_IO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IRQNoFlagsTerm
    : PARSEOP_IRQNOFLAGS '('        {$<n>$ = TrCreateLeafNode (PARSEOP_IRQNOFLAGS);}
        OptionalNameString_First
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_IRQNOFLAGS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

IRQTerm
    : PARSEOP_IRQ '('               {$<n>$ = TrCreateLeafNode (PARSEOP_IRQ);}
        InterruptTypeKeyword
        ',' InterruptLevel
        OptionalShareType
        OptionalNameString_Last
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,5,$4,$6,$7,$8,$11);}
    | PARSEOP_IRQ '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

Memory24Term
    : PARSEOP_MEMORY24 '('          {$<n>$ = TrCreateLeafNode (PARSEOP_MEMORY24);}
        OptionalReadWriteKeyword
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$6,$8,$10,$12,$13);}
    | PARSEOP_MEMORY24 '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

Memory32FixedTerm
    : PARSEOP_MEMORY32FIXED '('     {$<n>$ = TrCreateLeafNode (PARSEOP_MEMORY32FIXED);}
        OptionalReadWriteKeyword
        ',' DWordConstExpr
        ',' DWordConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,4,$4,$6,$8,$9);}
    | PARSEOP_MEMORY32FIXED '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

Memory32Term
    : PARSEOP_MEMORY32 '('          {$<n>$ = TrCreateLeafNode (PARSEOP_MEMORY32);}
        OptionalReadWriteKeyword
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        ',' DWordConstExpr
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$6,$8,$10,$12,$13);}
    | PARSEOP_MEMORY32 '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

QWordIOTerm
    : PARSEOP_QWORDIO '('           {$<n>$ = TrCreateLeafNode (PARSEOP_QWORDIO);}
        OptionalResourceType_First
        OptionalMinType
        OptionalMaxType
        OptionalDecodeType
        OptionalRangeType
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString
        OptionalType
        OptionalTranslationType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,15,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$19,$20,$21,$22,$23);}
    | PARSEOP_QWORDIO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

QWordMemoryTerm
    : PARSEOP_QWORDMEMORY '('       {$<n>$ = TrCreateLeafNode (PARSEOP_QWORDMEMORY);}
        OptionalResourceType_First
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        OptionalMemType
        ',' OptionalReadWriteKeyword
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString
        OptionalAddressRange
        OptionalType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,16,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$20,$21,$22,$23,$24,$25);}
    | PARSEOP_QWORDMEMORY '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

QWordSpaceTerm
    : PARSEOP_QWORDSPACE '('        {$<n>$ = TrCreateLeafNode (PARSEOP_QWORDSPACE);}
        ByteConstExpr               {UtCheckIntegerRange ($4, 0xC0, 0xFF);}
        OptionalResourceType
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        ',' ByteConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        ',' QWordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,14,$4,$6,$7,$8,$9,$11,$13,$15,$17,$19,$21,$22,$23,$24);}
    | PARSEOP_QWORDSPACE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

RegisterTerm
    : PARSEOP_REGISTER '('          {$<n>$ = TrCreateLeafNode (PARSEOP_REGISTER);}
        AddressSpaceKeyword
        ',' ByteConstExpr
        ',' ByteConstExpr
        ',' QWordConstExpr
        OptionalAccessSize
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,6,$4,$6,$8,$10,$11,$12);}
    | PARSEOP_REGISTER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

SpiSerialBusTerm
    : PARSEOP_SPI_SERIALBUS '('     {$<n>$ = TrCreateLeafNode (PARSEOP_SPI_SERIALBUS);}
        WordConstExpr               /* 04: DeviceSelection */
        OptionalDevicePolarity      /* 05: DevicePolarity */
        OptionalWireMode            /* 06: WireMode */
        ',' ByteConstExpr           /* 08: DataBitLength */
        OptionalSlaveMode           /* 09: SlaveMode */
        ',' DWordConstExpr          /* 11: ConnectionSpeed */
        ',' ClockPolarityKeyword    /* 13: ClockPolarity */
        ',' ClockPhaseKeyword       /* 15: ClockPhase */
        ',' StringData              /* 17: ResourceSource */
        OptionalByteConstExpr       /* 18: ResourceSourceIndex */
        OptionalResourceType        /* 19: ResourceType */
        OptionalNameString          /* 20: DescriptorName */
        OptionalBuffer_Last         /* 21: VendorData */
        ')'                         {$$ = TrLinkChildren ($<n>3,13,$4,$5,$6,$8,$9,$11,$13,$15,$17,$18,$19,$20,$21);}
    | PARSEOP_SPI_SERIALBUS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

StartDependentFnNoPriTerm
    : PARSEOP_STARTDEPENDENTFN_NOPRI '('    {$<n>$ = TrCreateLeafNode (PARSEOP_STARTDEPENDENTFN_NOPRI);}
        ')' '{'
        ResourceMacroList '}'       {$$ = TrLinkChildren ($<n>3,1,$6);}
    | PARSEOP_STARTDEPENDENTFN_NOPRI '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

StartDependentFnTerm
    : PARSEOP_STARTDEPENDENTFN '('  {$<n>$ = TrCreateLeafNode (PARSEOP_STARTDEPENDENTFN);}
        ByteConstExpr
        ',' ByteConstExpr
        ')' '{'
        ResourceMacroList '}'       {$$ = TrLinkChildren ($<n>3,3,$4,$6,$9);}
    | PARSEOP_STARTDEPENDENTFN '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

UartSerialBusTerm
    : PARSEOP_UART_SERIALBUS '('    {$<n>$ = TrCreateLeafNode (PARSEOP_UART_SERIALBUS);}
        DWordConstExpr              /* 04: ConnectionSpeed */
        OptionalBitsPerByte         /* 05: BitsPerByte */
        OptionalStopBits            /* 06: StopBits */
        ',' ByteConstExpr           /* 08: LinesInUse */
        OptionalEndian              /* 09: Endianess */
        OptionalParityType          /* 10: Parity */
        OptionalFlowControl         /* 11: FlowControl */
        ',' WordConstExpr           /* 13: Rx BufferSize */
        ',' WordConstExpr           /* 15: Tx BufferSize */
        ',' StringData              /* 17: ResourceSource */
        OptionalByteConstExpr       /* 18: ResourceSourceIndex */
        OptionalResourceType        /* 19: ResourceType */
        OptionalNameString          /* 20: DescriptorName */
        OptionalBuffer_Last         /* 21: VendorData */
        ')'                         {$$ = TrLinkChildren ($<n>3,14,$4,$5,$6,$8,$9,$10,$11,$13,$15,$17,$18,$19,$20,$21);}
    | PARSEOP_UART_SERIALBUS '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

VendorLongTerm
    : PARSEOP_VENDORLONG '('        {$<n>$ = TrCreateLeafNode (PARSEOP_VENDORLONG);}
        OptionalNameString_First
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_VENDORLONG '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

VendorShortTerm
    : PARSEOP_VENDORSHORT '('       {$<n>$ = TrCreateLeafNode (PARSEOP_VENDORSHORT);}
        OptionalNameString_First
        ')' '{'
            ByteList '}'            {$$ = TrLinkChildren ($<n>3,2,$4,$7);}
    | PARSEOP_VENDORSHORT '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

WordBusNumberTerm
    : PARSEOP_WORDBUSNUMBER '('     {$<n>$ = TrCreateLeafNode (PARSEOP_WORDBUSNUMBER);}
        OptionalResourceType_First
        OptionalMinType
        OptionalMaxType
        OptionalDecodeType
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,12,$4,$5,$6,$7,$9,$11,$13,$15,$17,$18,$19,$20);}
    | PARSEOP_WORDBUSNUMBER '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

WordIOTerm
    : PARSEOP_WORDIO '('            {$<n>$ = TrCreateLeafNode (PARSEOP_WORDIO);}
        OptionalResourceType_First
        OptionalMinType
        OptionalMaxType
        OptionalDecodeType
        OptionalRangeType
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString
        OptionalType
        OptionalTranslationType_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,15,$4,$5,$6,$7,$8,$10,$12,$14,$16,$18,$19,$20,$21,$22,$23);}
    | PARSEOP_WORDIO '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;

WordSpaceTerm
    : PARSEOP_WORDSPACE '('         {$<n>$ = TrCreateLeafNode (PARSEOP_WORDSPACE);}
        ByteConstExpr               {UtCheckIntegerRange ($4, 0xC0, 0xFF);}
        OptionalResourceType
        OptionalDecodeType
        OptionalMinType
        OptionalMaxType
        ',' ByteConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        ',' WordConstExpr
        OptionalByteConstExpr
        OptionalStringData
        OptionalNameString_Last
        ')'                         {$$ = TrLinkChildren ($<n>3,14,$4,$6,$7,$8,$9,$11,$13,$15,$17,$19,$21,$22,$23,$24);}
    | PARSEOP_WORDSPACE '('
        error ')'                   {$$ = AslDoError(); yyclearin;}
    ;


/******* Object References ***********************************************/

/* Allow IO, DMA, IRQ Resource macro names to also be used as identifiers */

NameString
    : NameSeg                       {}
    | PARSEOP_NAMESTRING            {$$ = TrCreateValuedLeafNode (PARSEOP_NAMESTRING, (ACPI_NATIVE_INT) AslCompilerlval.s);}
    | PARSEOP_IO                    {$$ = TrCreateValuedLeafNode (PARSEOP_NAMESTRING, (ACPI_NATIVE_INT) "IO");}
    | PARSEOP_DMA                   {$$ = TrCreateValuedLeafNode (PARSEOP_NAMESTRING, (ACPI_NATIVE_INT) "DMA");}
    | PARSEOP_IRQ                   {$$ = TrCreateValuedLeafNode (PARSEOP_NAMESTRING, (ACPI_NATIVE_INT) "IRQ");}
    ;

NameSeg
    : PARSEOP_NAMESEG               {$$ = TrCreateValuedLeafNode (PARSEOP_NAMESEG, (ACPI_NATIVE_INT) AslCompilerlval.s);}
    ;


/******* Helper rules ****************************************************/


AmlPackageLengthTerm
    : Integer                       {$$ = TrUpdateNode (PARSEOP_PACKAGE_LENGTH,(ACPI_PARSE_OBJECT *) $1);}
    ;

NameStringItem
    : ',' NameString                {$$ = $2;}
    | ',' error                     {$$ = AslDoError (); yyclearin;}
    ;

TermArgItem
    : ',' TermArg                   {$$ = $2;}
    | ',' error                     {$$ = AslDoError (); yyclearin;}
    ;

OptionalBusMasterKeyword
    : ','                                       {$$ = TrCreateLeafNode (PARSEOP_BUSMASTERTYPE_MASTER);}
    | ',' PARSEOP_BUSMASTERTYPE_MASTER          {$$ = TrCreateLeafNode (PARSEOP_BUSMASTERTYPE_MASTER);}
    | ',' PARSEOP_BUSMASTERTYPE_NOTMASTER       {$$ = TrCreateLeafNode (PARSEOP_BUSMASTERTYPE_NOTMASTER);}
    ;

OptionalAccessAttribTerm
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' ByteConstExpr             {$$ = $2;}
    | ',' AccessAttribKeyword       {$$ = $2;}
    ;

OptionalAccessSize
    :                               {$$ = TrCreateValuedLeafNode (PARSEOP_BYTECONST, 0);}
    | ','                           {$$ = TrCreateValuedLeafNode (PARSEOP_BYTECONST, 0);}
    | ',' ByteConstExpr             {$$ = $2;}
    ;

OptionalAddressingMode
    : ','                           {$$ = NULL;}
    | ',' AddressingModeKeyword     {$$ = $2;}
    ;

OptionalAddressRange
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' AddressKeyword            {$$ = $2;}
    ;

OptionalBitsPerByte
    : ','                           {$$ = NULL;}
    | ',' BitsPerByteKeyword        {$$ = $2;}
    ;

OptionalBuffer_Last
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' DataBufferTerm            {$$ = $2;}
    ;

OptionalByteConstExpr
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' ByteConstExpr             {$$ = $2;}
    ;

OptionalDecodeType
    : ','                           {$$ = NULL;}
    | ',' DecodeKeyword             {$$ = $2;}
    ;

OptionalDevicePolarity
    : ','                           {$$ = NULL;}
    | ',' DevicePolarityKeyword     {$$ = $2;}
    ;

OptionalDWordConstExpr
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' DWordConstExpr            {$$ = $2;}
    ;

OptionalEndian
    : ','                           {$$ = NULL;}
    | ',' EndianKeyword             {$$ = $2;}
    ;

OptionalFlowControl
    : ','                           {$$ = NULL;}
    | ',' FlowControlKeyword        {$$ = $2;}
    ;

OptionalIoRestriction
    : ','                           {$$ = NULL;}
    | ',' IoRestrictionKeyword      {$$ = $2;}
    ;

OptionalListString
    :                               {$$ = TrCreateValuedLeafNode (PARSEOP_STRING_LITERAL, ACPI_TO_INTEGER (""));}   /* Placeholder is a NULL string */
    | ','                           {$$ = TrCreateValuedLeafNode (PARSEOP_STRING_LITERAL, ACPI_TO_INTEGER (""));}   /* Placeholder is a NULL string */
    | ',' TermArg                   {$$ = $2;}
    ;

OptionalMaxType
    : ','                           {$$ = NULL;}
    | ',' MaxKeyword                {$$ = $2;}
    ;

OptionalMemType
    : ','                           {$$ = NULL;}
    | ',' MemTypeKeyword            {$$ = $2;}
    ;

OptionalMinType
    : ','                           {$$ = NULL;}
    | ',' MinKeyword                {$$ = $2;}
    ;

OptionalNameString
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' NameString                {$$ = $2;}
    ;

OptionalNameString_Last
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' NameString                {$$ = $2;}
    ;

OptionalNameString_First
    :                               {$$ = TrCreateLeafNode (PARSEOP_ZERO);}
    | NameString                    {$$ = $1;}
    ;

OptionalObjectTypeKeyword
    :                               {$$ = TrCreateLeafNode (PARSEOP_OBJECTTYPE_UNK);}
    | ',' ObjectTypeKeyword         {$$ = $2;}
    ;

OptionalParityType
    : ','                           {$$ = NULL;}
    | ',' ParityTypeKeyword         {$$ = $2;}
    ;

OptionalQWordConstExpr
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' QWordConstExpr            {$$ = $2;}
    ;

OptionalRangeType
    : ','                           {$$ = NULL;}
    | ',' RangeTypeKeyword          {$$ = $2;}
    ;

OptionalReadWriteKeyword
    :                                   {$$ = TrCreateLeafNode (PARSEOP_READWRITETYPE_BOTH);}
    | PARSEOP_READWRITETYPE_BOTH        {$$ = TrCreateLeafNode (PARSEOP_READWRITETYPE_BOTH);}
    | PARSEOP_READWRITETYPE_READONLY    {$$ = TrCreateLeafNode (PARSEOP_READWRITETYPE_READONLY);}
    ;

OptionalReference
    :                               {$$ = TrCreateLeafNode (PARSEOP_ZERO);}       /* Placeholder is a ZeroOp object */
    | ','                           {$$ = TrCreateLeafNode (PARSEOP_ZERO);}       /* Placeholder is a ZeroOp object */
    | ',' TermArg                   {$$ = $2;}
    ;

OptionalResourceType_First
    :                               {$$ = TrCreateLeafNode (PARSEOP_RESOURCETYPE_CONSUMER);}
    | ResourceTypeKeyword           {$$ = $1;}
    ;

OptionalResourceType
    :                               {$$ = TrCreateLeafNode (PARSEOP_RESOURCETYPE_CONSUMER);}
    | ','                           {$$ = TrCreateLeafNode (PARSEOP_RESOURCETYPE_CONSUMER);}
    | ',' ResourceTypeKeyword       {$$ = $2;}
    ;

OptionalReturnArg
    :                               {$$ = TrSetNodeFlags (TrCreateLeafNode (PARSEOP_ZERO), NODE_IS_NULL_RETURN);}       /* Placeholder is a ZeroOp object */
    | TermArg                       {$$ = $1;}
    ;

OptionalSerializeRuleKeyword
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' SerializeRuleKeyword      {$$ = $2;}
    ;

OptionalSlaveMode
    : ','                           {$$ = NULL;}
    | ',' SlaveModeKeyword          {$$ = $2;}
    ;

OptionalShareType
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' ShareTypeKeyword          {$$ = $2;}
    ;

OptionalShareType_First
    :                               {$$ = NULL;}
    | ShareTypeKeyword              {$$ = $1;}
    ;

OptionalStopBits
    : ','                           {$$ = NULL;}
    | ',' StopBitsKeyword           {$$ = $2;}
    ;

OptionalStringData
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' StringData                {$$ = $2;}
    ;

OptionalTermArg
    :                               {$$ = NULL;}
    | TermArg                       {$$ = $1;}
    ;

OptionalType
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' TypeKeyword               {$$ = $2;}
    ;

OptionalType_Last
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' TypeKeyword               {$$ = $2;}
    ;

OptionalTranslationType_Last
    :                               {$$ = NULL;}
    | ','                           {$$ = NULL;}
    | ',' TranslationKeyword        {$$ = $2;}
    ;

OptionalWireMode
    : ','                           {$$ = NULL;}
    | ',' WireModeKeyword           {$$ = $2;}
    ;

OptionalWordConst
    :                               {$$ = NULL;}
    | WordConst                     {$$ = $1;}
    ;

OptionalWordConstExpr
    : ','                           {$$ = NULL;}
    | ',' WordConstExpr             {$$ = $2;}
    ;

OptionalXferSize
    :                               {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_32, 2);}
    | ','                           {$$ = TrCreateValuedLeafNode (PARSEOP_XFERSIZE_32, 2);}
    | ',' XferSizeKeyword           {$$ = $2;}
    ;
