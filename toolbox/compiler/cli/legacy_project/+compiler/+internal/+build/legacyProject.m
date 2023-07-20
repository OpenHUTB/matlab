function buildOutput=legacyProject(prjFile)

    if~exist(prjFile,'file')
        error(message('Compiler:build:compatibility:projectDoesNotExist',prjFile))
    end

    try
        prjStruct=compiler.internal.readPRJStruct(prjFile);


        if prjStruct.param_user_defined_mcr_options.strlength>0&&...
            ~strcmp(prjStruct.param_user_defined_mcr_options,"-C")
            warning(message('Compiler:build:compatibility:mccFlagsNotSupported'))
        end

        target=prjStruct.param_target_type;



    catch E


        error(message('Compiler:build:compatibility:notCompatibilityPRJ',prjFile))
    end



    if isfield(prjStruct,"fileset_main")&&~isstruct(prjStruct.fileset_main)
        error(message('Compiler:build:compatibility:noMainFileSelected'))
    end
    if isfield(prjStruct,"fileset_web_main")&&~isstruct(prjStruct.fileset_web_main)
        error(message('Compiler:build:compatibility:noMainFileSelected'))
    end
    if isfield(prjStruct,"fileset_exports")&&~isstruct(prjStruct.fileset_exports)
        error(message('Compiler:build:compatibility:noExportedFunctionsSelected'))
    end

    switch target

    case "subtarget.web.app"
        buildOutput=compiler.internal.build.buildWebAppPRJ(prjStruct);
    case "subtarget.standalone"
        buildOutput=compiler.internal.build.buildStandalonePRJ(prjStruct);
    case "subtarget.ex.addin"
        if~ispc
            error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
        end
        buildOutput=compiler.internal.build.buildExcelPRJ(prjStruct);
    otherwise




        if~license('test','matlab_builder_for_java')
            error(message('Compiler:build:compatibility:sdkNotAvailable',prjFile))
        end

        switch target
        case "subtarget.mads"
            buildOutput=compiler.internal.build.buildMPSPRJ(prjStruct);
        case "subtarget.mps.excel"
            if~ispc
                error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
            end
            buildOutput=compiler.internal.build.buildMPSExcelPRJ(prjStruct);
        case "subtarget.library.c"
            buildOutput=compiler.internal.build.buildCPRJ(prjStruct);
        case "subtarget.library.cpp"
            buildOutput=compiler.internal.build.buildCPPPRJ(prjStruct);
        case "subtarget.java.package"
            buildOutput=compiler.internal.build.buildJavaPRJ(prjStruct);
        case "subtarget.python.module"
            buildOutput=compiler.internal.build.buildPythonPRJ(prjStruct);
        case "subtarget.net.component"
            if~ispc
                error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
            end
            buildOutput=compiler.internal.build.buildDotNetPRJ(prjStruct);
        case "subtarget.com.component"
            if~ispc
                error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
            end
            buildOutput=compiler.internal.build.buildCOMPRJ(prjStruct);
        case "subtarget.hadoop"
            error(message('Compiler:build:compatibility:hadoopNotSupported'))
        otherwise


            error(message('Compiler:build:compatibility:notCompatibilityPRJ',prjFile))
        end
    end


    disp(message('Compiler:build:compatibility:buildComplete').getString)

end
