function writeSfcnMdlTrailer(~,fid,infoStruct)





    if strcmp(infoStruct.SampleTime,'parameterized')



        fprintf(fid,'#define MDL_RTW\n');
        fprintf(fid,'#if defined(MATLAB_MEX_FILE) && defined(MDL_RTW)\n');
        fprintf(fid,'/* Function: mdlRTW =======================================================\n');
        fprintf(fid,' * Abstract:\n');
        fprintf(fid,' *    This function is called when Simulink Coder is generating\n');
        fprintf(fid,' *    the model.rtw file.\n');
        fprintf(fid,' */\n');
        fprintf(fid,'static void mdlRTW(SimStruct *S)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'}\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    end

    if infoStruct.canUseSFcnCGIRAPI==true
        fprintf(fid,'#define MDL_RTWCG\n');
        fprintf(fid,'#if defined(MATLAB_MEX_FILE) && defined(MDL_RTWCG)\n');
        fprintf(fid,'/* Function: mdlRTWCG =====================================================\n');
        fprintf(fid,' * Abstract:\n');
        fprintf(fid,' *    This function is called when Simulink Coder is generating the model.rtw\n');
        fprintf(fid,' *    file and the S-Function uses the Code Construction API.\n');
        fprintf(fid,' */\n');
        fprintf(fid,'static void mdlRTWCG(SimStruct *S, void *rtwBlk)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'    SFun::construct_code_for_user_block<%s_Block>(S, rtwBlk);\n',infoStruct.Specs.SFunctionName);
        fprintf(fid,'}\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    end

    if strcmp(infoStruct.SampleTime,'parameterized')


        fprintf(fid,'/* Function: IsRealMatrix =================================================\n');
        fprintf(fid,' * Abstract:\n');
        fprintf(fid,' *      Verify that the mxArray is a real (double) finite matrix\n');
        fprintf(fid,' */\n');
        fprintf(fid,'bool IsRealMatrix(const mxArray *m)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'    if (mxIsNumeric(m)  &&  \n');
        fprintf(fid,'        mxIsDouble(m)   && \n');
        fprintf(fid,'        !mxIsLogical(m) &&\n');
        fprintf(fid,'        !mxIsComplex(m) &&  \n');
        fprintf(fid,'        !mxIsSparse(m)  && \n');
        fprintf(fid,'        !mxIsEmpty(m)   &&\n');
        fprintf(fid,'        mxGetNumberOfDimensions(m) == 2) {\n');
        fprintf(fid,'\n');
        fprintf(fid,'        real_T *data = mxGetPr(m);\n');
        fprintf(fid,'        mwSize  numEl = mxGetNumberOfElements(m);\n');
        fprintf(fid,'        mwSize  i;\n');
        fprintf(fid,'\n');
        fprintf(fid,'        for (i = 0; i < numEl; i++) {\n');
        fprintf(fid,'            if (!mxIsFinite(data[i])) {\n');
        fprintf(fid,'                return(false);\n');
        fprintf(fid,'            }\n');
        fprintf(fid,'        }\n');
        fprintf(fid,'\n');
        fprintf(fid,'        return(true);\n');
        fprintf(fid,'    } else {\n');
        fprintf(fid,'        return(false);\n');
        fprintf(fid,'    }\n');
        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'\n');

    if infoStruct.hasSLObject
        fprintf(fid,'  /* Function: CheckDataTypeChecksum ======================================\n');
        fprintf(fid,'   * Abstract:\n');
        fprintf(fid,'   *    CheckDataTypeChecksum invokes a MATLAB helper for checking the consistency\n');
        fprintf(fid,'   *    between the data type definition used when this S-Function was generated\n');
        fprintf(fid,'   *    and the data type used when calling the S-Function.\n');
        fprintf(fid,' */\n');
        fprintf(fid,'\n');
        fprintf(fid,'static int_T CheckDataTypeChecksum(SimStruct *S, const char* dtypeName, uint32_T* chkRef)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'  mxArray *plhs[1] = {NULL};\n');
        fprintf(fid,'  mxArray *prhs[3];\n');
        fprintf(fid,'  mxArray *err = NULL;\n');
        fprintf(fid,'  const char *bpath = ssGetPath(S);\n');
        fprintf(fid,'  int_T status = -1;\n');
        fprintf(fid,'\n');
        fprintf(fid,'  prhs[0] = mxCreateString(bpath);\n');
        fprintf(fid,'  prhs[1] = mxCreateString(dtypeName);\n');
        fprintf(fid,'  prhs[2] = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
        fprintf(fid,'  mxGetPr(prhs[2])[0] = chkRef[0];\n');
        fprintf(fid,'  mxGetPr(prhs[2])[1] = chkRef[1];\n');
        fprintf(fid,'  mxGetPr(prhs[2])[2] = chkRef[2];\n');
        fprintf(fid,'  mxGetPr(prhs[2])[3] = chkRef[3];\n');
        fprintf(fid,'\n');
        fprintf(fid,'  err = mexCallMATLABWithTrap(1, plhs, 3, prhs, "legacycode.LCT.getOrCompareDataTypeChecksum");\n');
        fprintf(fid,'  mxDestroyArray(prhs[0]);\n');
        fprintf(fid,'  mxDestroyArray(prhs[1]);\n');
        fprintf(fid,'  mxDestroyArray(prhs[2]);\n');
        fprintf(fid,'\n');
        fprintf(fid,'  if (err==NULL && plhs[0]!=NULL) {\n');
        fprintf(fid,'    status = mxIsEmpty(plhs[0]) ? -1 : (int_T) (mxGetScalar(plhs[0]) != 0);\n');
        fprintf(fid,'    mxDestroyArray(plhs[0]);\n');
        fprintf(fid,'  }\n');
        fprintf(fid,'\n');
        fprintf(fid,'  return status;\n');
        fprintf(fid,'}\n');

        fprintf(fid,'  /* Function: CheckDataTypes =============================================\n');
        fprintf(fid,'   * Abstract:\n');
        fprintf(fid,'   *    CheckDataTypes verifies data type consistency between the data type \n');
        fprintf(fid,'   *    definition used when this S-Function was generated and the data type\n');
        fprintf(fid,'   *    used when calling the S-Function.\n');
        fprintf(fid,' */\n');
        fprintf(fid,'\n');
        fprintf(fid,'static void CheckDataTypes(SimStruct *S)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'\n');



        if infoStruct.hasEnum

            for ii=(infoStruct.DataTypes.NumSLBuiltInDataTypes+1):infoStruct.DataTypes.NumDataTypes
                thisDataType=infoStruct.DataTypes.DataType(ii);
                if(thisDataType.HasObject==1)&&(thisDataType.IsEnum)&&...
                    (thisDataType.IsPartOfSpec==true)




                    if(thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1)

                        continue
                    end

                    iWriteEnumTypeCheck(fid,infoStruct.DataTypes,ii);
                end
            end
        end



        if infoStruct.hasAlias

            for ii=(infoStruct.DataTypes.NumSLBuiltInDataTypes+1):infoStruct.DataTypes.NumDataTypes
                thisDataType=infoStruct.DataTypes.DataType(ii);
                if(thisDataType.HasObject==1)&&(thisDataType.Id~=thisDataType.IdAliasedThruTo)&&...
                    (thisDataType.IdAliasedTo~=-1)&&(thisDataType.IsPartOfSpec==true)

                    iWriteDataTypeCheck(fid,infoStruct.DataTypes,ii);
                end
            end
        end



        if infoStruct.hasBusOrStruct
            for ii=1:length(infoStruct.DataTypes.BusInfo.BusDataTypesId)
                iWriteBusOrStructCheck(fid,infoStruct.DataTypes,...
                infoStruct.DataTypes.BusInfo.BusDataTypesId(ii));
            end
        end

        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end



    if infoStruct.hasWrapper
        fprintf(fid,'  /* Function: GetRTWEnvironmentMode ======================================\n');
        fprintf(fid,'   * Abstract:\n');
        fprintf(fid,'   *    Must be called when ssRTWGenIsCodeGen(S)==true. This function\n');
        fprintf(fid,'   *    returns the code generation mode:\n');
        fprintf(fid,'   *      -1 if an error occurred\n');
        fprintf(fid,'   *       0 for standalone code generation target\n');
        fprintf(fid,'   *       1 for simulation target (Accelerator, RTW-SFcn,...)\n');
        fprintf(fid,' */\n');
        fprintf(fid,'\n');
        fprintf(fid,'static int_T GetRTWEnvironmentMode(SimStruct *S)\n');
        fprintf(fid,'{\n');
        fprintf(fid,'   int_T status;\n');
        fprintf(fid,'\n');


        fprintf(fid,'   mxArray *plhs[1];\n');
        fprintf(fid,'   mxArray *prhs[1];\n');
        fprintf(fid,'   mxArray *err;\n');
        fprintf(fid,'\n');


        fprintf(fid,'   /*\n');
        fprintf(fid,'    * Get the name of the Simulink block diagram\n');
        fprintf(fid,'    */\n');
        fprintf(fid,'   prhs[0] = mxCreateString(ssGetBlockDiagramName(S));\n');
        fprintf(fid,'   plhs[0] = NULL;\n');
        fprintf(fid,'\n');



        fprintf(fid,'   /*\n');
        fprintf(fid,'    * Call "isSimulationTarget = rtwenvironmentmode(modelName)" in MATLAB\n');
        fprintf(fid,'    */\n');
        fprintf(fid,'   err = mexCallMATLABWithTrap(1, plhs, 1, prhs, "rtwenvironmentmode");\n');
        fprintf(fid,'\n');


        fprintf(fid,'   mxDestroyArray(prhs[0]);\n');
        fprintf(fid,'\n');



        fprintf(fid,'   /*\n');
        fprintf(fid,'    * Set the error status if an error occurred\n');
        fprintf(fid,'    */\n');
        fprintf(fid,'   if (err) {\n');
        fprintf(fid,'      if (plhs[0]) {\n');
        fprintf(fid,'         mxDestroyArray(plhs[0]);\n');
        fprintf(fid,'         plhs[0] = NULL;\n');
        fprintf(fid,'      }\n');
        fprintf(fid,'      ssSetErrorStatus(S, "Unknown error during call to ''rtwenvironmentmode''.");\n');
        fprintf(fid,'      return -1;\n');
        fprintf(fid,'   }\n');
        fprintf(fid,'\n');


        fprintf(fid,'   /*\n');
        fprintf(fid,'    * Get the value returned by rtwenvironmentmode(modelName)\n');
        fprintf(fid,'    */\n');
        fprintf(fid,'   if (plhs[0]) {\n');
        fprintf(fid,'      status = (int_T) (mxGetScalar(plhs[0]) != 0);\n');
        fprintf(fid,'      mxDestroyArray(plhs[0]);\n');
        fprintf(fid,'      plhs[0] = NULL;\n');
        fprintf(fid,'   }\n');
        fprintf(fid,'\n');
        fprintf(fid,'   return (status);\n');
        fprintf(fid,'}\n');
        fprintf(fid,'\n');
    end

    fprintf(fid,'/*\n');
    fprintf(fid,' * Required S-function trailer\n');
    fprintf(fid,' */\n');

    fprintf(fid,'#ifdef    MATLAB_MEX_FILE\n');
    fprintf(fid,'# include "simulink.c"\n');
    fprintf(fid,'#else\n');
    fprintf(fid,'# include "cg_sfun.h"\n');
    fprintf(fid,'#endif\n');



    function iWriteTypeChecksumCheck(fid,dtChk,dtName,dtDesc)

        fprintf(fid,'{\n');
        fprintf(fid,'  uint32_T chk[] = {');
        sep='';
        for ii=1:numel(dtChk)
            fprintf(fid,'%s%d',sep,dtChk(ii));
            sep=', ';
        end
        fprintf(fid,'};\n');
        fprintf(fid,'  int_T status;\n');
        fprintf(fid,'  status = CheckDataTypeChecksum(S, "%s", &chk[0]);\n',dtName);
        fprintf(fid,'  if (status==-1) {\n');
        fprintf(fid,['     ssSetErrorStatus(S, "Unexpected error when ',...
        'checking the validity of the %s ''%s''");\n'],dtDesc,dtName);
        fprintf(fid,'  } else if (status==0) {\n');
        fprintf(fid,['     ssSetErrorStatus(S, "The %s ''%s'' definition has changed ',...
        'since the S-Function was generated");\n'],dtDesc,dtName);
        fprintf(fid,'  }\n');
        fprintf(fid,'}\n');


        function iWriteEnumTypeCheck(fid,dataTypes,dataTypeId)


            thisDataType=dataTypes.DataType(dataTypeId);

            fprintf(fid,'  /* Verify Enumerated Type ''%s'' specification */\n',...
            dataTypes.DataType(dataTypeId).DTName);


            chk=legacycode.LCT.getOrCompareDataTypeChecksum('',thisDataType.DTName);
            if~isempty(chk)
                iWriteTypeChecksumCheck(fid,chk,thisDataType.DTName,'Enumerated type');
            end

            fprintf(fid,'\n');


            function iWriteDataTypeCheck(fid,dataTypes,dataTypeId)


                thisDataType=dataTypes.DataType(dataTypeId);
                baseDataType=dataTypes.DataType(dataTypes.DataType(dataTypeId).IdAliasedThruTo);
                baseDataType=dataTypes.DataType(baseDataType.StorageId);




                fprintf(fid,'  /* Verify AliasType/NumericType ''%s'' specification */\n',...
                thisDataType.DTName);


                chk=legacycode.LCT.getOrCompareDataTypeChecksum('',baseDataType.DTName);
                if~isempty(chk)
                    iWriteTypeChecksumCheck(fid,chk,baseDataType.DTName,'Simulink AliasType/NumericType');
                end

                fprintf(fid,'\n');


                function iWriteBusOrStructCheck(fid,dataTypes,dataTypeId)


                    thisDataType=dataTypes.DataType(dataTypeId);

                    fprintf(fid,'/* Verify Bus/StructType ''%s'', specification */\n',...
                    thisDataType.DTName);


                    chk=legacycode.LCT.getOrCompareDataTypeChecksum('',thisDataType.DTName);
                    if~isempty(chk)
                        iWriteTypeChecksumCheck(fid,chk,thisDataType.DTName,'Simulink Bus/StructType');
                    end

                    fprintf(fid,'\n');


