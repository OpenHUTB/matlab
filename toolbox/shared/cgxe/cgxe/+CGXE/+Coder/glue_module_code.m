function file=glue_module_code(md5ChecksumStr,file,fallbackInfo,modelName)



    moduleUniqName=md5ChecksumStr;
    instanceTypedef=['InstanceStruct_',md5ChecksumStr];

    moduleFcnNames=cgxe('module_fcn_names',modelName);
    simStateCompliance=cgxe('getSimStateCompliance',modelName);

    fprintf(file,'/* CGXE Glue Code */\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlOutputs_%s(SimStruct *S, int_T tid)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
    fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.output);
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlInitialize_%s(SimStruct *S)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
    fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.init);
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlUpdate_%s(SimStruct *S, int_T tid)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
    fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.update);
    fprintf(file,'}\n');
    fprintf(file,'\n');
    if isequal(simStateCompliance,'SimStateCompliant')
        fprintf(file,'static mxArray* getSimState_%s(SimStruct *S)\n',moduleUniqName);
        fprintf(file,'{\n');
        fprintf(file,'    mxArray* mxSS;\n');
        fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
        fprintf(file,'    mxSS = (mxArray *) %s(moduleInstance);\n',moduleFcnNames.getSS);
        fprintf(file,'    return mxSS;\n');
        fprintf(file,'}\n');
        fprintf(file,'\n');
        fprintf(file,'\n');
        fprintf(file,'static void setSimState_%s(SimStruct *S, const mxArray *ss)\n',moduleUniqName);
        fprintf(file,'{\n');
        fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
        fprintf(file,'    %s(moduleInstance, emlrtAlias(ss));\n',moduleFcnNames.setSS);
        fprintf(file,'}\n');
    end
    fprintf(file,'\n');
    fprintf(file,'static void mdlTerminate_%s(SimStruct *S)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
    fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.term);
    fprintf(file,'\n');
    fprintf(file,'    free((void *)moduleInstance);\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    if~isempty(moduleFcnNames.enable)
        fprintf(file,'static void mdlEnable_%s(SimStruct *S)\n',moduleUniqName);
        fprintf(file,'{\n');
        fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
        fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.enable);
        fprintf(file,'}\n');
    end
    fprintf(file,'\n');
    if~isempty(moduleFcnNames.disable)
        fprintf(file,'static void mdlDisable_%s(SimStruct *S)\n',moduleUniqName);
        fprintf(file,'{\n');
        fprintf(file,'    %s *moduleInstance = (%s *)cgxertGetRuntimeInstance(S);\n',instanceTypedef,instanceTypedef);
        fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.disable);
        fprintf(file,'}\n');
    end
    fprintf(file,'\n');
    fprintf(file,'static void mdlStart_%s(SimStruct *S)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    %s *moduleInstance = (%s *)calloc(1, sizeof(%s));\n',instanceTypedef,instanceTypedef,instanceTypedef);



    fprintf(file,'    moduleInstance->S = S;\n');
    fprintf(file,'    cgxertSetRuntimeInstance(S, (void *)moduleInstance);\n');
    fprintf(file,'\n');
    fprintf(file,'    ssSetmdlOutputs(S, mdlOutputs_%s);\n',moduleUniqName);
    fprintf(file,'    ssSetmdlInitializeConditions(S, mdlInitialize_%s);\n',moduleUniqName);
    fprintf(file,'    ssSetmdlUpdate(S, mdlUpdate_%s);\n',moduleUniqName);
    fprintf(file,'    ssSetmdlTerminate(S, mdlTerminate_%s);\n',moduleUniqName);
    if~isempty(moduleFcnNames.enable)
        fprintf(file,'    ssSetmdlEnable(S, mdlEnable_%s);\n',moduleUniqName);
    end
    if~isempty(moduleFcnNames.disable)
        fprintf(file,'    ssSetmdlDisable(S, mdlDisable_%s);\n',moduleUniqName);
    end


    fprintf(file,'\n');
    fprintf(file,'    %s(moduleInstance);\n',moduleFcnNames.start);
    fprintf(file,'\n');
    fprintf(file,'    {\n');
    fprintf(file,'        uint_T options = ssGetOptions(S);\n');
    fprintf(file,'        options |= SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE;\n');
    fprintf(file,'        ssSetOptions(S, options);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlProcessParameters_%s(SimStruct *S)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'void method_dispatcher_%s(SimStruct *S, int_T method, void *data)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'  switch (method) {\n');
    fprintf(file,'  case SS_CALL_MDL_START:\n');
    fprintf(file,'    mdlStart_%s(S);\n',moduleUniqName);
    fprintf(file,'    break;\n');
    fprintf(file,'  case SS_CALL_MDL_PROCESS_PARAMETERS:\n');
    fprintf(file,'    mdlProcessParameters_%s(S);\n',moduleUniqName);
    fprintf(file,'    break;\n');
    if isequal(simStateCompliance,'SimStateCompliant')
        fprintf(file,'  case SS_CALL_MDL_GET_SIM_STATE:\n');
        fprintf(file,'    *((mxArray**) data) = getSimState_%s(S);\n',moduleUniqName);
        fprintf(file,'    break;\n');
        fprintf(file,'  case SS_CALL_MDL_SET_SIM_STATE:\n');
        fprintf(file,'    setSimState_%s(S, (const mxArray *) data);\n',moduleUniqName);
        fprintf(file,'    break;\n');
    end
    fprintf(file,'  default:\n');
    fprintf(file,'    /* Unhandled method */\n');
    fprintf(file,'    /*\n');
    fprintf(file,'    sf_mex_error_message("Stateflow Internal Error:\\n"\n');
    fprintf(file,'                         "Error calling method dispatcher for module: %s.\\n"\n',moduleUniqName);
    fprintf(file,'                         "Can''t handle method %%d.\\n", method);\n');
    fprintf(file,'    */\n');
    fprintf(file,'    break;\n');
    fprintf(file,'  }\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'mxArray *cgxe_%s_BuildInfoUpdate(void)\n',moduleUniqName);
    fprintf(file,'{\n');
    updateBuildInfoArgs=cgxe('BuildInfoUpdate',modelName);
    numTp=length(updateBuildInfoArgs);
    if numTp>0
        [~,file]=createMexCommandsForCell(updateBuildInfoArgs,file,'mxBIArgs');
    else
        fprintf(file,'   mxArray *mxBIArgs = mxCreateCellMatrix(1,0);   \n');
    end
    fprintf(file,'   return mxBIArgs;\n');
    fprintf(file,'}\n');

    fprintf(file,'mxArray *cgxe_%s_fallback_info(void)\n',moduleUniqName);
    fprintf(file,'{\n');
    fprintf(file,'    const char* fallbackInfoFields[] = {"fallbackType", "incompatiableSymbol"};\n');
    fprintf(file,'    mxArray* fallbackInfoStruct = mxCreateStructMatrix(1, 1, 2, fallbackInfoFields);\n');
    fprintf(file,'    mxArray* fallbackType = mxCreateString("%s");\n',fallbackInfo.fallbackType);
    fprintf(file,'    mxArray* incompatibleSymbol = mxCreateString("%s");\n',fallbackInfo.incompatibleSymbol);
    fprintf(file,'    mxSetFieldByNumber(fallbackInfoStruct, 0, 0, fallbackType);\n');
    fprintf(file,'    mxSetFieldByNumber(fallbackInfoStruct, 0, 1, incompatibleSymbol);\n');
    fprintf(file,'    return fallbackInfoStruct;\n');
    fprintf(file,'}\n');

    function[uniqNum,file]=createMexCommandsForCell(c,file,cName,uniqNum)


        if nargin<4
            uniqNum=0;
            fprintf(file,'mxArray * %s; \n',cName);
            [numMxElem,hasNumeric,hasLogical]=cellMxNumel(c);
            for iMx=1:numMxElem
                fprintf(file,'mxArray * elem_%.17g;   \n',iMx);
            end
            if hasNumeric
                fprintf(file,'double * pointer;\n');
            end
            if hasLogical
                fprintf(file,'mxLogical *  getLogical;   \n');
            end
        end
        [row,col]=size(c);
        fprintf(file,'%s = mxCreateCellMatrix(%.17g,%.17g);\n',cName,row,col);
        uniqNum=uniqNum+1;
        for i=1:numel(c)
            subVar=['elem_',num2str(uniqNum)];
            if isnumeric(c{i})
                assert(isa(c{i},'double'));
                fprintf(file,'%s = mxCreateDoubleMatrix(%.17g,%.17g, mxREAL);\n',subVar,size(c{i},1),size(c{i},2));
                fprintf(file,'pointer = mxGetPr(%s);\n',subVar);
                for index=1:numel(c{i})
                    fprintf(file,'pointer[%.17g] = %.17g;\n',index-1,c{i}(index));
                end
            elseif ischar(c{i})
                strValue=strip(c{i},'"');
                strValue=strrep(strValue,'\','\\');
                fprintf(file,'%s = mxCreateString("%s");\n',subVar,strValue);
            elseif islogical(c{i})
                fprintf(file,'%s = mxCreateLogicalMatrix(%.17g,%.17g);\n',subVar,size(c{i},1),size(c{i},2));
                fprintf(file,'getLogical = mxGetLogicals(%s);   \n',subVar);
                for index=1:numel(c{i})
                    fprintf(file,'getLogical[%.17g] = %.17g;\n',index-1,c{i}(index));
                end
            else
                assert(iscell(c{i}));
            end
            if iscell(c{i})
                [uniqNum,file]=createMexCommandsForCell(c{i},file,subVar,uniqNum);
            else
                uniqNum=uniqNum+1;
            end
            fprintf(file,'mxSetCell(%s,%.17g,%s);\n',cName,i-1,subVar);
        end

        function[y,hasNumeric,hasLogical]=cellMxNumel(c)

            y=numel(c);
            hasNumeric=any(cellfun(@isnumeric,c));
            hasLogical=any(cellfun(@islogical,c));

            for i=1:numel(c)
                if iscell(c{i})
                    [yTemp,hasNumericTemp,hasLogicalTemp]=cellMxNumel(c{i});
                    y=y+yTemp;
                    hasNumeric=hasNumeric||hasNumericTemp;
                    hasLogical=hasLogical||hasLogicalTemp;
                end
            end
