function toggleImplementationStatus(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(editor)
        if cbinfo.EventData
            editor.toggleOnImplementationStatus();
        else
            editor.toggleOffImplementationStatus();
        end
    end
end