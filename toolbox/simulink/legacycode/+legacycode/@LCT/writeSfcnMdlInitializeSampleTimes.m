function writeSfcnMdlInitializeSampleTimes(h,fid,infoStruct)%#ok<INUSL>






    hasSampleTimeAsParameter=strcmp(infoStruct.SampleTime,'parameterized');

    fprintf(fid,'/* Function: mdlInitializeSampleTimes =====================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    This function is used to specify the sample time(s) for your\n');
    fprintf(fid,' *    S-function. You must register the same number of sample times as\n');
    fprintf(fid,' *    specified in ssSetNumSampleTimes.\n');
    fprintf(fid,' */\n');

    fprintf(fid,'static void mdlInitializeSampleTimes(SimStruct *S)\n');
    fprintf(fid,'{\n');

    if strcmp(infoStruct.SampleTime,'inherited')

        fprintf(fid,'  ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);\n');
        fprintf(fid,'  ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);\n');

    elseif hasSampleTimeAsParameter

        fprintf(fid,'  real_T * sampleTime = (real_T*) (mxGetPr(SAMPLE_TIME));\n');
        fprintf(fid,'  mwSize  stArraySize = mxGetM(SAMPLE_TIME) * mxGetN(SAMPLE_TIME);\n');
        fprintf(fid,'\n');
        fprintf(fid,'  ssSetSampleTime(S, 0, sampleTime[0]);\n');
        fprintf(fid,'  if (stArraySize == 1) {\n');
        fprintf(fid,'      ssSetOffsetTime(S, 0, (sampleTime[0] == CONTINUOUS_SAMPLE_TIME?\n');
        fprintf(fid,'                             FIXED_IN_MINOR_STEP_OFFSET: 0.0));\n');
        fprintf(fid,'  } else {\n');
        fprintf(fid,'      ssSetOffsetTime(S, 0, sampleTime[1]);\n');
        fprintf(fid,'  }\n');

    else

        fprintf(fid,'  ssSetSampleTime(S, 0, (real_T)%g);\n',infoStruct.SampleTime(1));
        fprintf(fid,'  ssSetOffsetTime(S, 0, (real_T)%g);\n',infoStruct.SampleTime(2));
    end

    if strcmp(infoStruct.SampleTime,'inherited')||hasSampleTimeAsParameter
        fprintf(fid,'\n');
        fprintf(fid,'#if defined(ssSetModelReferenceSampleTimeDefaultInheritance)\n');
        fprintf(fid,'  ssSetModelReferenceSampleTimeDefaultInheritance(S);\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    else
        fprintf(fid,'\n');
        fprintf(fid,'#if defined(ssSetModelReferenceSampleTimeDisallowInheritance)\n');
        fprintf(fid,'  ssSetModelReferenceSampleTimeDisallowInheritance(S);\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'}\n\n');


