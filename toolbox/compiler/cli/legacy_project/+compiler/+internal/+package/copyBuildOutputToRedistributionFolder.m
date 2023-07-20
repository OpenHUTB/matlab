function copyBuildOutputToRedistributionFolder(prjStruct,buildOutput)



    if strcmp(prjStruct.param_target_type,"subtarget.mads")||...
        (strcmp(prjStruct.targetAttribute,"target.webdeploy")&&...
        isfield(prjStruct,'param_checkbox')&&...
        strcmp(prjStruct.param_checkbox,'true'))


        additionalFiles=prjStruct.fileset_package;

        if isstruct(additionalFiles)
            moreFiles=additionalFiles.file;
            theFiles=[buildOutput.Files',cellstr(moreFiles)];
        else
            theFiles=buildOutput.Files;
        end

        serverAppFolder=prjStruct.param_output;

        if~strcmp(serverAppFolder,"")
            compiler.internal.package.writeFilesOnlyFolder(...
            theFiles,prjStruct.param_intermediate,serverAppFolder);
        end
    end

end