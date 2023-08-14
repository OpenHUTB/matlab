



function emitParameterRegistration(this,codeWriter)


    trueNumParam=this.LctSpecInfo.Parameters.Numel+int32(this.HasSampleTimeAsParameter);
    codeWriter.wCmt('Number of expected parameters');
    codeWriter.wLine('ssSetNumSFcnParams(S, %d);',trueNumParam);
    codeWriter.wNewLine;


    if trueNumParam~=0
        codeWriter.wLine('#if defined(MATLAB_MEX_FILE) ');
        codeWriter.wBlockStart('if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))');
        codeWriter.wMultiCmtStart();
        codeWriter.wMultiCmtMiddle('If the number of expected input parameters is not equal');
        codeWriter.wMultiCmtMiddle('to the number of parameters entered in the dialog box return.');
        codeWriter.wMultiCmtMiddle('Simulink will generate an error indicating that there is a');
        codeWriter.wMultiCmtMiddle('parameter mismatch.');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('mdlCheckParameters(S);');
        codeWriter.wLine('if (ssGetErrorStatus(S) != NULL) return;');
        codeWriter.decIndent;
        codeWriter.wLine('} else {');
        codeWriter.incIndent;
        codeWriter.wCmt('Return if number of expected != number of actual parameters');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wLine('#endif ');
        codeWriter.wNewLine;
    end


    if trueNumParam>0
        codeWriter.wCmt('Set the parameter''s tunability');
    end

    for ii=1:this.LctSpecInfo.Parameters.Numel
        tunVal=1;
        if ismember(ii,this.LctSpecInfo.ParamAsDimensionId)
            tunVal=0;
        end
        codeWriter.wLine('ssSetSFcnParamTunable(S, %d, %d);',ii-1,tunVal);
    end

    if this.HasSampleTimeAsParameter

        codeWriter.wLine('ssSetSFcnParamTunable(S, %d, 0);',trueNumParam-1);
    end


