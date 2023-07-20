function updateSwitchStates(handle,widgetId,isSlimDialog,states)
    model=get_param(bdroot(handle),'Name');
    updateStates=struct();
    for i=1:length(states)
        updateStates(i).index=i;
        updateStates(i).states=states(i).Value;
        if isfield(states(i).Label,'text')
            updateStates(i).stateLabels=states(i).Label.text.content;
        else
            updateStates(i).stateLabels=states(i).Label;
        end
    end
    scChannel='/hmi_discrete_knob_controller_/';
    message.publish([scChannel,'updateProperties'],...
    {~isSlimDialog,widgetId,model,updateStates});
end

