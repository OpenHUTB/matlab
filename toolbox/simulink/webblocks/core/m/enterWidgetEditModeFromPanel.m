function enterWidgetEditModeFromPanel(editorWebId,blockHandle)
    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    if(isempty(editor))
        return
    end
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end





    parentSystem=get_param(blockHandle,'Parent');
    modelDiagramPair=SLM3I.Util.getDiagram(parentSystem);

    element=SLM3I.SLDomain.handle2DiagramElement(blockHandle);
    SLM3I.SLCommonDomain.setWidgetEditModeForEditor(editor,element.handle,true);
end
