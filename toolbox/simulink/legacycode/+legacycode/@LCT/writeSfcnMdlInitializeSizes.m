function writeSfcnMdlInitializeSizes(h,fid,infoStruct)





    hasSampleTimeAsParameter=strcmp(infoStruct.SampleTime,'parameterized');

    fprintf(fid,'/* Function: mdlInitializeSizes ===========================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *    The sizes information is used by Simulink to determine the S-function\n');
    fprintf(fid,' *    block''s characteristics (number of inputs, outputs, states, etc.).\n');
    fprintf(fid,' */\n');

    fprintf(fid,'static void mdlInitializeSizes(SimStruct *S)\n');
    fprintf(fid,'{\n');


    visitedTypeId=[];



    if infoStruct.hasWrapper&&infoStruct.hasBusOrStruct==true
        fprintf(fid,'\n');
        fprintf(fid,'   /*\n');
        fprintf(fid,'    * Get the value returned by rtwenvironmentmode(modelName)\n');
        fprintf(fid,'    */\n');
        fprintf(fid,'if (ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL) {\n');
        fprintf(fid,'   isSimulationTarget = GetRTWEnvironmentMode(S);\n');
        fprintf(fid,'   if (isSimulationTarget==-1) {\n');
        fprintf(fid,'      ssSetErrorStatus(S, "Unable to determine a valid code generation environment mode.");');
        fprintf(fid,'      return;\n');
        fprintf(fid,'   }\n');
        fprintf(fid,'   isSimulationTarget |= ssRTWGenIsModelReferenceSimTarget(S);\n');
        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end


    fprintf(fid,'/* Number of expected parameters */\n');
    numParam=infoStruct.Parameters.Num;
    trueNumParam=numParam+int32(hasSampleTimeAsParameter);
    fprintf(fid,'ssSetNumSFcnParams(S, %d);\n',trueNumParam);


    if trueNumParam~=0
        fprintf(fid,'\n');
        fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');
        fprintf(fid,'if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {\n');
        fprintf(fid,'  /*\n');
        fprintf(fid,'   * If the number of expected input parameters is not equal\n');
        fprintf(fid,'   * to the number of parameters entered in the dialog box return.\n');
        fprintf(fid,'   * Simulink will generate an error indicating that there is a\n');
        fprintf(fid,'   * parameter mismatch.\n');
        fprintf(fid,'   */\n');
        fprintf(fid,'  mdlCheckParameters(S);\n');
        fprintf(fid,'  if (ssGetErrorStatus(S) != NULL) {\n');
        fprintf(fid,'    return;\n');
        fprintf(fid,'  }\n');
        fprintf(fid,'} else {\n');
        fprintf(fid,'  /* Return if number of expected != number of actual parameters */\n');
        fprintf(fid,'  return;\n');
        fprintf(fid,'}\n');
        fprintf(fid,'#endif \n');
    end


    if trueNumParam~=0
        fprintf(fid,'\n');
        fprintf(fid,'/* Set the parameter''s tunability */\n');
    end
    for ii=1:numParam
        tunVal=1;
        if ismember(ii,infoStruct.Parameters.ParamAsDimensionId)
            tunVal=0;
        end
        fprintf(fid,'ssSetSFcnParamTunable(S, %d, %d);\n',ii-1,tunVal);
    end
    if hasSampleTimeAsParameter

        fprintf(fid,'ssSetSFcnParamTunable(S, %d, 0);\n',trueNumParam-1);
    end
    fprintf(fid,'\n');


    fprintf(fid,'/*\n');
    fprintf(fid,' * Set the number of work vectors. \n');
    fprintf(fid,' */\n');


    numDWorks=infoStruct.DWorks.NumDWorks;
    numDWorks2D=infoStruct.DWorks.NumDWorkFor2DMatrix;





    trueNumDWorks=infoStruct.DWorks.TotalNumDWorks-infoStruct.DWorks.NumDWorkForBus;

    if infoStruct.hasBusOrStruct==false

        fprintf(fid,'if (!ssSetNumDWork(S, %d)) return;\n',numDWorks+numDWorks2D);
        fprintf(fid,'ssSetNumPWork(S, %d);\n',infoStruct.DWorks.NumPWorks);
    else


        fprintf(fid,'if (!isDWorkNeeded(S)) {\n');
        fprintf(fid,'   ssSetNumPWork(S, %d);\n',infoStruct.DWorks.NumPWorks);
        fprintf(fid,'   if (!ssSetNumDWork(S, %d)) return;\n',numDWorks+numDWorks2D);
        fprintf(fid,'} else {\n');
        fprintf(fid,'   ssSetNumPWork(S, %d);\n',...
        infoStruct.DWorks.NumPWorks+infoStruct.DWorks.NumDWorkForBus);
        fprintf(fid,'   if (!ssSetNumDWork(S, %d)) return;\n\n',trueNumDWorks);


        dWorkId=trueNumDWorks-2;
        fprintf(fid,'/*\n');
        fprintf(fid,' * Configure the dwork %d (__dtSizeInfo)\n',dWorkId);
        fprintf(fid,' */\n');
        fprintf(fid,'ssSetDWorkDataType(S, %d, SS_INT32);\n',dWorkId);
        fprintf(fid,'ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);\n',dWorkId);
        fprintf(fid,'ssSetDWorkName(S, %d, "dtSizeInfo");\n',dWorkId);
        fprintf(fid,'ssSetDWorkWidth(S, %d, %d);\n',...
        dWorkId,numel(infoStruct.DataTypes.BusInfo.DataTypeSizeTable));
        fprintf(fid,'ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);\n',dWorkId);
        fprintf(fid,'\n');


        dWorkId=trueNumDWorks-1;
        fprintf(fid,'/*\n');
        fprintf(fid,' * Configure the dwork %d (__dtBusInfo)\n',dWorkId);
        fprintf(fid,' */\n');
        fprintf(fid,'ssSetDWorkDataType(S, %d, SS_INT32);\n',dWorkId);
        fprintf(fid,'ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);\n',dWorkId);
        fprintf(fid,'ssSetDWorkName(S, %d, "dtBusInfo");\n',dWorkId);
        fprintf(fid,'ssSetDWorkWidth(S, %d, %d);\n',...
        dWorkId,2*size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1));
        fprintf(fid,'ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);\n',dWorkId);
        fprintf(fid,'\n');

        fprintf(fid,'}\n');
    end
    fprintf(fid,'\n');

    for ii=1:infoStruct.DWorks.Num

        thisDWork=infoStruct.DWorks.DWork(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisDWork.DataTypeId);
        if isempty(thisDWork.dwIdx)

            continue
        end

        fprintf(fid,'/*\n');
        fprintf(fid,' * Configure the dwork %d (work%d)\n',thisDWork.dwIdx,ii);
        fprintf(fid,' */\n');


        if(thisDataType.HasObject==1)
            if~ismember(thisDataType.Id,visitedTypeId)
                visitedTypeId(end+1)=thisDataType.Id;%#ok<AGROW>
            end
            fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');
            fprintf(fid,'if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {\n');
            fprintf(fid,'  DTypeId dataTypeIdReg;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
            thisDataType.DTName);
            fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssSetDWorkDataType(S, %d, dataTypeIdReg);\n',thisDWork.dwIdx-1);
            fprintf(fid,'}\n');
            fprintf(fid,'#endif\n');

        else
            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
            fprintf(fid,'ssSetDWorkDataType(S, %d, %s);\n',...
            thisDWork.dwIdx-1,thisDataType.Enum);

        end




        fprintf(fid,'ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);\n',thisDWork.dwIdx-1);
        fprintf(fid,'ssSetDWorkName(S, %d, "work%d");\n',thisDWork.dwIdx-1,ii);



        dimStr=h.generateSfcnDataDimStr(infoStruct,'DWork',ii,'init');
        nbDims=length(dimStr);



        castStr='';
        if~isempty(find(strncmp('mxGetScalar',dimStr,11),1))
            castStr='(int_T) ';
        end



        if nbDims==1||ismember('DYNAMICALLY_SIZED',dimStr)

            fprintf(fid,'ssSetDWorkWidth(S, %d, %s%s);\n',...
            thisDWork.dwIdx-1,castStr,dimStr{1});
        else

            fprintf(fid,'{\n');
            fprintf(fid,'int_T dims[%d];\n',nbDims);
            fprintf(fid,'int_T width;\n');
            fprintf(fid,'\n');


            width='';
            mult='';
            for jj=1:length(dimStr)
                fprintf(fid,'dims[%d] = %s;\n',jj-1,dimStr{jj});
                width=sprintf('%s %s dims[%d]',width,mult,jj-1);
                mult='*';
            end
            fprintf(fid,'width = %s;\n',width);
            fprintf(fid,'\n');
            fprintf(fid,'ssSetDWorkWidth(S, %d, width);\n',thisDWork.dwIdx-1);
            fprintf(fid,'}\n');
        end


        if thisDWork.IsComplex==1
            fprintf(fid,'ssSetDWorkComplexSignal(S, %d, COMPLEX_YES);\n',thisDWork.dwIdx-1);
        else
            fprintf(fid,'ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);\n',thisDWork.dwIdx-1);
        end

        fprintf(fid,'\n');
    end


    if infoStruct.DWorks.NumDWorkFor2DMatrix
        for ii=1:infoStruct.DWorks.NumDWorkFor2DMatrix

            thisDWork=infoStruct.DWorks.DWorkFor2DMatrix(ii);
            thisDataType=infoStruct.DataTypes.DataType(thisDWork.DataTypeId);
            thisDWorkNumber=numDWorks+ii-1;

            fprintf(fid,'/*\n');
            fprintf(fid,' * Configure the dwork %d (%sM2D)\n',thisDWorkNumber+1,thisDWork.Identifier);
            fprintf(fid,' */\n');


            if thisDataType.HasObject==1
                if~ismember(thisDataType.Id,visitedTypeId)
                    visitedTypeId(end+1)=thisDataType.Id;%#ok<AGROW>
                end
                fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');
                fprintf(fid,'if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {\n');
                fprintf(fid,'  DTypeId dataTypeIdReg;\n');
                fprintf(fid,'\n');
                fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
                thisDataType.DTName);
                fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
                fprintf(fid,'\n');
                fprintf(fid,'  ssSetDWorkDataType(S, %d, dataTypeIdReg);\n',thisDWorkNumber);
                fprintf(fid,'}\n');
                fprintf(fid,'#endif\n');

            else
                thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
                fprintf(fid,'ssSetDWorkDataType(S, %d, %s);\n',thisDWorkNumber,thisDataType.Enum);

            end




            fprintf(fid,'ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);\n',thisDWorkNumber);
            fprintf(fid,'ssSetDWorkName(S, %d, "%sM2D");\n',thisDWorkNumber,thisDWork.Identifier);


            fprintf(fid,'ssSetDWorkWidth(S, %d, DYNAMICALLY_SIZED);\n',thisDWorkNumber);


            fprintf(fid,'ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);\n',thisDWorkNumber);

            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    end


    fprintf(fid,'/*\n');
    fprintf(fid,' * Set the number of input ports. \n');
    fprintf(fid,' */\n');


    fprintf(fid,'if (!ssSetNumInputPorts(S, %d)) return;\n',infoStruct.Inputs.Num);
    fprintf(fid,'\n');

    for ii=1:infoStruct.Inputs.Num

        thisInput=infoStruct.Inputs.Input(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisInput.DataTypeId);

        fprintf(fid,'/*\n');
        fprintf(fid,' * Configure the input port %d\n',ii);
        fprintf(fid,' */\n');


        if(thisDataType.HasObject==1)
            if~ismember(thisDataType.Id,visitedTypeId)
                visitedTypeId(end+1)=thisDataType.Id;%#ok<AGROW>
            end
            fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');
            fprintf(fid,'if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {\n');
            fprintf(fid,'  DTypeId dataTypeIdReg;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
            thisDataType.DTName);
            fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssSetInputPortDataType(S, %d, dataTypeIdReg);\n',ii-1);
            fprintf(fid,'}\n');
            fprintf(fid,'#endif\n');


            if(thisDataType.IsBus==1)
                fprintf(fid,'ssSetBusInputAsStruct(S, %d, 1);\n',ii-1);
            end

        else
            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
            fprintf(fid,'ssSetInputPortDataType(S, %d, %s);\n',...
            ii-1,thisDataType.Enum);

        end



        dimStr=h.generateSfcnDataDimStr(infoStruct,'Input',ii,'init');
        nbDims=length(dimStr);



        castStr='';
        if~isempty(find(strncmp('mxGetScalar',dimStr,11),1))
            castStr='(int_T) ';
        end

        if nbDims==1
            fprintf(fid,'ssSetInputPortWidth(S, %d, %s%s);\n',...
            ii-1,castStr,dimStr{1});
        elseif nbDims==2
            fprintf(fid,'ssSetInputPortMatrixDimensions(S, %d, %s%s, %s%s);\n',...
            ii-1,castStr,dimStr{1},castStr,dimStr{2});
        else


            if ismember('DYNAMICALLY_SIZED',dimStr)
                fprintf(fid,'ssSetInputPortDimensionInfo(S,  %d, DYNAMIC_DIMENSION);\n',ii-1);
            else
                fprintf(fid,'{\n');
                fprintf(fid,'    DECL_AND_INIT_DIMSINFO(dimsInfo);\n');
                fprintf(fid,'    %s\n',iGetInputOutputNDDimsStmtDuringInit(infoStruct,dimStr));
                fprintf(fid,'    ssSetInputPortDimensionInfo(S,  %d, &dimsInfo);\n',ii-1);
                fprintf(fid,'}\n');
            end
        end


        if thisInput.IsComplex==1
            fprintf(fid,'ssSetInputPortComplexSignal(S, %d, COMPLEX_YES);\n',ii-1);
        else
            fprintf(fid,'ssSetInputPortComplexSignal(S, %d, COMPLEX_NO);\n',ii-1);
        end

        fprintf(fid,'ssSetInputPortDirectFeedThrough(S, %d, 1);\n',ii-1);






        bool=(infoStruct.Specs.Options.isMacro==false);
        if(bool==1)
            for jj=1:infoStruct.Fcns.Output.RhsArgs.NumArgs
                thisArg=infoStruct.Fcns.Output.RhsArgs.Arg(jj);
                if strcmp(thisArg.Type,'Input')&&(thisArg.DataId==ii)
                    if strcmp(thisArg.AccessType,'pointer')
                        bool=0;
                    end
                    break
                end
            end
        end

        fprintf(fid,'ssSetInputPortAcceptExprInRTW(S, %d, %d);\n',ii-1,bool);
        fprintf(fid,'ssSetInputPortOverWritable(S, %d, %d);\n',ii-1,bool);
        fprintf(fid,'ssSetInputPortOptimOpts(S, %d, SS_REUSABLE_AND_LOCAL);\n',ii-1);
        fprintf(fid,'ssSetInputPortRequiredContiguous(S, %d, 1);\n',ii-1);
        fprintf(fid,'\n');
    end

    fprintf(fid,'/*\n');
    fprintf(fid,' * Set the number of output ports.\n');
    fprintf(fid,' */\n');

    fprintf(fid,'if (!ssSetNumOutputPorts(S, %d)) return;\n',infoStruct.Outputs.Num);
    fprintf(fid,'\n');

    for ii=1:infoStruct.Outputs.Num

        thisOutput=infoStruct.Outputs.Output(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisOutput.DataTypeId);

        fprintf(fid,'/*\n');
        fprintf(fid,' * Configure the output port %d\n',ii);
        fprintf(fid,' */\n');

        if(thisDataType.HasObject==1)
            if~ismember(thisDataType.Id,visitedTypeId)
                visitedTypeId(end+1)=thisDataType.Id;%#ok<AGROW>
            end
            fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');
            fprintf(fid,'if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {\n');
            fprintf(fid,'  DTypeId dataTypeIdReg;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
            thisDataType.DTName);
            fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssSetOutputPortDataType(S, %d, dataTypeIdReg);\n',ii-1);
            fprintf(fid,'}\n');
            fprintf(fid,'#endif\n');

            if(thisDataType.IsBus==1)
                fprintf(fid,'ssSetBusOutputObjectName(S, %d, (void *)"%s");\n',...
                ii-1,thisDataType.DTName);
                fprintf(fid,'ssSetBusOutputAsStruct(S, %d, 1);\n',ii-1);
            end

        else
            thisDataType=infoStruct.DataTypes.DataType(thisDataType.IdAliasedThruTo);
            fprintf(fid,'ssSetOutputPortDataType(S, %d, %s);\n',...
            ii-1,thisDataType.Enum);

        end



        dimStr=h.generateSfcnDataDimStr(infoStruct,'Output',ii,'init');
        nbDims=length(dimStr);



        castStr='';
        if~isempty(find(strncmp('mxGetScalar',dimStr,11),1))
            castStr='(int_T) ';
        end

        if nbDims==1
            fprintf(fid,'ssSetOutputPortWidth(S, %d, %s%s);\n',...
            ii-1,castStr,dimStr{1});
        elseif nbDims==2
            fprintf(fid,'ssSetOutputPortMatrixDimensions(S, %d, %s%s, %s%s);\n',...
            ii-1,castStr,dimStr{1},castStr,dimStr{2});
        else


            if ismember('DYNAMICALLY_SIZED',dimStr)
                fprintf(fid,'ssSetOutputPortDimensionInfo(S,  %d, DYNAMIC_DIMENSION);\n',ii-1);
            else
                fprintf(fid,'{\n');
                fprintf(fid,'    DECL_AND_INIT_DIMSINFO(dimsInfo);\n');
                fprintf(fid,'    %s\n',iGetInputOutputNDDimsStmtDuringInit(infoStruct,dimStr));
                fprintf(fid,'    ssSetOutputPortDimensionInfo(S,  %d, &dimsInfo);\n',ii-1);
                fprintf(fid,'}\n');
            end
        end


        if thisOutput.IsComplex==1
            fprintf(fid,'ssSetOutputPortComplexSignal(S, %d, COMPLEX_YES);\n',ii-1);
        else
            fprintf(fid,'ssSetOutputPortComplexSignal(S, %d, COMPLEX_NO);\n',ii-1);
        end






        bool=(infoStruct.Outputs.Num<=1)&&(infoStruct.has2DMatrix==false);
        for jj=1:infoStruct.Fcns.Output.RhsArgs.NumArgs
            thisArg=infoStruct.Fcns.Output.RhsArgs.Arg(jj);
            if strcmp(thisArg.Type,'Output')&&(thisArg.DataId==ii)
                bool=0;
                break
            end
        end
        if infoStruct.Fcns.Output.LhsArgs.NumArgs
            thisArg=infoStruct.Fcns.Output.LhsArgs.Arg(1);
            if(thisArg.DataId==ii)&&((thisDataType.IsBus==1)||(thisDataType.IsStruct==1))
                bool=0;
            end
        end


        if infoStruct.Specs.Options.outputsConditionallyWritten
            portOptim='SS_NOT_REUSABLE_AND_GLOBAL';
        else
            portOptim='SS_REUSABLE_AND_LOCAL';
        end
        fprintf(fid,'ssSetOutputPortOptimOpts(S, %d, %s);\n',ii-1,portOptim);
        fprintf(fid,'ssSetOutputPortOutputExprInRTW(S, %d, %d);\n',...
        ii-1,bool);
        fprintf(fid,'\n');
    end



    hasInitFcn=infoStruct.Fcns.InitializeConditions.IsSpecified;
    hasStartFcn=infoStruct.Fcns.Start.IsSpecified;
    hasOutputFcn=infoStruct.Fcns.Output.IsSpecified;
    hasTermFcn=infoStruct.Fcns.Terminate.IsSpecified;

    if(hasInitFcn==true)||(hasStartFcn==true)||(hasOutputFcn==true)||(hasTermFcn==true)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Register reserved identifiers to avoid name conflict \n');
        fprintf(fid,' */\n');
        fprintf(fid,'if (ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL) {\n');













        if(infoStruct.hasWrapper==true)
            if infoStruct.hasBusOrStruct==false

                fprintf(fid,'isSimulationTarget = GetRTWEnvironmentMode(S);\n');
                fprintf(fid,'   if (isSimulationTarget==-1) {\n');
                fprintf(fid,'      ssSetErrorStatus(S, "Unable to determine a valid code generation environment mode.");');
                fprintf(fid,'      return;\n');
                fprintf(fid,'   }\n');
                fprintf(fid,'   isSimulationTarget |= ssRTWGenIsModelReferenceSimTarget(S);\n');
                fprintf(fid,'\n');
            end
        end

        if hasInitFcn==true
            fprintf(fid,'/*\n');
            fprintf(fid,' * Register reserved identifier for InitializeConditionsFcnSpec\n');
            fprintf(fid,' */\n');
            fprintf(fid,...
            '  ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
            iGetFunctionName(infoStruct.Fcns.InitializeConditions));
            fprintf(fid,'\n');
        end

        if hasStartFcn==true
            fprintf(fid,'/*\n');
            fprintf(fid,' * Register reserved identifier for StartFcnSpec\n');
            fprintf(fid,' */\n');
            fprintf(fid,...
            '  ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
            iGetFunctionName(infoStruct.Fcns.Start));
            fprintf(fid,'\n');
        end

        if hasOutputFcn==true
            fprintf(fid,'/*\n');
            fprintf(fid,' * Register reserved identifier for OutputFcnSpec\n');
            fprintf(fid,' */\n');
            fprintf(fid,...
            '  ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
            iGetFunctionName(infoStruct.Fcns.Output));
            fprintf(fid,'\n');
        end

        if hasTermFcn==true
            fprintf(fid,'/*\n');
            fprintf(fid,' * Register reserved identifier for TerminateFcnSpec\n');
            fprintf(fid,' */\n');
            fprintf(fid,...
            '  ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
            iGetFunctionName(infoStruct.Fcns.Terminate));
            fprintf(fid,'\n');
        end



        if(infoStruct.hasWrapper==true||infoStruct.isCPP==true)
            fprintf(fid,'\n');
            fprintf(fid,'/*\n');
            fprintf(fid,' * Register reserved identifier for wrappers\n');
            fprintf(fid,' */\n');


            if infoStruct.hasWrapper==true


                fprintf(fid,'if (isSimulationTarget) {\n');
            else

                fprintf(fid,'if (ssRTWGenIsModelReferenceSimTarget(S)) {\n');
            end

            if hasInitFcn==true
                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for InitializeConditionsFcnSpec for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_initialize_conditions", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');
            end

            if infoStruct.DWorks.NumDWorkForBus>0


                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for allocating PWork for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_allocmem", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');

                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for freeing PWork for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_freemem", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');
            end

            if hasStartFcn==true
                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for StartFcnSpec for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_start", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');
            end

            if hasOutputFcn==true
                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for OutputFcnSpec for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_output", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');
            end

            if hasTermFcn==true
                fprintf(fid,'/*\n');
                fprintf(fid,' * Register reserved identifier for TerminateFcnSpec for SimulationTarget\n');
                fprintf(fid,' */\n');
                fprintf(fid,...
                '  ssRegMdlInfo(S, "%s_wrapper_terminate", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                infoStruct.Specs.SFunctionName);
                fprintf(fid,'\n');
            end
            fprintf(fid,'}\n');

        end
        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end

    if infoStruct.has2DMatrix

        fprintf(fid,'if (ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL) {\n');
        fType={'Input','Output','Parameter'};
        for ii=1:numel(fType)
            for jj=1:infoStruct.([fType{ii},'s']).Num
                thisData=infoStruct.([fType{ii},'s']).(fType{ii})(jj);
                if thisData.CMatrix2D.DWorkId>0


                    fprintf(fid,...
                    '  ssRegMdlInfo(S, "__%sM2D", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                    thisData.Identifier);

                    fprintf(fid,...
                    '  ssRegMdlInfo(S, "__%sBUS", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));\n',...
                    thisData.Identifier);
                end
            end
        end





        fprintf(fid,'}\n\n');
    end


    if iHasNDSignals(infoStruct)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Set the option for ND signals support.\n');
        fprintf(fid,' */\n');
        fprintf(fid,'ssAllowSignalsWithMoreThan2D(S);\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'/*\n');
    fprintf(fid,' * This S-function can be used in referenced model simulating in normal mode.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);\n');

    fprintf(fid,'/*\n');
    fprintf(fid,' * Set the number of sample time.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'ssSetNumSampleTimes(S, 1);\n');
    fprintf(fid,'\n');

    fprintf(fid,'/*\n');
    fprintf(fid,' * Set the compliance for the operating point save/restore.\n');
    fprintf(fid,' */\n');
    if infoStruct.DWorks.NumPWorks==0





        fprintf(fid,'ssSetOperatingPointCompliance(S, USE_DEFAULT_OPERATING_POINT);\n');
    else


        fprintf(fid,'ssSetOperatingPointCompliance(S, OPERATING_POINT_COMPLIANCE_UNKNOWN);\n');
    end

    fprintf(fid,'/*\n');
    fprintf(fid,' * All options have the form SS_OPTION_<name> and are documented in\n');
    fprintf(fid,' * matlabroot/simulink/include/simstruc.h. The options should be\n');
    fprintf(fid,' * bitwise or''d together as in\n');
    fprintf(fid,' *   ssSetOptions(S, (SS_OPTION_name1 | SS_OPTION_name2))\n');
    fprintf(fid,' */\n');


    h.writeSfcnSSOptions(fid,infoStruct);

    if infoStruct.canUseSFcnCGIRAPI
        fprintf(fid,'/* Generate code with S-Function Code Construction API */\n');
        fprintf(fid,' ssSetRTWCG(S, true);\n');
    end



    if(infoStruct.hasSLObject==true)
        fprintf(fid,'#if defined(MATLAB_MEX_FILE) \n');



        fprintf(fid,'if ((ssGetSimMode(S)!=SS_SIMMODE_SIZES_CALL_ONLY) && !ssRTWGenIsCodeGen(S)) {\n');



        visitedTypeId=iRegisterDataTypeIfNeeded(fid,infoStruct,visitedTypeId,'InitializeConditions');
        visitedTypeId=iRegisterDataTypeIfNeeded(fid,infoStruct,visitedTypeId,'Start');
        visitedTypeId=iRegisterDataTypeIfNeeded(fid,infoStruct,visitedTypeId,'Output');
        iRegisterDataTypeIfNeeded(fid,infoStruct,visitedTypeId,'Terminate');

        fprintf(fid,'  /* Verify Data Type consistency with specification */');
        fprintf(fid,'  CheckDataTypes(S);\n');
        fprintf(fid,'}\n');
        fprintf(fid,'#endif\n');
    end

    slVer=ver('Simulink');
    fprintf(fid,['ssSetSimulinkVersionGeneratedIn(S, "',slVer.Version,'");']);


    fprintf(fid,'}\n');
    fprintf(fid,'\n');



    function visitedTypeId=iRegisterDataTypeIfNeeded(fid,infoStruct,visitedTypeId,fcnType)


        fcnArgs=infoStruct.Fcns.(fcnType).RhsArgs;


        if fcnArgs.NumArgs==0
            return
        end

        for ii=1:fcnArgs.NumArgs

            thisArg=fcnArgs.Arg(ii);


            if~(strcmpi(thisArg.Type,'Parameter')||strcmp(thisArg.Type,'SizeArg'))
                continue
            end



            thisDataType=infoStruct.DataTypes.DataType(thisArg.DataTypeId);
            if(thisDataType.HasObject==0)||ismember(thisDataType.Id,visitedTypeId)
                continue
            end


            fprintf(fid,'{\n');
            fprintf(fid,'  DTypeId dataTypeIdReg;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
            thisDataType.DTName);
            fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
            fprintf(fid,'}\n');


            visitedTypeId(end+1)=thisDataType.Id;%#ok<AGROW>
        end



        function bool=iHasNDSignals(infoStruct)




            bool=false;


            for ii=1:infoStruct.Inputs.Num
                if length(infoStruct.Inputs.Input(ii).Dimensions)>2
                    bool=true;
                    return
                end
            end


            for ii=1:infoStruct.Outputs.Num
                if length(infoStruct.Outputs.Output(ii).Dimensions)>2
                    bool=true;
                    return
                end
            end


            function stmt=iGetInputOutputNDDimsStmtDuringInit(infoStruct,dimStr)%#ok<INUSL>



                nbDims=length(dimStr);
                stmt=sprintf('int_T dims[%d];\n dimsInfo.numDims = %d;\n',nbDims,nbDims);


                widthStr='';
                multStr='';
                for ii=1:nbDims
                    stmt=sprintf('%s dims[%d] = (int_T) %s;\n',stmt,ii-1,dimStr{ii});
                    widthStr=sprintf('%s %s dims[%d]',widthStr,multStr,ii-1);
                    multStr='*';
                end
                stmt=sprintf('%s dimsInfo.dims = &dims[0];\n',stmt);


                stmt=sprintf('%s dimsInfo.width = %s;\n',stmt,widthStr);


                function fcnName=iGetFunctionName(fcnInfo)


                    token=regexpi(fcnInfo.RhsExpression,'(\w*)\s*\(','tokens');
                    fcnName=token{1}{1};




