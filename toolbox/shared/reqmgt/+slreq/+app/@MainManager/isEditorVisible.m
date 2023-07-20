function tf=isEditorVisible()

    tf=false;



    if slreq.app.MainManager.exists()
        appmgr=slreq.app.MainManager.getInstance();
        tf=~isempty(appmgr.requirementsEditor)&&appmgr.requirementsEditor.isVisible;
    end
end
