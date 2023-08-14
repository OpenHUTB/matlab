



function emitOutputs(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wMultiCmtStart('Function: mdlOutputs ===================================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  In this function, you compute the outputs of your S-function');
    codeWriter.wMultiCmtMiddle('  block. Generally outputs are placed in the output vector(s),');
    codeWriter.wMultiCmtMiddle('  ssGetOutputPortSignal.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlOutputs(SimStruct *S, int_T tid)');
    codeWriter.wBlockStart();

    this.emitBlockMethod(codeWriter,this.LctSpecInfo.Fcns.Output,false,false);

    codeWriter.wBlockEnd();
