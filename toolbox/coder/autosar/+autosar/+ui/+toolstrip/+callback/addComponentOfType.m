function addComponentOfType(componentType,cbinfo)




    mdlH=SLStudio.Utils.getDiagramHandle(cbinfo);
    editor=SLM3I.SLDomain.getLastActiveEditorFor(mdlH);
    switch componentType
    case 'Component'
        Simulink.Editor.CompositionTools.SLComponentCreationTool(editor);
    case 'Composition'
        Simulink.Editor.CompositionTools.SLCompositionCreationTool(editor)
    case 'DiagnosticServiceComponent'
        Simulink.Editor.CompositionTools.SLDemComponentCreationTool(editor);
    case 'NVRAMServiceComponent'
        Simulink.Editor.CompositionTools.SLNvMComponentCreationTool(editor);
    case 'Adapter'
        Simulink.Editor.CompositionTools.SLAdapterCreationTool(editor);
    case 'Merge'
        Simulink.Editor.CompositionTools.SLMergeCreationTool(editor);
    otherwise
        assert(false,'Unexpected option for adding behavior');
    end


