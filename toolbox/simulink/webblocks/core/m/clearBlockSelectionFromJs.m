function clearBlockSelectionFromJs(editorWebId)
    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    if isempty(editor)
        return
    end
    modelHandle=editor.getStudio.App.blockDiagramHandle;
    Simulink.HMI.clearBindingHighlight(modelHandle);
end