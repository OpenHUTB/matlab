function writeSfcnMdlWorkWidths(h,fid,infoStruct)






    if(infoStruct.Parameters.Num==0)&&(infoStruct.DynamicSizeInfo.DWorkHasDynSize==false)&&...
        (infoStruct.DWorks.NumDWorkFor2DMatrix==0)&&...
        (infoStruct.hasBusOrStruct==0)&&(infoStruct.Specs.Options.supportsMultipleExecInstances==0)
        return
    end

    fprintf(fid,'#define MDL_SET_WORK_WIDTHS\n');
    fprintf(fid,'#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)\n');
    fprintf(fid,'/* Function: mdlSetWorkWidths =============================================\n');
    fprintf(fid,' * Abstract:\n');
    fprintf(fid,' *      The optional method, mdlSetWorkWidths is called after input port\n');
    fprintf(fid,' *      width, output port width, and sample times of the S-function have\n');
    fprintf(fid,' *      been determined to set any state and work vector sizes which are\n');
    fprintf(fid,' *      a function of the input, output, and/or sample times. \n');
    fprintf(fid,' *\n');
    fprintf(fid,' *      Run-time parameters are registered in this method using methods \n');
    fprintf(fid,' *      ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'static void mdlSetWorkWidths(SimStruct *S)\n');
    fprintf(fid,'{\n');

    if infoStruct.Specs.Options.supportsMultipleExecInstances
        fprintf(fid,'#if defined(ssSupportsMultipleExecInstances)\n');
        fprintf(fid,'ssSupportsMultipleExecInstances(S, 1);\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    end

    if(infoStruct.Parameters.Num~=0)
        fprintf(fid,'/* Set number of run-time parameters */\n');
        fprintf(fid,'if (!ssSetNumRunTimeParams(S, %d)) return;\n',infoStruct.Parameters.Num);
        fprintf(fid,'\n');
    end

    for ii=1:infoStruct.Parameters.Num
        thisParam=infoStruct.Parameters.Parameter(ii);

        fprintf(fid,'/*\n');
        fprintf(fid,' * Register the run-time parameter %d\n',ii);
        fprintf(fid,' */\n');

        thisDataType=infoStruct.DataTypes.DataType(thisParam.DataTypeId);
        if(thisDataType.HasObject==1)
            fprintf(fid,'{\n');
            fprintf(fid,'  DTypeId dataTypeIdReg;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);\n',...
            thisDataType.DTName);
            fprintf(fid,'  if(dataTypeIdReg == INVALID_DTYPE_ID) return;\n');
            fprintf(fid,'\n');
            fprintf(fid,'  ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", dataTypeIdReg);\n',...
            ii-1,ii-1,ii);
            fprintf(fid,'}\n');
        else
            fprintf(fid,'ssRegDlgParamAsRunTimeParam(S, %d, %d, "p%d", ssGetDataTypeId(S, "%s"));\n',...
            ii-1,ii-1,ii,thisDataType.DTName);
        end
        fprintf(fid,'\n');
    end



    for ii=1:length(infoStruct.DynamicSizeInfo.DWorkDynSize)
        thisDynSize=infoStruct.DynamicSizeInfo.DWorkDynSize{ii};



        if any(thisDynSize==true)

            str=h.generateSfcnDataDimStr(infoStruct,'DWork',ii,'DYNAMICALLY_SIZED');
            nbDims=length(str);

            fprintf(fid,'/* Set DWork width */\n');

            if nbDims>1
                fprintf(fid,'{\n');
                fprintf(fid,'  int_T dims[%d];\n',nbDims);
                fprintf(fid,'\n');


                width='';
                mult='';
                for jj=1:length(str)
                    fprintf(fid,'dims[%d] = %s;\n',jj-1,str{jj});
                    width=sprintf('%s %s dims[%d]',width,mult,jj-1);
                    mult='*';
                end
                fprintf(fid,'\n');
                fprintf(fid,'  ssSetDWorkWidth(S, %d, %s);\n',ii-1,width);
                fprintf(fid,'}\n');

            else
                fprintf(fid,'ssSetDWorkWidth(S, %d, (int_T) %s);\n',ii-1,str{1});
            end

            fprintf(fid,'\n');
        end
    end

    if infoStruct.DWorks.NumDWorkFor2DMatrix>0
        fprintf(fid,'/* Set the width of DWork(s) used for marshalling the 2D Row Major IOs */\n\n');
        for ii=1:infoStruct.DWorks.NumDWorkFor2DMatrix
            thisDWork=infoStruct.DWorks.DWorkFor2DMatrix(ii);
            thisDWorkNumber=infoStruct.DWorks.NumDWorks+ii-1;

            switch thisDWork.CMatrix2D.Type
            case 'Input'
                str=sprintf('ssGetInputPortWidth(S, %d)',thisDWork.CMatrix2D.DataId-1);

            case 'Output'
                str=sprintf('ssGetOutputPortWidth(S, %d)',thisDWork.CMatrix2D.DataId-1);

            case 'Parameter'
                str=sprintf('mxGetNumberOfElements(ssGetSFcnParam(S, %d))',thisDWork.CMatrix2D.DataId-1);

            otherwise

            end

            fprintf(fid,'/* Update dwork %d (%sM2D) */\n',thisDWorkNumber+1,thisDWork.Identifier);
            fprintf(fid,'ssSetDWorkWidth(S, %d, %s);\n',thisDWorkNumber,str);
            fprintf(fid,'\n');
        end
    end

    fprintf(fid,'}\n');
    fprintf(fid,'#endif \n');
    fprintf(fid,'\n');


