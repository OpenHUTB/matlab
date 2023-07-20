function openTM(cbinfo)
    view=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(view)
        view.generateRTMX();
    end
end