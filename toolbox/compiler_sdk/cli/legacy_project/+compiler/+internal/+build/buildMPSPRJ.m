function buildOutput=buildMPSPRJ(prjStruct)

    options=compiler.build.ProductionServerArchiveOptions(...
    prjStruct.fileset_exports.file);


    if isfield(prjStruct,"param_discovery_file")...
        &&~strcmp(prjStruct.param_discovery_file,"")
        options.FunctionSignatures=prjStruct.param_discovery_file;
    end

    options.ArchiveName=prjStruct.param_appname;

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);


    if strcmp(prjStruct.param_target_type,"subtarget.mps.excel")
        options.OutputDir=fullfile(options.OutputDir,"server");
    end
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.productionServerArchive(options);

end
