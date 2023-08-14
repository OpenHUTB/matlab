function toggleChangeInformation(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(editor)
        if cbinfo.EventData
            editor.toggleOnChangeInformation();
        else
            editor.toggleOffChangeInformation();
        end
    end
end