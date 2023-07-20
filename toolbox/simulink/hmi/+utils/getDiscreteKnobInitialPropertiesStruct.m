

function s=getDiscreteKnobInitialPropertiesStruct(modelName,widgetId,isLibWidget)

    discreteKnob=utils.getWidget(modelName,widgetId,isLibWidget);
    if~isempty(discreteKnob)


        states=utils.getAsCellString(discreteKnob.States);
        stateLabels=discreteKnob.StateLabels;
    else
        states={'0','1','2','3'};
        stateLabels={'Off','Low','Medium','High'};
    end
    s=struct();
    for i=1:length(states)
        s(i).index=i;
        s(i).states=states{i};
        s(i).stateLabels=stateLabels{i};
    end
end
