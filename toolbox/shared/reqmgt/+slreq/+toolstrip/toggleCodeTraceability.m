function toggleCodeTraceability(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    editor=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(editor)
        editor.showCode();
    end
end
