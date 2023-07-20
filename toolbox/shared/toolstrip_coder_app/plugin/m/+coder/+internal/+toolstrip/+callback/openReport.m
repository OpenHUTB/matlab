function openReport(input)


    if isa(input,'SLM3I.CallbackInfo')
        editor=input.studio.App.getActiveEditor;
        modelH=coder.internal.toolstrip.util.getCodeGenRoot(editor);
    else
        modelH=input;
    end

    if coder.internal.toolstrip.util.checkUseSlcoderOrEcoderFeaturesBasedOnTarget(modelH)

        try
            [rptInfo,srcSysName]=rtw.report.getLatestReportInfo(modelH);

            if Simulink.report.ReportInfo.featureReportV2
                mainFile=fullfile(rptInfo.getReportDir,'index.html');
            else
                mainFile=rptInfo.getContentsFileFullName;
            end

            if~isfile(mainFile)



                rtw.report.generate(srcSysName);
                if~strcmp(get_param(modelH,'LaunchReport'),'on')



                    rptInfo.show;
                end
            else
                rtw.report.launch(srcSysName);
            end

        catch me
            if strcmp(me.identifier,'RTW:report:relativeBuildFolderNotFound')||...
                strcmp(me.identifier,'RTW:report:buildFolderNotFound')

                rtw.report.launch(modelH);
            else
                errordlg(me.message);
            end
        end
    end
