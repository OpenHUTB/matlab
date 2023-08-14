function addParameterTuningToUndoStack(hBlk,val)




    [editor,editorDomain]=getEditorWithUndoRedo(get(hBlk,'Path'));
    if~isempty(editorDomain)
        editorDomain.createParamChangesCommand(...
        editor,...
        'SimulinkHMI:messages:ParamTuning',...
        DAStudio.message('SimulinkHMI:messages:ParamTuning'),...
        @addTuningValToUndo,...
        {hBlk,val,editorDomain},...
        false,...
        true,...
        false,...
        false,...
        true);
    end
end


function[success,noop]=addTuningValToUndo(hBlk,val,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(hBlk);
        set_param(hBlk,'TunedParameterValue',num2str(val));
    catch me %#ok<NASGU>
        success=false;
    end
end


function[editor,editorDomain]=getEditorWithUndoRedo(layerName)
    editor=[];
    editorDomain=[];
    try
        editors=GLUE2.Util.findAllEditors(layerName);
        numEditors=length(editors);
        for idx=1:numEditors
            if editors(idx).isVisible
                domain=editors(idx).getStudio.getActiveDomain();
                if ismethod(domain,'createParamChangesCommand')
                    editor=editors(idx);
                    editorDomain=domain;
                    break;
                end
            end
        end
    catch me %#ok<NASGU>
        editor=[];
        editorDomain=[];
    end
end
