function exitBindModeFromJs(editorWebId)
    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    if(isempty(editor))
        return
    end

    model=get_param(editor.getStudio().App.blockDiagramHandle,'object');
    BindMode.BindMode.disableBindMode(model);
end
