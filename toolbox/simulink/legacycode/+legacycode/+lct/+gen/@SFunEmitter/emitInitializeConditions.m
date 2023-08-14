



function emitInitializeConditions(this,codeWriter)


    if~this.LctSpecInfo.Fcns.InitializeConditions.IsSpecified
        return
    end

    codeWriter.wNewLine;
    codeWriter.wLine('#define MDL_INITIALIZE_CONDITIONS');
    codeWriter.wLine('#if defined(MDL_INITIALIZE_CONDITIONS)');
    codeWriter.wMultiCmtStart('Function: mdlInitializeConditions ======================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  In this function, you should initialize the states for your S-function block.');
    codeWriter.wMultiCmtMiddle('  You can also perform any other initialization activities that your');
    codeWriter.wMultiCmtMiddle('  S-function may require. Note, this routine will be called at the');
    codeWriter.wMultiCmtMiddle('  start of simulation and if it is present in an enabled subsystem');
    codeWriter.wMultiCmtMiddle('  configured to reset states, it will be call when the enabled subsystem');
    codeWriter.wMultiCmtMiddle('  restarts execution to reset the states.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlInitializeConditions(SimStruct *S)');
    codeWriter.wBlockStart();

    this.emitBlockMethod(codeWriter,this.LctSpecInfo.Fcns.InitializeConditions,false,false);

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');
