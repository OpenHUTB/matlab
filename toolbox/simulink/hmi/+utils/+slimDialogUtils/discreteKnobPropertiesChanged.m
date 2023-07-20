

function discreteKnobPropertiesChanged(discreteKnobDlgSrc,widgetId,mdl,isLibWidget)


    scChannel='/hmi_discrete_knob_controller_/';
    widget=utils.getWidget(mdl,widgetId,isLibWidget);

    if~isempty(widget)
        [states,stateLabels,success,~]=...
        utils.validateDiscreteStates(discreteKnobDlgSrc);

        if~success
            return;
        end

        widget.States=states;
        widget.StateLabels=stateLabels;
        bindParameter(discreteKnobDlgSrc);

        properties=utils.getDiscreteKnobInitialPropertiesStruct(mdl,widgetId,isLibWidget);
        message.publish([scChannel,'updateProperties'],...
        {true,widgetId,mdl,properties});

        set_param(mdl,'Dirty','on');
    end
end