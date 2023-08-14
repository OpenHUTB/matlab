function dpigenerator_generateUVMPackage(dpiModuleName,CodeGenObj,NumberOfParameters)
    try

        svFile=fullfile(pwd,[dpiModuleName,'.sv']);
        genSVH=dpig.internal.GenSVCode(svFile);
        dpigenerator_disp(['Generating UVM module package ',dpigenerator_getfilelink(svFile)]);
        genSVH.appendCode('//%FL_BANNER% ');
        genSVH.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclStart',dpiModuleName));


        genSVH.appendCode(CodeGenObj.getImportCommonTypesPkg());

        genSVH.addNewLine;
        genSVH.addComment('Declare imported C functions');
        genSVH.appendCode(CodeGenObj.getImportInitializeFcn());
        genSVH.appendCode(CodeGenObj.getImportResetFcn());
        genSVH.appendCode(CodeGenObj.getImportOutputFcn());
        genSVH.appendCode(CodeGenObj.getImportUpdateFcn());
        genSVH.appendCode(CodeGenObj.getImportTerminateFcn());
        genSVH.appendCode(CodeGenObj.getImportRunTimeErrFcn());
        genSVH.appendCode(CodeGenObj.getImportStopSimFcn());
        genSVH.appendCode(CodeGenObj.getImportAccessTestPointFcn());

        for idxParam=1:NumberOfParameters
            genSVH.appendCode(CodeGenObj.getImportSetParamFcn(idxParam));
        end


        genSVH.addComment(CodeGenObj.getDPIEntryPointWrapperFcn('comment'));
        genSVH.appendCode(CodeGenObj.getDPIEntryPointWrapperFcn('definition'));

        genSVH.appendCode(CodeGenObj.getImportTSVerifyFcn());

        if hdlverifierfeature('IS_CODEGEN_FOR_UVMDUT')
            genSVH.addNewLine;
            genSVH.appendCode(CodeGenObj.getReportRunTimeErrPackageCode());
        end

        genSVH.addNewLine;
        genSVH.appendCode(CodeGenObj.getAssertionSVPackageCode());
        genSVH.addNewLine;
        genSVH.appendCode(CodeGenObj.getTSVerifyPackageCode());
        genSVH.addNewLine;
        genSVH.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclEnd',dpiModuleName));

        CodeGenObj.AddAssertionInfo();

        CodeGenObj.AddTSAssertionInfo();
    catch ME
        baseME=MException(message('HDLLink:DPIG:SVWrapperGenerationFailed'));
        newME=addCause(baseME,ME);
        throw(newME);
    end
end
