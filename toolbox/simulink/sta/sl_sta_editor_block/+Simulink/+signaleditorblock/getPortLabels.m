function labels=getPortLabels(block)





    if~ischar(block)

        error('Function only takes block path as input.');
    end

    labels={'Signal 1'};
    if getSimulinkBlockHandle(block)>0
        BlockDataModel=get_param([block,'/Model Info'],'UserData');
        activeScenario=get_param(block,'ActiveScenario');
        labels=BlockDataModel.getSignalsForScenario(activeScenario);
        if isempty(labels)
            labels={'Signal 1'};
        end
    end

end