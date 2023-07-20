



function emitStart(this,codeWriter)


    if iscell(this.LctSpecInfo.Fcns.Start)
        startFcn=this.LctSpecInfo.Fcns.Start;
    else
        startFcn={this.LctSpecInfo.Fcns.Start};
    end

    numStartFcns=numel(startFcn);
    if~startFcn{1}.IsSpecified&&~this.HasBusInfoToRegister
        return
    end

    codeWriter.wNewLine;
    codeWriter.wLine('#define MDL_START');
    codeWriter.wLine('#if defined(MDL_START)');
    codeWriter.wMultiCmtStart('Function: mdlStart =====================================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  This function is called once at start of model execution. If you');
    codeWriter.wMultiCmtMiddle('  have states that should be initialized once, this is the place');
    codeWriter.wMultiCmtMiddle('  to do it.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlStart(SimStruct *S)');
    codeWriter.wBlockStart();

    for idx=1:numStartFcns
        this.emitBlockMethod(codeWriter,startFcn{idx},true,false);
    end

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');
