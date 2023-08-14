function tf=hasEditor()








    if slreq.app.MainManager.exists()
        appmgr=slreq.app.MainManager.getInstance();
        tf=~isempty(appmgr.requirementsEditor)||...
        (~isempty(appmgr.spreadsheetManager)&&appmgr.spreadsheetManager.hasData());
    else
        tf=false;
    end
end
