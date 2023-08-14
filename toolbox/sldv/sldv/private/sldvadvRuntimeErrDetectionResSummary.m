function sldvadvRuntimeErrDetectionResSummary(modelName,datafile,showUI)




    if~bdIsLoaded(modelName)
        try
            load_system(modelName);
        catch MEx

            if strcmp(MEx.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                createResSummaryWarnDialog();
            else
                errortitle=getString(message(...
                'Sldv:ModelAdvisor:Runtime_Error_Detection:ResultsSummaryError'));
                errordlg(MEx.message,errortitle);
            end
            return;
        end
    end
    if~(exist(datafile,'file')==2)

        createResSummaryWarnDialog();
        return;
    end


    modelH=get_param(modelName,'Handle');
    progressBar=createResSummaryProgressIndicator();
    [status,errormsg]=sldvloadresults(modelH,datafile,showUI);
    if(status==true)

        callbackInfo.model.Handle=modelH;
        sldvprivate('util_menu_callback','load_active_results',callbackInfo);
        if~isempty(progressBar)
            progressBar=[];
        end
    else
        if~isempty(progressBar)
            progressBar=[];
        end
        errortitle=getString(message(...
        'Sldv:ModelAdvisor:Runtime_Error_Detection:ResultsSummaryError'));
        errordlg(errormsg,errortitle);
    end
end

function progressBar=createResSummaryProgressIndicator()
    try
        progressBar=DAStudio.WaitBar;
        progressBar.setWindowTitle(getString(message(...
        'Sldv:ModelAdvisor:Runtime_Error_Detection:ResultsSummaryProgressBar')));
        progressBar.setLabelText(DAStudio.message(...
        'Simulink:tools:MAPleaseWait'));
        progressBar.setCircularProgressBar(true);
        progressBar.show();
    catch Mex %#ok<NASGU>
        progressBar=[];
    end
end

function createResSummaryWarnDialog()
    tag='SLDV_MdlAdv_ResSummary_WarnDlg';
    h=findobj('Tag',tag);
    if isempty(h)

        warndlgName=getString(message(...
        'Sldv:ModelAdvisor:Runtime_Error_Detection:WarningDlgName'));
        warndlgMsg=getString(message(...
        'Sldv:ModelAdvisor:Runtime_Error_Detection:WarningDlgMsg'));
        h=warndlg(warndlgMsg,warndlgName);
        h.HandleVisibility='on';
        h.Tag=tag;
    else

        figure(h);
    end
end