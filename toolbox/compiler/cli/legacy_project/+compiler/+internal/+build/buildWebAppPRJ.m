function buildOutput=buildWebAppPRJ(prjStruct)

    options=compiler.build.WebAppArchiveOptions(...
    prjStruct.fileset_web_main.file);
    options.ArchiveName=prjStruct.param_appname;

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.webAppArchive(options);

end
