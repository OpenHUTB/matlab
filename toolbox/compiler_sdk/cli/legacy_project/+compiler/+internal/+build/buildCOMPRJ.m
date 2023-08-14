function buildOutput=buildCOMPRJ(prjStruct)


    classmap=compiler.internal.build.LegacyProjectBuildUtilities.generateClassmapFromPRJ(prjStruct);
    options=compiler.build.COMComponentOptions(classmap);

    options.DebugBuild="off";
    options.ComponentName=compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName(prjStruct);
    options.ComponentVersion=prjStruct.param_version;

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.comComponent(options);

end