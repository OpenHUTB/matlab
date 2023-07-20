



function emitTerminate(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wMultiCmtStart('Function: mdlTerminate =================================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  In this function, you should perform any actions that are necessary');
    codeWriter.wMultiCmtMiddle('  at the termination of a simulation.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlTerminate(SimStruct *S)');
    codeWriter.wBlockStart();

    this.emitBlockMethod(codeWriter,this.LctSpecInfo.Fcns.Terminate,false,true);

    codeWriter.wBlockEnd();
