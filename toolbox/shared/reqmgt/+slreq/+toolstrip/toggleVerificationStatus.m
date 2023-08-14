function toggleVerificationStatus(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(editor)
        if cbinfo.EventData
            editor.toggleOnVerificationStatus();
        else
            editor.toggleOffVerificationStatus();
        end
    end
end