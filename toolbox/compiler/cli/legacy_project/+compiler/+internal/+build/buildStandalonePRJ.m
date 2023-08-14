function buildOutput=buildStandalonePRJ(prjStruct)

    options=compiler.build.StandaloneApplicationOptions(...
    prjStruct.fileset_main.file);

    options.EmbedArchive=...
    ~prjStruct.param_user_defined_mcr_options.contains("-C");

    options.ExecutableName=prjStruct.param_appname;
    if ispc||ismac

        if isstruct(prjStruct.param_icons)


            options.ExecutableIcon=prjStruct.param_icons.file(1);
        end
    end

    if ispc

        if prjStruct.param_screenshot.strlength>0


            options.ExecutableSplashScreen=prjStruct.param_screenshot;
        end
    end

    options.ExecutableVersion=prjStruct.param_version;


    if isfield(prjStruct,"param_native_matlab")
        options.TreatInputsAsNumeric=strcmp(prjStruct.param_native_matlab,"true");
        if strcmp(prjStruct.param_checkbox,"true")





            helpTextFile=writeHelpFile(char(prjStruct.param_help_text));
            cleanupHelpTextFile=onCleanup(@()delete(helpTextFile));
            options.CustomHelpTextFile=helpTextFile;
        end
    else
        options.TreatInputsAsNumeric=false;
    end


    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);





    if ispc&&strcmp(prjStruct.param_windows_command_prompt,"true")
        buildOutput=compiler.build.standaloneWindowsApplication(options);
    else
        buildOutput=compiler.build.standaloneApplication(options);
    end
end

function helpTextFile=writeHelpFile(helpTextString)
    helpTextFile=tempname;
    fileID=fopen(helpTextFile,'w');
    o1=onCleanup(@()fclose(fileID));
    fprintf(fileID,'%s',helpTextString);
end
