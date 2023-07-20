function legacyProject(prjFile)


    buildOutput=compiler.internal.build.legacyProject(prjFile);

    prjStruct=compiler.internal.readPRJStruct(prjFile);

    targetName=prjStruct.targetAttribute;
    if strcmp(targetName,"target.ezdeploy.standalone")||...
        strcmp(targetName,"target.ezdeploy.library")


        compiler.internal.package.packageInstaller(prjStruct,buildOutput);
    elseif strcmp(targetName,"target.webdeploy")||...
        strcmp(prjStruct.param_target_type,"subtarget.mads")
        compiler.internal.package.copyBuildOutputToRedistributionFolder(prjStruct,buildOutput);
    elseif strcmp(prjStruct.param_target_type,"subtarget.mps.excel")
        if~license('test','matlab_builder_for_java')
            error(message('Compiler:build:compatibility:sdkNotAvailable',prjFile))
        end
        compiler.internal.package.packageExcelClient(prjStruct,buildOutput);
    else
        warning(message('Compiler:build:compatibility:packagingNotSupported',prjFile));
    end


    disp(message('Compiler:package:compatibility:packageComplete').getString)
end
