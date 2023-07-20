function toggleComment(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(editor)
        if cbinfo.EventData
            editor.setDisplayComment(true);
        else
            editor.setDisplayComment(false);
        end
    end
end