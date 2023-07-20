function buildOutput=buildExcelPRJ(prjStruct)

    options=compiler.build.ExcelAddInOptions(prjStruct.fileset_exports.file);

    options.EmbedArchive=...
    ~prjStruct.param_user_defined_mcr_options.contains("-C");
    options.DebugBuild="off";
    options.AddInName=prjStruct.param_appname;
    options.AddInVersion=prjStruct.param_version;
    options.GenerateVisualBasicFile='on';




    theClasses=[prjStruct.fileset_classes.entity_package.entity_class.nameAttribute];
    options.ClassName=theClasses(1);

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.excelAddIn(options);

end