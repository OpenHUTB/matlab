function buildOutput=buildPythonPRJ(prjStruct)

    options=compiler.build.PythonPackageOptions(...
    prjStruct.fileset_exports.file);

    options.PackageName=compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName(prjStruct);

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSampleFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.pythonPackage(options);

end