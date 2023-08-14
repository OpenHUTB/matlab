


function insertComponentCB(userData,cbinfo)
    editor=cbinfo.studio.App.getActiveEditor();
    assert(~isempty(editor));
    modelH=editor.blockDiagramHandle;
    modelDomain=get_param(modelH,'SimulinkSubDomain');


    switch userData
    case 'Reference'
        Simulink.Editor.CompositionTools.SLReferenceCreationTool(editor);
    case 'Variant'
        Simulink.Editor.CompositionTools.SLVariantCreationTool(editor);
    case 'Adapter'
        Simulink.Editor.CompositionTools.SLAdapterCreationTool(editor);
    end


    if strcmp(modelDomain,'Architecture')&&strcmp(userData,'Component')
        Simulink.Editor.CompositionTools.SLComponentCreationTool(editor);
    end


    if strcmp(modelDomain,'SoftwareArchitecture')
        switch userData
        case 'SoftwareComponent'
            Simulink.Editor.CompositionTools.SLSoftwareComponentCreationTool(editor);
        case 'Merge'
            Simulink.Editor.CompositionTools.SLMergeCreationTool(editor);
        case 'ServerFunctionComponent'
            Simulink.Editor.CompositionTools.SLServerFunctionComponentCreationTool(editor);
        case 'MessageFunctionComponent'
            Simulink.Editor.CompositionTools.SLMessageFunctionComponentCreationTool(editor);
        case 'Initialize'
            Simulink.Editor.CompositionTools.SLInitializeFunctionCreationTool(editor);
        case 'Reset'
            Simulink.Editor.CompositionTools.SLResetFunctionCreationTool(editor);
        case 'Terminate'
            Simulink.Editor.CompositionTools.SLTerminateFunctionCreationTool(editor);
        case 'Function'
            Simulink.Editor.CompositionTools.SLInternalFunctionCreationTool(editor);
        end
    end
end
