function displayReport(fileName)





    import Simulink.ModelReference.ProtectedModel.*;
    [opts,fullName]=getOptions(fileName);

    buildDirs=RTW.getBuildDir(opts.modelName);
    if opts.report
        rootTgtDir=getSimBuildDir();
        path=fullfile(rootTgtDir,buildDirs.ModelRefRelativeSimDir);


        try
            dstDir=unpack(fullName,'REPORT');
            rptInfo=rtw.report.ReportInfo.getReportInfoFromBuildDir(dstDir);
        catch me


            if strcmp(me.identifier,'RTW:report:invalidBuildFolder')
                unpack(fullName,'REPORT');
                rptInfo=rtw.report.ReportInfo.getReportInfoFromBuildDir(dstDir);
            else
                stage=Simulink.output.Stage(...
                message('Simulink:protectedModel:ProtectedModelReportMessageViewerStageName').getString,...
                'ModelName',opts.modelName,'UIMode',true);%#ok<NASGU>
                Simulink.output.error(me);
                return;
            end
        end


        warnIfNoSTF(fileName,opts);


        rptInfo.ModelName=opts.modelName;
        rptInfo.BuildDirectory=dstDir;


        if isa(rptInfo,'Simulink.ModelReference.ProtectedModel.Report')
            rptInfo.show;
            rptInfo.setCleanupAfterShow(true);
        else
            DAStudio.error('Simulink:protectedModel:ProtectedMdlNoRpt',path);
        end
    end
end

function warnIfNoSTF(fileName,opts)
    import Simulink.ModelReference.ProtectedModel.*;
    if~supportsAccel(opts)
        return;
    end


    assert(opts.report&&supportsAccel(opts));

    target=get_param(getConfigSet(fileName,'sim'),'SystemTargetFile');
    reader=coder.internal.stf.FileReader.getInstance(target);
    if~reader.Success&&reader.ErrorArguments{1}=="Simulink:utility:SystemTargetFileNotFound"

        MSLDiagnostic('Simulink:protectedModel:ProtectedModelCannotFindSTFConfigset',target,opts.modelName).reportAsWarning;
    end
end

