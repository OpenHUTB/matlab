function code_model_registry_file(fileNameInfo,checksums,modelName)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.modelRegistryFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    fprintf(file,'#define S_FUNCTION_LEVEL 2\n');
    fprintf(file,'#define S_FUNCTION_NAME %s\n',fileNameInfo.mexFunctionName);
    fprintf(file,'#include "simstruc.h"\n');
    fprintf(file,'\n');
    fprintf(file,'#include "%s"\n',fileNameInfo.modelHeaderFile);
    fprintf(file,'\n');
    fprintf(file,'#define MDL_START\n');
    fprintf(file,'static void mdlStart(SimStruct* S)\n');
    fprintf(file,'{\n');
    fprintf(file,'    unsigned int success;\n');
    fprintf(file,'    success = cgxe_%s_method_dispatcher(S, SS_CALL_MDL_START, NULL);\n',modelName);
    fprintf(file,'    if (!success) {\n');
    fprintf(file,'        /* error */\n');
    fprintf(file,'        mexPrintf("ERROR: Failed to dispatch s-function method!\\n");\n');
    fprintf(file,'    }\n');





    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'#define MDL_INITIALIZE_CONDITIONS\n');
    fprintf(file,'static void mdlInitializeConditions(SimStruct *S)\n');
    fprintf(file,'{\n');
    fprintf(file,'    mexPrintf("ERROR: Calling model mdlInitializeConditions method directly.\\n");\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'#define MDL_UPDATE\n');
    fprintf(file,'static void mdlUpdate(SimStruct *S, int_T tid)\n');
    fprintf(file,'{\n');
    fprintf(file,'    mexPrintf("ERROR: Calling model mdlUpdate method directly.\\n");\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlOutputs(SimStruct* S, int_T tid)\n');
    fprintf(file,'{\n');
    fprintf(file,'    mexPrintf("ERROR: Calling model mdlOutputs method directly.\\n");\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlTerminate(SimStruct *S)\n');
    fprintf(file,'{\n');
    fprintf(file,'    mexPrintf("ERROR: Calling model mdlTerminate method directly.\\n");\n');




    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlInitializeSizes(SimStruct *S)\n');
    fprintf(file,'{\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static void mdlInitializeSampleTimes(SimStruct *S)\n');
    fprintf(file,'{\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static mxArray* cgxe_get_supported_modules(void)\n');
    fprintf(file,'{\n');
    fprintf(file,'    mxArray* mxModules = mxCreateCellMatrix(%.17g, 1);\n',fileNameInfo.numModules);
    fprintf(file,'    mxArray* mxChksum = NULL;\n');
    fprintf(file,'    uint32_T* checksumData = NULL;\n');
    fprintf(file,'\n');

    for i=1:fileNameInfo.numModules
        thisModuleChksum=fileNameInfo.moduleInfo(i).checksums;

        fprintf(file,'    mxChksum = mxCreateNumericMatrix(1, 4, mxUINT32_CLASS, mxREAL);\n');
        fprintf(file,'    checksumData = (uint32_T*) mxGetData(mxChksum);\n');
        fprintf(file,'    checksumData[0] = %.17g;\n',thisModuleChksum(1));
        fprintf(file,'    checksumData[1] = %.17g;\n',thisModuleChksum(2));
        fprintf(file,'    checksumData[2] = %.17g;\n',thisModuleChksum(3));
        fprintf(file,'    checksumData[3] = %.17g;\n',thisModuleChksum(4));
        fprintf(file,'    mxSetCell(mxModules, %.17g, mxChksum);\n',(i-1));

    end

    fprintf(file,'\n');
    fprintf(file,'    return mxModules;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static int cgxe_process_get_checksums(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])\n');
    fprintf(file,'{\n');
    fprintf(file,'    const char* checksumFields[] = {"modules", "model", "makefile", "target", "overall"};\n');
    fprintf(file,'    mxArray* mxChecksum = mxCreateStructMatrix(1, 1, 5, checksumFields);\n');
    fprintf(file,'\n');
    fprintf(file,'    mxSetField(mxChecksum, 0, "modules", cgxe_get_supported_modules());\n');
    fprintf(file,'\n');
    fprintf(file,'    {\n');
    fprintf(file,'        mxArray* mxModelChksum = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
    fprintf(file,'        double* checksumData = (double*) mxGetData(mxModelChksum);\n');
    fprintf(file,'        checksumData[0] = %.17g;\n',checksums.model(1));
    fprintf(file,'        checksumData[1] = %.17g;\n',checksums.model(2));
    fprintf(file,'        checksumData[2] = %.17g;\n',checksums.model(3));
    fprintf(file,'        checksumData[3] = %.17g;\n',checksums.model(4));
    fprintf(file,'        mxSetField(mxChecksum, 0, "model", mxModelChksum);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    {\n');
    fprintf(file,'        mxArray* mxMakefileChksum = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
    fprintf(file,'        double* checksumData = (double*) mxGetData(mxMakefileChksum);\n');
    fprintf(file,'        checksumData[0] = %.17g;\n',checksums.makefile(1));
    fprintf(file,'        checksumData[1] = %.17g;\n',checksums.makefile(2));
    fprintf(file,'        checksumData[2] = %.17g;\n',checksums.makefile(3));
    fprintf(file,'        checksumData[3] = %.17g;\n',checksums.makefile(4));
    fprintf(file,'        mxSetField(mxChecksum, 0, "makefile", mxMakefileChksum);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    {\n');
    fprintf(file,'        mxArray* mxTargetChksum = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
    fprintf(file,'        double* checksumData = (double*) mxGetData(mxTargetChksum);\n');
    fprintf(file,'        checksumData[0] = %.17g;\n',checksums.target(1));
    fprintf(file,'        checksumData[1] = %.17g;\n',checksums.target(2));
    fprintf(file,'        checksumData[2] = %.17g;\n',checksums.target(3));
    fprintf(file,'        checksumData[3] = %.17g;\n',checksums.target(4));
    fprintf(file,'        mxSetField(mxChecksum, 0, "target", mxTargetChksum);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    {\n');
    fprintf(file,'        mxArray* mxOverallChksum = mxCreateDoubleMatrix(1, 4, mxREAL);\n');
    fprintf(file,'        double* checksumData = (double*) mxGetData(mxOverallChksum);\n');
    fprintf(file,'        checksumData[0] = %.17g;\n',checksums.overall(1));
    fprintf(file,'        checksumData[1] = %.17g;\n',checksums.overall(2));
    fprintf(file,'        checksumData[2] = %.17g;\n',checksums.overall(3));
    fprintf(file,'        checksumData[3] = %.17g;\n',checksums.overall(4));
    fprintf(file,'        mxSetField(mxChecksum, 0, "overall", mxOverallChksum);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    plhs[0] = mxChecksum;\n');
    fprintf(file,'    return 1;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static int cgxe_mex_unlock_call(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) \n');
    fprintf(file,'{\n');
    fprintf(file,'    while (mexIsLocked()) {\n');
    fprintf(file,'        mexUnlock();\n');
    fprintf(file,'    }\n');
    fprintf(file,'    return 1;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'\n');
    fprintf(file,'static SimStruct* cgxe_unpack_simstruct(const mxArray *mxS)\n');
    fprintf(file,'{\n');
    fprintf(file,'    uint32_T *uintPtr = (uint32_T*)malloc(sizeof(SimStruct*));\n');
    fprintf(file,'    int nEl = sizeof(SimStruct*)/sizeof(uint32_T);\n');
    fprintf(file,'    uint32_T *uintDataPtr = (uint32_T *)mxGetData(mxS);\n');
    fprintf(file,'    int el;\n');
    fprintf(file,'    SimStruct *S;\n');
    fprintf(file,'    for (el=0; el < nEl; el++) {\n');
    fprintf(file,'     uintPtr[el] = uintDataPtr[el];\n');
    fprintf(file,'    }\n');
    fprintf(file,'    memcpy(&S,uintPtr,sizeof(SimStruct*));\n');
    fprintf(file,'    free(uintPtr);\n');
    fprintf(file,'    return S;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static int cgxe_get_sim_state(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) \n');
    fprintf(file,'{\n');
    fprintf(file,'    unsigned int success;\n');
    fprintf(file,'    SimStruct *S = cgxe_unpack_simstruct(prhs[1]);\n');
    fprintf(file,'    success = cgxe_%s_method_dispatcher(S, SS_CALL_MDL_GET_SIM_STATE, (void *) (plhs));\n',modelName);
    fprintf(file,'    if (!success) {\n');
    fprintf(file,'        /* error */\n');
    fprintf(file,'        mexPrintf("ERROR: Failed to dispatch s-function method!\\n");\n');
    fprintf(file,'    }\n');
    fprintf(file,'    return 1;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'\n');
    fprintf(file,'static int cgxe_set_sim_state(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) \n');
    fprintf(file,'{\n');
    fprintf(file,'    unsigned int success;\n');
    fprintf(file,'    SimStruct *S = cgxe_unpack_simstruct(prhs[1]);\n');
    fprintf(file,'    success = cgxe_%s_method_dispatcher(S, SS_CALL_MDL_SET_SIM_STATE, (void *) prhs[2]);\n',modelName);
    fprintf(file,'    if (!success) {\n');
    fprintf(file,'        /* error */\n');
    fprintf(file,'        mexPrintf("ERROR: Failed to dispatch s-function method!\\n");\n');
    fprintf(file,'    }\n');
    fprintf(file,'    return 1;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'static int cgxe_get_BuildInfoUpdate(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) \n');
    fprintf(file,'{\n');

    fprintf(file,' char tpChksum[64];\n');
    fprintf(file,'	mxGetString(prhs[1], tpChksum,sizeof(tpChksum)/sizeof(char));\n');
    fprintf(file,'	tpChksum[(sizeof(tpChksum)/sizeof(char)-1)] = ''\\0'';\n');
    for i=1:length(fileNameInfo.moduleChksumStrings)
        fprintf(file,'     if (strcmp(tpChksum, "%s") == 0) {\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'         extern mxArray *cgxe_%s_BuildInfoUpdate(void);\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'			plhs[0] = cgxe_%s_BuildInfoUpdate();\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'         return 1;\n');
        fprintf(file,'     }\n');
    end
    fprintf(file,'    return 0;\n');
    fprintf(file,'}\n');

    fprintf(file,'static int cgxe_get_fallback_info(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[]) \n');
    fprintf(file,'{\n');

    fprintf(file,' char tpChksum[64];\n');
    fprintf(file,'	mxGetString(prhs[1], tpChksum,sizeof(tpChksum)/sizeof(char));\n');
    fprintf(file,'	tpChksum[(sizeof(tpChksum)/sizeof(char)-1)] = ''\\0'';\n');
    for i=1:length(fileNameInfo.moduleChksumStrings)
        fprintf(file,'     if (strcmp(tpChksum, "%s") == 0) {\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'         extern mxArray *cgxe_%s_fallback_info(void);\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'			plhs[0] = cgxe_%s_fallback_info();\n',fileNameInfo.moduleChksumStrings{i});
        fprintf(file,'         return 1;\n');
        fprintf(file,'     }\n');
    end
    fprintf(file,'    return 0;\n');
    fprintf(file,'}\n');

    fprintf(file,'\n');
    fprintf(file,'#define PROCESS_MEX_SFUNCTION_CMD_LINE_CALL\n');
    fprintf(file,'\n');
    fprintf(file,'static int ProcessMexSfunctionCmdLineCall(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])\n');
    fprintf(file,'{\n');
    fprintf(file,'    char commandName[64];\n');
    fprintf(file,'\n');
    fprintf(file,'    if (nrhs < 1 || !mxIsChar(prhs[0])) return 0;\n');
    fprintf(file,'    mxGetString(prhs[0], commandName, sizeof(commandName)/sizeof(char));\n');
    fprintf(file,'    commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "get_checksums") == 0) {\n');
    fprintf(file,'        return cgxe_process_get_checksums(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "mex_unlock") == 0) {\n');
    fprintf(file,'        return cgxe_mex_unlock_call(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "get_sim_state") == 0) {\n');
    fprintf(file,'        return cgxe_get_sim_state(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'     }\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "set_sim_state") == 0) {\n');
    fprintf(file,'        return cgxe_set_sim_state(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "get_BuildInfoUpdate") == 0) {\n');
    fprintf(file,'        return cgxe_get_BuildInfoUpdate(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    if (strcmp(commandName, "get_fallback_info") == 0) {\n');
    fprintf(file,'        return cgxe_get_fallback_info(nlhs, plhs, nrhs, prhs);\n');
    fprintf(file,'    }\n');
    fprintf(file,'\n');
    fprintf(file,'    return 0;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fprintf(file,'#include "simulink.c"\n');
    fprintf(file,'\n');

    fclose(file);
    try_indenting_file(fileName);
