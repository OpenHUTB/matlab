

function importReqSet(cbinfo)
    if slreq.toolstrip.activateEditor(cbinfo)
        modelH=-1;
    else
        modelH=slreq.toolstrip.getModelHandle(cbinfo);
    end

    appmgr=slreq.app.MainManager.getInstance;


    ddgDialog=slreq.import.ui.dlg_mgr();


    currentView=appmgr.getSpreadSheetObject(modelH);
    if isa(currentView,'slreq.gui.ReqSpreadSheet')


        currentView.startListeningForImportedReqSets();
        importDlg=ddgDialog.getSource();
        importDlg.onCancel=@()currentView.stopListeningForImportedReqSets();
    end

end
