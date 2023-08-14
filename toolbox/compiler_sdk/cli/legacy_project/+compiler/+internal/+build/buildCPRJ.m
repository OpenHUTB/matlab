function buildOutput=buildCPRJ(prjStruct)

    options=compiler.build.CSharedLibraryOptions(prjStruct.fileset_exports.file);

    options.EmbedArchive=...
    ~prjStruct.param_user_defined_mcr_options.contains("-C");
    options.DebugBuild="off";
    options.LibraryName=prjStruct.param_appname;

    options.LibraryVersion=prjStruct.param_version;

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.cSharedLibrary(options);

end
