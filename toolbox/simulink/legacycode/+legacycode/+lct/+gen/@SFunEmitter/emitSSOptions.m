



function emitSSOptions(this,codeWriter)

    codeWriter.wMultiCmtStart();
    codeWriter.wMultiCmtMiddle('All options have the form SS_OPTION_<name> and are documented in');
    codeWriter.wMultiCmtMiddle('matlabroot/simulink/include/simstruc.h. The options should be');
    codeWriter.wMultiCmtMiddle('bitwise or''d together as in');
    codeWriter.wMultiCmtMiddle('   ssSetOptions(S, (SS_OPTION_name1 | SS_OPTION_name2))');
    codeWriter.wMultiCmtEnd();

    codeWriter.wLine('ssSetOptions(S,');
    codeWriter.incIndent;

    if this.LctSpecInfo.Specs.Options.useTlcWithAccel&&~this.LctSpecInfo.canUseSFunCgAPI
        codeWriter.wLine('SS_OPTION_USE_TLC_WITH_ACCELERATOR |');
    end

    if this.LctSpecInfo.Specs.Options.canBeCalledConditionally
        codeWriter.wLine('SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |');
    end

    if this.LctSpecInfo.Specs.Options.isVolatile==false
        codeWriter.wLine('SS_OPTION_NONVOLATILE |');
    end

    codeWriter.wLine('SS_OPTION_EXCEPTION_FREE_CODE |');
    codeWriter.wLine('SS_OPTION_WORKS_WITH_CODE_REUSE |');
    codeWriter.wLine('SS_OPTION_SFUNCTION_INLINED_FOR_RTW |');
    codeWriter.wLine('SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME');

    codeWriter.decIndent;
    codeWriter.wLine(');');

    if this.LctSpecInfo.Specs.Options.supportCodeReuseAcrossModels
        codeWriter.wLine('ssSetSupportedForCodeReuseAcrossModels(S, 1);')
    end

