function updateDiscreteStates(handle,widgetId,isSlimDialog)
    model=get_param(bdroot(handle),'Name');
    states=get_param(handle,'States');
    if isa(states,'char')
        states=jsondecode(states);
    end
    updateStates=struct();
    for i=1:length(states)
        updateStates(i).index=i;
        updateStates(i).states=states(i).Value;
        updateStates(i).stateLabels=states(i).Label;
    end
    scChannel='/hmi_discrete_knob_controller_/';
    message.publish([scChannel,'updateProperties'],...
    {~isSlimDialog,widgetId,model,updateStates});
end

