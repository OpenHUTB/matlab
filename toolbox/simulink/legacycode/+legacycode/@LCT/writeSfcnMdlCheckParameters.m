function writeSfcnMdlCheckParameters(h,fid,infoStruct)%#ok<INUSL>





    hasSampleTimeAsParameter=strcmp(infoStruct.SampleTime,'parameterized');


    if infoStruct.Parameters.Num==0&&hasSampleTimeAsParameter==0
        return
    end

    fprintf(fid,'#define MDL_CHECK_PARAMETERS\n');
    fprintf(fid,'#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'  /* Function: mdlCheckParameters ===========================================\n');
    fprintf(fid,'   * Abstract:\n');
    fprintf(fid,'   *    mdlCheckParameters verifies new parameter settings whenever parameter\n');
    fprintf(fid,'   *    change or are re-evaluated during a simulation. When a simulation is\n');
    fprintf(fid,'   *    running, changes to S-function parameters can occur at any time during\n');
    fprintf(fid,'   *    the simulation loop.\n');
    fprintf(fid,' */\n');

    fprintf(fid,'\n');
    fprintf(fid,'static void mdlCheckParameters(SimStruct *S)\n');
    fprintf(fid,'{\n');

    for ii=1:infoStruct.Parameters.Num
        thisParam=infoStruct.Parameters.Parameter(ii);

        fprintf(fid,'/*\n');
        fprintf(fid,' * Check the parameter %d\n',ii);
        fprintf(fid,' */\n');
        fprintf(fid,'if EDIT_OK(S, %d) {\n',ii-1);


        if thisParam.Width==1

            fprintf(fid,'int_T dimsArray[2] = {1, 1};\n');


            if ismember(ii,infoStruct.Parameters.ParamAsDimensionId)
                fprintf(fid,'\n');
                fprintf(fid,'/* Parameter %d must be numeric */\n',ii);
                fprintf(fid,'if(!mxIsNumeric(ssGetSFcnParam(S, %d))) { \n',ii-1);
                fprintf(fid,'  ssSetErrorStatus(S,"Parameter %d must be numeric");\n',ii);
                fprintf(fid,'  return;\n');
                fprintf(fid,'}\n');
            end

        else

            hasDynSize=any(thisParam.Dimensions==-1);


            if length(thisParam.Dimensions)<2




                fprintf(fid,'int_T *dimsArray = (int_T *) mxGetDimensions(ssGetSFcnParam(S, %d));\n',ii-1);
                fprintf(fid,'\n');

                fprintf(fid,'/* Parameter %d must be a vector */\n',ii);
                fprintf(fid,'if ((dimsArray[0] > 1) && (dimsArray[1] > 1)) { \n');
                fprintf(fid,'  ssSetErrorStatus(S,"Parameter %d must be a vector");\n',ii);
                fprintf(fid,'  return;\n');
                fprintf(fid,'}\n');



                if hasDynSize==0
                    fprintf(fid,'\n');
                    fprintf(fid,'/* Parameter %d must have %d elements */\n',...
                    ii,thisParam.Width);
                    fprintf(fid,'if (mxGetNumberOfElements(ssGetSFcnParam(S, %d)) != %d) { \n',...
                    ii-1,thisParam.Width);
                    fprintf(fid,'  ssSetErrorStatus(S,"Parameter %d must have %d elements");\n',...
                    ii,thisParam.Width);
                    fprintf(fid,'  return;\n');
                    fprintf(fid,'}\n');
                end


            else



                if hasDynSize==1
                    fprintf(fid,'int_T *dimsArray = (int_T *) mxGetDimensions(ssGetSFcnParam(S, %d));\n',...
                    ii-1);

                    fprintf(fid,'if (mxGetNumberOfDimensions(ssGetSFcnParam(S, %d)) < %d) {\n',...
                    ii-1,length(thisParam.Dimensions));
                    fprintf(fid,'  ssSetErrorStatus(S,"Parameter %d must have %d dimensions");\n',...
                    ii,length(thisParam.Dimensions));
                    fprintf(fid,'  return;\n');
                    fprintf(fid,'}\n');

                else
                    dimStr='{';
                    sep='';
                    for jj=1:length(thisParam.Dimensions)
                        dimStr=sprintf('%s%s%d',dimStr,sep,thisParam.Dimensions(jj));
                        sep=', ';
                    end
                    dimStr=[dimStr,'}'];%#ok
                    fprintf(fid,'int_T dimsArray[] = %s;\n',dimStr);
                end

                fprintf(fid,'\n');

            end
        end


        fprintf(fid,'\n');
        fprintf(fid,'/* Check the parameter attributes */\n');
        fprintf(fid,['ssCheckSFcnParamValueAttribs(S, '...
        ,'%d, "P%d", DYNAMICALLY_TYPED, %d, dimsArray, %d);\n'],...
        ii-1,ii,max(2,length(thisParam.Dimensions)),thisParam.IsComplex);

        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end

    if hasSampleTimeAsParameter
        fprintf(fid,'/*\n');
        fprintf(fid,' * Check the parameter %d (sample time)\n',infoStruct.Parameters.Num+1);
        fprintf(fid,' */\n');
        fprintf(fid,'if EDIT_OK(S, %d) {\n',infoStruct.Parameters.Num);
        fprintf(fid,'    real_T  *sampleTime = NULL;\n');
        fprintf(fid,'    mwSize  stArraySize = mxGetM(SAMPLE_TIME) * mxGetN(SAMPLE_TIME);\n');
        fprintf(fid,'\n');
        fprintf(fid,'    /* Sample time must be a real scalar value or 2 element array. */\n');
        fprintf(fid,'    if (IsRealMatrix(SAMPLE_TIME) && \n');
        fprintf(fid,'        (stArraySize == 1 || stArraySize == 2) ) {\n');
        fprintf(fid,'        sampleTime = (real_T *) mxGetPr(SAMPLE_TIME);\n');
        fprintf(fid,'    } else {\n');
        fprintf(fid,'        ssSetErrorStatus(S, "Invalid sample time. Sample time must be a real scalar value or an array of two real values.");\n');
        fprintf(fid,'        return;\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'\n');
        fprintf(fid,'    if (sampleTime[0] < 0.0 && sampleTime[0] != -1.0) {\n');
        fprintf(fid,'        ssSetErrorStatus(S, \n');
        fprintf(fid,'         "Invalid sample time. Period must be non-negative or -1 (for inherited).");\n');
        fprintf(fid,'        return;\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'\n');
        fprintf(fid,'    if (stArraySize == 2 && sampleTime[0] > 0.0 && \n');
        fprintf(fid,'        sampleTime[1] >= sampleTime[0]) {\n');
        fprintf(fid,'        ssSetErrorStatus(S, "Invalid sample time. Offset must be smaller than period.");\n');
        fprintf(fid,'        return;\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'\n');
        fprintf(fid,'   if (stArraySize == 2 && sampleTime[0] == -1.0 && sampleTime[1] != 0.0) {\n');
        fprintf(fid,'        ssSetErrorStatus(S, "Invalid sample time. When period is -1, offset must be 0.");\n');
        fprintf(fid,'        return;\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'\n');
        fprintf(fid,'   if (stArraySize == 2 && sampleTime[0] == 0.0 && \n');
        fprintf(fid,'        !(sampleTime[1] == 1.0)) {\n');
        fprintf(fid,'        ssSetErrorStatus(S, "Invalid sample time. When period is 0, offset must be 1.");\n');
        fprintf(fid,'        return;\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'}\n');
    fprintf(fid,'#endif\n');
    fprintf(fid,'\n');

    fprintf(fid,[...
    '#define MDL_PROCESS_PARAMETERS\n',...
    '#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)\n',...
    '/* Function: mdlProcessParameters =========================================\n',...
    ' * Abstract:\n',...
    ' *    Update run-time parameters.\n',...
    ' */\n',...
    'static void mdlProcessParameters(SimStruct *S)\n',...
    '{\n',...
    '    /* Update Run-Time parameters */\n',...
    '    ssUpdateAllTunableParamsAsRunTimeParams(S);\n',...
    '}\n',...
    '#endif\n\n']);


