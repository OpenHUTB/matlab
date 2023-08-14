function buildOutput=buildMPSExcelPRJ(prjStruct)




    serverBuildOutput=compiler.internal.build.buildMPSPRJ(prjStruct);



    archiveLocation=serverBuildOutput.Files{1};
    classStruct=prjStruct.fileset_classes.entity_package.entity_class;

    options=compiler.build.ExcelClientForProductionServerOptions(...
    classStruct.file,archiveLocation);

    options.AddInName=prjStruct.param_appname;
    options.AddInVersion=prjStruct.param_version;
    options.ClassName=classStruct.nameAttribute;
    options.DebugBuild='off';
    options.GenerateVisualBasicFile='on';

    options.OutputDir=fullfile(prjStruct.param_intermediate,"client");
    options.Verbose=true;

    options=compiler.internal.build.LegacyProjectBuildUtilities.configureDataMarshallingRules(options,prjStruct);

    buildOutput=compiler.build.excelClientForProductionServer(options);


end