function updateDeps=ccParseCCBtnCallback(cs,msg)


    updateDeps=false;

    hMdl=cs.getModel;
    if isempty(hMdl)
        errordlg('Parsing custom code requires a Simulink model to be open. Initiate the parse from a Simulink model.','Error');
        return;
    end

    mdlName=get_param(hMdl,'Name');

    dlg=cs.getDialogHandle;
    if~isempty(dlg)&&dlg.hasUnappliedChanges
        unappliedChange=message('Simulink:CustomCode:ValidateCCUnappliedChanges',mdlName);
        unappliedChangeSLDiag=MSLException([],unappliedChange);
        SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',unappliedChangeSLDiag);
        slmsgviewer.Instance(mdlName).show();
        return;
    end

    Progressbar=DAStudio.WaitBar;
    Progressbar.setWindowTitle(getString(message('RTW:configSet:ParsingCustomCodeTitle')));
    Progressbar.setLabelText(getString(message('RTW:configSet:ParsingCustomCodePleaseWait')));
    Progressbar.setCancelButtonText(DAStudio.message('Simulink:utility:CloseButton'));
    Progressbar.setCircularProgressBar(true);
    Progressbar.show();

    if isempty(strip(get_param(hMdl,'SimCustomHeaderCode')))
        hdrEmptyErr=message('Simulink:CustomCode:EmptyCustomCodeHeader',mdlName);
        hdrEmptySLDiag=MSLException([],hdrEmptyErr);
        SLCC.Utils.displayOnDiagnosticViewer(mdlName,'error',hdrEmptySLDiag);
        slmsgviewer.Instance(mdlName).show();
        return;
    end


    dvStage=sldiagviewer.createStage('Simulink','ModelName',mdlName);%#ok<NASGU>
    validatingCCMsg=message('Simulink:CustomCode:ValidateCustomCode',mdlName);
    validatingCCSLDiag=MSLException([],validatingCCMsg);
    sldiagviewer.reportInfo(validatingCCSLDiag,'Component','Simulink','Category','Custom Code');
    slmsgviewer.Instance(mdlName).show();

    parseSuccess=slccprivate('parseCustomCode',hMdl,true);
    if parseSuccess
        exportedSyms=slcc('getExportedSymbols',hMdl);
        functionList=exportedSyms.functions;

        if~isempty(functionList)
            parseSuccessMsg=message('Simulink:CustomCode:ParseWithImportedFunctions',mdlName,strjoin(functionList,'\n'));
        else
            parseSuccessMsg=message('Simulink:CustomCode:CustomCudeParseSuccessful',mdlName);
        end
        parseSuccessSLDiag=MSLException([],parseSuccessMsg);
        SLCC.Utils.displayOnDiagnosticViewer(mdlName,'message',parseSuccessSLDiag);

        locBuildCustomCode(hMdl,Progressbar);
    end
end

function locBuildCustomCode(hMdl,Progressbar)
    Progressbar.setLabelText(getString(message('RTW:configSet:BuildingCustomCodePleaseWait')));
    buildSuccess=slccprivate('buildCustomCodeForModel',hMdl);
    if buildSuccess
        buildSuccessMsg=message('Simulink:CustomCode:CustomCodeBuildSuccessful',get_param(hMdl,'Name'));
        buildSuccessSLDiag=MSLException([],buildSuccessMsg);
        SLCC.Utils.displayOnDiagnosticViewer(get_param(hMdl,'Name'),'message',buildSuccessSLDiag);
    end
end