

function setModelPropertiesButtonName(cbinfo,action)

    bdType=get_param(cbinfo.model.handle,'BlockDiagramType');
    if strcmpi(bdType,'library')
        action.text="simulink_ui:studio:resources:LibraryPropertiesActionText";
    elseif strcmpi(bdType,'subsystem')
        action.text="simulink_ui:studio:resources:SubsystemReferencePropertiesActionText";
    end
end
