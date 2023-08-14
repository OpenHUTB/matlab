



function emitBlockOutputSignal(this,codeWriter)


    funSpec=this.LctSpecInfo.Fcns.Output;






    if(funSpec.LhsArgs.Numel==0)||~funSpec.IsSpecified||...
        (this.LctSpecInfo.Outputs.Numel>1)||(this.LctSpecInfo.hasRowMajorNDArray==true)
        return
    end


    codeWriter.wFunctionDefStart('BlockOutputSignal','(block,system,portIdx,ucv,lcv,idx,retType) void');


    this.emitLocalsForFunCall(codeWriter,funSpec,true);


    [~,fcnName,argList]=this.genFunCall(funSpec);

    codeWriter.wComment('');
    codeWriter.wLine('%switch retType');
    codeWriter.wLine('  %case "Signal"');
    codeWriter.wLine('    %%if portIdx == %d',funSpec.LhsArgs.Items(1).Id-1);
    codeWriter.wLine('      %%return "%s(%s)"',fcnName,strjoin(argList,', '));
    codeWriter.wLine('    %else');
    codeWriter.wLine('      %assign errTxt = "Block output port index not supported: %<portIdx>"');
    codeWriter.wLine('      %<LibBlockReportError(block,errTxt)>');
    codeWriter.wLine('    %endif');
    codeWriter.wLine('  %default');
    codeWriter.wLine('    %assign errTxt = "Unsupported return type: %<retType>"');
    codeWriter.wLine('    %<LibBlockReportError(block,errTxt)>');
    codeWriter.wLine('%endswitch');


    codeWriter.wFunctionDefEnd();


