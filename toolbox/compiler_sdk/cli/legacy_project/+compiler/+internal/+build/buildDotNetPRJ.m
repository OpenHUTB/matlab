function buildOutput=buildDotNetPRJ(prjStruct)

    classmap=compiler.internal.build.LegacyProjectBuildUtilities.generateClassmapFromPRJ(prjStruct);
    options=compiler.build.DotNETAssemblyOptions(classmap);

    options.DebugBuild="off";
    options.AssemblyName=compiler.internal.build.LegacyProjectBuildUtilities.getNamespacedComponentName(prjStruct);
    options.AssemblyVersion=prjStruct.param_version;
    options.EmbedArchive=...
    ~prjStruct.param_user_defined_mcr_options.contains("-C");
    options.EnableRemoting=strcmp(prjStruct.param_net_enable_remoting,"true");

    if strcmp(prjStruct.param_assembly_type,"true")
        options.StrongNameKeyFile=prjStruct.param_encryption_key_file;
    end





    if strcmp(prjStruct.param_net_tsa_enable,"true")
        warning(message('Compiler:build:compatibility:typeSafeNotSupported'));
    end

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSampleFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    buildOutput=compiler.build.dotNETAssembly(options);

end