



function emitHeader(this,codeWriter)


    thisDate=datestr(now,0);
    slVer=legacycode.lct.spec.Common.SLVer;

    codeWriter.wComment(sprintf('file : %s.tlc',this.LctSpecInfo.Specs.SFunctionName));
    codeWriter.wComment('');
    codeWriter.wComment('Description:');
    codeWriter.wComment(sprintf('  Simulink Coder TLC Code Generation file for %s',this.LctSpecInfo.Specs.SFunctionName));
    codeWriter.wComment('');
    codeWriter.wComment(sprintf('Simulink version      : %s %s %s',slVer.Version,slVer.Release,slVer.Date));
    codeWriter.wComment(sprintf('TLC file generated on : %s',thisDate));
    codeWriter.wNewLine;



    codeWriter.wMultilineCommentStart();
    codeWriter.wLine('     %%%-MATLAB_Construction_Commands_Start');
    codeWriter.wLine(legacycode.LCT.generateSpecConstructionCmd(this.LctSpecInfo.Specs,'tlc'));
    codeWriter.wLine('     %%%-MATLAB_Construction_Commands_End');
    codeWriter.wMultilineCommentEnd();
    codeWriter.wNewLine;

    codeWriter.wLine('%%implements %s "C"',this.LctSpecInfo.Specs.SFunctionName);
    codeWriter.wNewLine;

    if this.LctSpecInfo.Specs.Options.stubSimBehavior
        codeWriter.wLine('%assign lLCTLocation=FEVAL("which", "legacy_code")');
        codeWriter.wLine('%assign lLCTFolder=FEVAL("fileparts", lLCTLocation)');
        codeWriter.wLine('%assign lctTlcLibPath=FEVAL("fullfile", lLCTFolder, "+legacycode", "+lct", "+gen", "+tlclib")');
        codeWriter.wLine('%addincludepath "%<lctTlcLibPath>"');
        codeWriter.wLine('%include "xrelimportlib.tlc"');
        codeWriter.wNewLine;
    end


    if~(this.LctSpecInfo.hasWrapper||this.LctSpecInfo.isCPP)
        return
    end


    codeWriter.wFunctionDefStart('FcnGenerateUniqueFileName','(filename, type) void');


    bodyTxt={...
    '%assign isReserved = TLC_FALSE',...
    '%foreach idxFile = CompiledModel.DataObjectUsage.NumFiles[0]',...
    '    %assign thisFile = CompiledModel.DataObjectUsage.File[idxFile]',...
    '    %if (thisFile.Name==filename) && (thisFile.Type==type)',...
    '        %assign isReserved = TLC_TRUE',...
    '        %break',...
    '    %endif',...
    '%endforeach',...
    '%if (isReserved==TLC_TRUE)',...
    '    %assign filename = FcnGenerateUniqueFileName(filename + "_", type)',...
    '%endif',...
    '%return filename',...
    };
    cellfun(@(aLine)codeWriter.wLine(aLine),bodyTxt);


    codeWriter.wFunctionDefEnd();
