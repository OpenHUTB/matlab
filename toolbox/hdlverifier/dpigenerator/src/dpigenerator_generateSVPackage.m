function dpigenerator_generateSVPackage(dpiModuleName,CodeGenObj,NumberOfParameters)
    try

        svFile=fullfile(pwd,[dpiModuleName,'.sv']);
        genSVH=dpig.internal.GenSVCode(svFile);
        dpigenerator_disp(['Generating SystemVerilog module package ',dpigenerator_getfilelink(svFile)]);
        genSVH.addGeneratedBy('// ');
        genSVH.appendCode('`timescale 1ns / 1ns');
        genSVH.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclStart',dpiModuleName));
        genSVH.addNewLine;
        genSVH.appendCode(CodeGenObj.getEnumDeclarations());
        genSVH.appendCode(CodeGenObj.getSVPortStructDef());
        genSVH.addComment('Declare imported C functions');
        genSVH.appendCode(CodeGenObj.getImportInitializeFcn());
        genSVH.appendCode(CodeGenObj.getImportResetFcn());
        genSVH.appendCode(CodeGenObj.getImportOutputFcn());
        genSVH.appendCode(CodeGenObj.getImportUpdateFcn());
        genSVH.appendCode(CodeGenObj.getImportAccessTestPointFcn());
        genSVH.appendCode(CodeGenObj.getImportTerminateFcn());

        if~isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')
            genSVH.appendCode(CodeGenObj.getImportRunTimeErrFcn());
        end

        for idxParam=1:NumberOfParameters
            genSVH.addNewLine
            genSVH.appendCode(CodeGenObj.getImportSetParamFcn(idxParam));
            SVNativePrmStruct_def=CodeGenObj.getSVNativePrmStructFcn(idxParam,'definition');
            if~isempty(SVNativePrmStruct_def)

                genSVH.addNewLine
                genSVH.addComment(CodeGenObj.getSVNativePrmStructFcn(idxParam,'comment'));
                genSVH.appendCode(SVNativePrmStruct_def);
                genSVH.addNewLine
            end
        end



        genSVH.addComment(CodeGenObj.getDPIEntryPointWrapperFcn('comment'));
        genSVH.appendCode(CodeGenObj.getDPIEntryPointWrapperFcn('definition'));


        genSVH.appendCode(CodeGenObj.getImportTSVerifyFcn());

        if~isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')

            genSVH.addNewLine;
            genSVH.appendCode(CodeGenObj.getReportRunTimeErrPackageCode());
        end

        genSVH.addNewLine;
        genSVH.appendCode(CodeGenObj.getAssertionSVPackageCode());
        genSVH.addNewLine;
        genSVH.appendCode(CodeGenObj.getTSVerifyPackageCode());
        genSVH.addNewLine;
        genSVH.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclEnd',dpiModuleName));
    catch ME
        baseME=MException(message('HDLLink:DPIG:SVWrapperGenerationFailed'));
        newME=addCause(baseME,ME);
        throw(newME);
    end
end
