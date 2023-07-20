function code_interface_and_support_files(fileNameInfo,incCodeGenInfo,...
    buildInfo,modelName,targetInfo)



    CGXE.Coder.code_model_interface_header_file(fileNameInfo);
    CGXE.Coder.code_model_registry_file(fileNameInfo,incCodeGenInfo.newChecksum,modelName);
    code_rtwtypesdoth(modelName,fileNameInfo.targetDirName);

    if incCodeGenInfo.makefile
        if targetInfo.codingMSVCMakefile
            CGXE.Coder.code_msvc_make_file(buildInfo,fileNameInfo,modelName);
        elseif targetInfo.codingUnixMakefile
            CGXE.Coder.code_unix_make_file(buildInfo,fileNameInfo,modelName);
        elseif targetInfo.codingMinGWMakefile
            CGXE.Coder.code_mingw_make_file(fileNameInfo,buildInfo,...
            modelName,'cgxe',targetInfo);
        elseif~isunix&&targetInfo.codingLccMakefile
            CGXE.Coder.code_lcc_make_file(fileNameInfo,buildInfo,modelName);
        end
    end

