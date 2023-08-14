function tf=activateEditor(cbinfo)




    tf=false;
    app=slreq.app.MainManager.getInstance;
    if slreq.toolstrip.isEditor(cbinfo)
        tf=true;
        editor=app.requirementsEditor;
        if app.getCurrentView()~=editor
            app.setLastOperatedView(editor);
        end
    end
end