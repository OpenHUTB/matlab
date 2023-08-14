



function emitInitializeSampleTimes(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wMultiCmtStart('Function: mdlInitializeSampleTimes =====================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  This function is used to specify the sample time(s) for your');
    codeWriter.wMultiCmtMiddle('  S-function. You must register the same number of sample times as');
    codeWriter.wMultiCmtMiddle('  specified in ssSetNumSampleTimes.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlInitializeSampleTimes(SimStruct *S)');
    codeWriter.wBlockStart();

    if strcmp(this.LctSpecInfo.SampleTime,'inherited')

        codeWriter.wLine('ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);');
        codeWriter.wLine('ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);');

    elseif this.HasSampleTimeAsParameter

        codeWriter.wLine('real_T * sampleTime = (real_T*) (mxGetPr(SAMPLE_TIME));');
        codeWriter.wLine('size_t  stArraySize = mxGetM(SAMPLE_TIME) * mxGetN(SAMPLE_TIME);');
        codeWriter.newLine;
        codeWriter.wLine('ssSetSampleTime(S, 0, sampleTime[0]);');
        codeWriter.wBlockStart('if (stArraySize == 1)');
        codeWriter.wLine('ssSetOffsetTime(S, 0, (sampleTime[0] == CONTINUOUS_SAMPLE_TIME ? FIXED_IN_MINOR_STEP_OFFSET: 0.0));');
        codeWriter.decIndent;
        codeWriter.wLine('} else {');
        codeWriter.incIndent;
        codeWriter.wLine('ssSetOffsetTime(S, 0, sampleTime[1]);');
        codeWriter.wBlockEnd();

    else






        strSampleTime={...
        rtw.connectivity.CodeInfoUtils.double2str(this.LctSpecInfo.SampleTime(1)),...
        rtw.connectivity.CodeInfoUtils.double2str(this.LctSpecInfo.SampleTime(2))};
        codeWriter.wLine('ssSetSampleTime(S, 0, (real_T)%s);',strSampleTime{1});
        codeWriter.wLine('ssSetOffsetTime(S, 0, (real_T)%s);',strSampleTime{2});
    end

    codeWriter.newLine;
    if strcmp(this.LctSpecInfo.SampleTime,'inherited')||this.HasSampleTimeAsParameter
        codeWriter.wLine('#if defined(ssSetModelReferenceSampleTimeDefaultInheritance)');
        codeWriter.wLine('ssSetModelReferenceSampleTimeDefaultInheritance(S);');
        codeWriter.wLine('#endif');
    else
        codeWriter.wLine('#if defined(ssSetModelReferenceSampleTimeDisallowInheritance)');
        codeWriter.wLine('ssSetModelReferenceSampleTimeDisallowInheritance(S);');
        codeWriter.wLine('#endif');
    end

    codeWriter.wBlockEnd();
