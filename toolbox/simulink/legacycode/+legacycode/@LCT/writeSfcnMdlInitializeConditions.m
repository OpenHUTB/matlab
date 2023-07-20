function writeSfcnMdlInitializeConditions(h,fid,infoStruct)






    if(infoStruct.Fcns.InitializeConditions.IsSpecified==0)
        return
    end

    fprintf(fid,'#define MDL_INITIALIZE_CONDITIONS\n');
    fprintf(fid,'#if defined(MDL_INITIALIZE_CONDITIONS)\n');
    fprintf(fid,'  /* Function: mdlInitializeConditions ======================================\n');
    fprintf(fid,'   * Abstract:\n');
    fprintf(fid,'   *    In this function, you should initialize the states for your S-function block.\n');
    fprintf(fid,'   *    You can also perform any other initialization activities that your\n');
    fprintf(fid,'   *    S-function may require. Note, this routine will be called at the\n');
    fprintf(fid,'   *    start of simulation and if it is present in an enabled subsystem\n');
    fprintf(fid,'   *    configured to reset states, it will be call when the enabled subsystem\n');
    fprintf(fid,'   *    restarts execution to reset the states.\n');
    fprintf(fid,'   */\n');
    fprintf(fid,'  static void mdlInitializeConditions(SimStruct *S)\n');
    fprintf(fid,'  {\n');


    if infoStruct.hasBusOrStruct==true
        fprintf(fid,'if (isDWorkNeeded(S)) {\n');
    end


    h.writeSfcnTempVariableForStructInfo(fid,infoStruct);


    h.writeSfcnArgumentAccess(fid,infoStruct,infoStruct.Fcns.InitializeConditions);

    fprintf(fid,'\n');


    h.writeSfcnTempVariableFor2DRowMatrix(fid,infoStruct,infoStruct.Fcns.InitializeConditions);


    h.writeSfcnTempVariableForUserStruct(fid,infoStruct,infoStruct.Fcns.InitializeConditions);


    h.writeSfcnSLStructToUserStruct(fid,infoStruct,infoStruct.Fcns.InitializeConditions);


    h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.InitializeConditions,true);


    fprintf(fid,'/*\n');
    fprintf(fid,' * Call the legacy code function\n');
    fprintf(fid,' */\n');
    fprintf(fid,'%s;\n',h.generateSfcnFcnCallString(infoStruct,infoStruct.Fcns.InitializeConditions));
    fprintf(fid,'\n');


    h.writeSfcn2DMatrixConversion(fid,infoStruct,infoStruct.Fcns.InitializeConditions,false);


    h.writeSfcnUserStructToSLStruct(fid,infoStruct,infoStruct.Fcns.InitializeConditions);


    h.writeSfcnPWorkUpdate(fid,infoStruct,infoStruct.Fcns.InitializeConditions);


    if infoStruct.hasBusOrStruct==true

        fprintf(fid,'}\n');
    end

    fprintf(fid,'  }\n');
    fprintf(fid,'#endif\n');

    fprintf(fid,'\n');


