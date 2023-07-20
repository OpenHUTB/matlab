function packageInstaller(prjStruct,buildOutput)

    options=compiler.package.InstallerOptions(buildOutput);

    if strcmp(prjStruct.param_web_mcr,"true")
        options.InstallerName=prjStruct.param_web_mcr_name;
        options.RuntimeDelivery="web";
    else
        options.InstallerName=prjStruct.param_package_mcr_name;
        options.RuntimeDelivery="installer";
    end

    options.AuthorName=prjStruct.param_authnamewatermark;
    options.AuthorEmail=prjStruct.param_email;
    options.AuthorCompany=prjStruct.param_company;
    options.Summary=prjStruct.param_summary;
    options.Description=prjStruct.param_description;
    options.OutputDir=prjStruct.param_output;

    if ispc||ismac

        if prjStruct.param_icon.strlength>0


            options.InstallerIcon=prjStruct.param_icons.file(1);
            if ispc

                options.AddRemoveProgramsIcon=options.InstallerIcon;
            end
        end

        if prjStruct.param_screenshot.strlength>0


            options.InstallerSplash=prjStruct.param_screenshot;
        end
    end

    if prjStruct.param_logo.strlength>0


        options.InstallerLogo=prjStruct.param_logo;
    end

    options.InstallationNotes=prjStruct.param_install_notes;

    if ispc&&strcmp(prjStruct.param_target_type,"subtarget.standalone")

        buildFiles=buildOutput.Files;
        for i=1:length(buildFiles)
            [~,~,ext]=fileparts(buildFiles{i});
            if strcmpi(ext,"exe")
                options.Shortcut=buildFiles{i};
                break
            end
        end
    end





    if ispc
        if strcmp(prjStruct.param_installpath_combo,"option.installpath.appdata")
            instRoot="%AppData%";
        else
            instRoot="%ProgramFiles%";
        end
    elseif ismac
        instRoot="/Applications";
    else
        if strcmp(prjStruct.param_installpath_combo,"option.installpath.user")
            instRoot="/usr";
        else
            instRoot="/usr/local";
        end
    end
    options.DefaultInstallationDir=fullfile(instRoot,prjStruct.param_installpath_string);


    additionalFiles=prjStruct.fileset_package;

    if isstruct(additionalFiles)
        moreFiles=additionalFiles.file;
        theFiles=[buildOutput.Files',cellstr(moreFiles)];



        mcrProductFile=fullfile(prjStruct.param_intermediate,"requiredMCRProducts.txt");
        compiler.package.installer(theFiles,mcrProductFile,"Options",options);
    else


        compiler.package.installer(buildOutput,"Options",options);
        theFiles=buildOutput.Files;
    end



    if isfield(prjStruct,'param_files_only')
        filesOnlyFolder=prjStruct.param_files_only;
        compiler.internal.package.writeFilesOnlyFolder(...
        theFiles,prjStruct.param_intermediate,filesOnlyFolder);
    end

end

