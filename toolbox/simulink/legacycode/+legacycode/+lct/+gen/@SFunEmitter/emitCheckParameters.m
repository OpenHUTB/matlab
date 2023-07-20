



function emitCheckParameters(this,codeWriter)


    if(this.LctSpecInfo.Parameters.Numel<1)&&~this.HasSampleTimeAsParameter
        return
    end

    codeWriter.newLine;
    codeWriter.wLine('#define MDL_CHECK_PARAMETERS');
    codeWriter.wLine('#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)');
    codeWriter.wMultiCmtStart('Function: mdlCheckParameters ===========================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  mdlCheckParameters verifies new parameter settings whenever parameter');
    codeWriter.wMultiCmtMiddle('  change or are re-evaluated during a simulation. When a simulation is');
    codeWriter.wMultiCmtMiddle('  running, changes to S-function parameters can occur at any time during');
    codeWriter.wMultiCmtMiddle('  the simulation loop.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlCheckParameters(SimStruct *S)');
    codeWriter.wBlockStart();

    emitBody(this,codeWriter);

    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');
    codeWriter.newLine;

    codeWriter.wLine('#define MDL_PROCESS_PARAMETERS');
    codeWriter.wLine('#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)');
    codeWriter.wMultiCmtStart('Function: mdlProcessParameters =========================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  Update run-time parameters.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlProcessParameters(SimStruct *S)');
    codeWriter.wBlockStart();
    codeWriter.wLine('ssUpdateAllTunableParamsAsRunTimeParams(S);');
    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');

end


function emitBody(this,codeWriter)

    for ii=1:this.LctSpecInfo.Parameters.Numel

        dataSpec=this.LctSpecInfo.Parameters.Items(ii);
        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');

        codeWriter.wCmt('Check the parameter %d',ii);
        codeWriter.wBlockStart('if (EDIT_OK(S, %d))',ii-1);


        if dataSpec.Width==1

            codeWriter.wLine('int_T dimsArray[2] = {1, 1};');


            if ismember(ii,this.LctSpecInfo.ParamAsDimensionId)
                codeWriter.wNewLine;
                msg=sprintf('Parameter %d must be numeric',ii);
                codeWriter.wCmt(msg);
                codeWriter.wBlockStart('if (!mxIsNumeric(ssGetSFcnParam(S, %d)))',ii-1);
                codeWriter.wLine('ssSetErrorStatus(S,"%s");',msg);
                codeWriter.wLine('return;');
                codeWriter.wBlockEnd();
            end
        else

            hasDynSize=any(dataSpec.Dimensions==-1);


            numDims=numel(dataSpec.Dimensions);

            if numDims<2




                codeWriter.wLine('int_T dimsArray[2];');
                codeWriter.wLine('dimsArray[0] = %s;',apiInfo.Dims(0));
                codeWriter.wLine('dimsArray[1] = %s;',apiInfo.Dims(1));
                codeWriter.wNewLine;

                msg=sprintf('Parameter %d must be a vector',ii);
                codeWriter.wCmt(msg);
                codeWriter.wBlockStart('if ((dimsArray[0] > 1) && (dimsArray[1] > 1))');
                codeWriter.wLine('ssSetErrorStatus(S,"%s");',msg);
                codeWriter.wLine('return;');
                codeWriter.wBlockEnd();



                if~hasDynSize
                    codeWriter.wNewLine;
                    msg=sprintf('Parameter %d must have %d elements',ii,dataSpec.Width);
                    codeWriter.wCmt(msg);
                    codeWriter.wBlockStart('if ((%s) != %d)',apiInfo.Width,dataSpec.Width);
                    codeWriter.wLine('ssSetErrorStatus(S,"%s");',msg);
                    codeWriter.wLine('return;');
                    codeWriter.wBlockEnd();
                end
            else



                if hasDynSize

                    codeWriter.wLine('int_T dimsArray[%d];',max(2,numDims));


                    codeWriter.wNewLine;
                    codeWriter.wBlockStart('if (%s < %d)',apiInfo.NumDims,numDims);
                    codeWriter.wLine('ssSetErrorStatus(S,"Parameter %d must have %d dimensions");',ii,numDims);
                    codeWriter.wLine('return;');
                    codeWriter.wBlockEnd();


                    codeWriter.wNewLine;
                    for jj=1:numDims
                        codeWriter.wLine('dimsArray[%d] = %s;',jj-1,apiInfo.Dims(jj-1));
                    end

                else

                    dimList=cell(1,numDims);
                    for jj=1:numDims
                        dimList{jj}=sprintf('%d',dataSpec.Dimensions(jj));
                    end
                    codeWriter.wLine('int_T dimsArray[] = {%s};',strjoin(dimList,', '));
                end
            end
        end


        codeWriter.wNewLine;
        codeWriter.wCmt('Check the parameter attributes');
        codeWriter.wLine('ssCheckSFcnParamValueAttribs(S, %d, "P%d", DYNAMICALLY_TYPED, %d, dimsArray, %d);',...
        ii-1,ii,max(2,length(dataSpec.Dimensions)),dataSpec.IsComplex);

        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
    end

    if this.HasSampleTimeAsParameter
        codeWriter.wCmt('Check the parameter %d (sample time)',this.LctSpecInfo.Parameters.Numel+1);
        codeWriter.wBlockStart('if (EDIT_OK(S, %d))',this.LctSpecInfo.Parameters.Numel);
        codeWriter.wLine('real_T  *sampleTime = NULL;');
        codeWriter.wLine('size_t  stArraySize = mxGetM(SAMPLE_TIME) * mxGetN(SAMPLE_TIME);');
        codeWriter.wNewLine;
        codeWriter.wCmt('Sample time must be a real scalar value or 2 element array');
        codeWriter.wBlockStart('if (IsRealMatrix(SAMPLE_TIME) && (stArraySize == 1 || stArraySize == 2))');
        codeWriter.wLine('sampleTime = (real_T *) mxGetPr(SAMPLE_TIME);');
        codeWriter.decIndent;
        codeWriter.wLine('} else {');
        codeWriter.incIndent;
        codeWriter.wLine('ssSetErrorStatus(S, "Invalid sample time. Sample time must be a real scalar value or an array of two real values.");');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (sampleTime[0] < 0.0 && sampleTime[0] != -1.0)');
        codeWriter.wLine('ssSetErrorStatus(S, "Invalid sample time. Period must be non-negative or -1 (for inherited).");');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (stArraySize == 2 && sampleTime[0] > 0.0 && sampleTime[1] >= sampleTime[0])');
        codeWriter.wLine('ssSetErrorStatus(S, "Invalid sample time. Offset must be smaller than period.");');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (stArraySize == 2 && sampleTime[0] == -1.0 && sampleTime[1] != 0.0)');
        codeWriter.wLine('ssSetErrorStatus(S, "Invalid sample time. When period is -1, offset must be 0.");');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (stArraySize == 2 && sampleTime[0] == 0.0 && !(sampleTime[1] == 1.0))');
        codeWriter.wLine('ssSetErrorStatus(S, "Invalid sample time. When period is 0, offset must be 1.");');
        codeWriter.wLine('return;');
        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
    end

end


