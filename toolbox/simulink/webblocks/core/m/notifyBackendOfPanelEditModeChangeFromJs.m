

function notifyBackendOfPanelEditModeChangeFromJs(editorWebId,enabled)
    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    if isempty(editor)
        return;
    end
    SLM3I.SLDomain.notifyBackendOfPanelEditModeChange(editor,enabled)
end