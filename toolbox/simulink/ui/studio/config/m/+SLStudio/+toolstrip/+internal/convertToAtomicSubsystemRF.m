
function convertToAtomicSubsystemRF(cbinfo,action)

    editor=cbinfo.studio.App.getActiveEditor;
    selections=editor.getSelection;

    if selections.size()==0||selections.size()>1
        return;
    end

    selection=selections.at(1);
    if isempty(selection)||isempty(find(strcmp(fieldnames(selection),'handle'),1))
        return;
    end

    handle=selection.handle;
    if~isa(get_param(handle,'Object'),'Simulink.SubSystem')||~strcmpi(get_param(handle,'SFBlockType'),'None')
        action.enabled=false;
        return;
    end

    if strcmp(get_param(handle,'TreatAsAtomicUnit'),'on')==1
        action.selected=true;
    else
        action.selected=false;
    end

    action.enabled=true;
end
