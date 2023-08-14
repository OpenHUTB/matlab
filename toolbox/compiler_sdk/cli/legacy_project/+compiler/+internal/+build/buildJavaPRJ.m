function buildOutput=buildJavaPRJ(prjStruct)

    classmap=compiler.internal.build.LegacyProjectBuildUtilities.generateClassmapFromPRJ(prjStruct);
    options=compiler.build.JavaPackageOptions(classmap);

    options.DebugBuild="off";
    options.PackageName=compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName(prjStruct);

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSampleFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.javaPackage(options);

end