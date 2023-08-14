function updateDeps=ccAutoInferHeaderFiles(cs,msg)


    updateDeps=false;

    hMdl=cs.getModel;
    mdlName=get_param(hMdl,'Name');
    if isempty(hMdl)
        errordlg('Inferring header files requires a Simulink model to be open. Open a Simulink model before continuing.','Error');
        return;
    end




    dvStage=sldiagviewer.createStage('Simulink','ModelName',mdlName);%#ok<NASGU>


    dlg=cs.getDialogHandle;
    if~isempty(dlg)&&dlg.hasUnappliedChanges
        unappliedChange=message('Simulink:CustomCode:InferHdrUnappliedChanges',mdlName);
        unappliedChangeSLDiag=MSLException([],unappliedChange);
        SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',unappliedChangeSLDiag);
        slmsgviewer.Instance(mdlName).show();
        return;
    end

    if isempty(strip(get_param(hMdl,'SimUserSources')))
        srcEmptyErr=message('Simulink:CustomCode:EmptyCustomCodeSource',mdlName);
        srcEmptySLDiag=MSLException([],srcEmptyErr);
        SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',srcEmptySLDiag);
        slmsgviewer.Instance(mdlName).show();
        return;
    end

    btnYes=message('Simulink:CustomCode:InferHdrConfirmationDlgYesLabel').getString;
    selection=btnYes;
    if~isempty(strip(get_param(cs,'SimCustomHeaderCode')))
        selection=constructConfirmDlg();
    end

    if strcmp(selection,btnYes)
        Progressbar=DAStudio.WaitBar;
        Progressbar.setWindowTitle(getString(message('RTW:configSet:InferringHeadersTitle')));
        Progressbar.setLabelText(getString(message('RTW:configSet:InferringHeadersPleaseWait')));
        Progressbar.setCircularProgressBar(true);
        Progressbar.show();

        try
            isSettingOnly=false;
            forSLCC=false;
            reportTokenizerError=true;
            ccInfo=cgxeprivate('getCCInfo',mdlName,isSettingOnly,forSLCC,reportTokenizerError);
        catch ME
            SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',ME);
            slmsgviewer.Instance(mdlName).show();
            return;
        end

        try
            hdrFiles=SLCC.Utils.InferHeaderDependencies(ccInfo);
        catch ME
            SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',ME);
            slmsgviewer.Instance(mdlName).show();
            return;
        end

        if isempty(hdrFiles)
            hdrEmptyErr=message('Simulink:CustomCode:InferredHeadersEmpty');
            hdrEmptySLDiag=MSLException([],hdrEmptyErr);
            SLCC.Utils.displayOnDiagnosticViewer(mdlName,'warning',hdrEmptySLDiag);
            slmsgviewer.Instance(mdlName).show();
        else
            hdrString=sprintf('#include "%s"\n',hdrFiles);
            set_param(cs,'SimCustomHeaderCode',hdrString);
            webDlg=dlg.getDialogSource;
            webDlg.enableApplyButton(true);
        end
    end
end

function ret=constructConfirmDlg()
    simCustomHdrName=message('RTW:configSet:SimCustomHeaderCodeName').getString;
    title=message('Simulink:CustomCode:InferHdrConfirmationDlgTitle').getString;
    msg=message('Simulink:CustomCode:InferHdrConfirmationDlgMsg',simCustomHdrName).getString;
    btnYes=message('Simulink:CustomCode:InferHdrConfirmationDlgYesLabel').getString;
    btnNo=message('Simulink:CustomCode:InferHdrConfirmationDlgNoLabel').getString;
    defbtn=btnYes;
    ret=questdlg(msg,title,btnYes,btnNo,defbtn);
end