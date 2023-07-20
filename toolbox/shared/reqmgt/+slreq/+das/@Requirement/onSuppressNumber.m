function onSuppressNumber()



    appmgr=slreq.app.MainManager.getInstance();
    currentReq=appmgr.getCurrentViewSelections();

    if isa(currentReq,'slreq.das.Requirement')
        srcDataReq=currentReq.dataModelObj;
        currentValue=srcDataReq.hIdxEnabled;
        srcDataReq.enableHIdx(~currentValue);

        dlgs=DAStudio.ToolRoot.getOpenDialogs(currentReq);
        slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);
    end
end
