function updateToolstrip(cbinfo,action)

    view=slreq.app.MainManager.getInstance().requirementsEditor;
    if~isempty(view)
        view.updateToolstrip();
    end
end