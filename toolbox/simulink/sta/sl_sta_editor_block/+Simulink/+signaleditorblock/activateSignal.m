function activateSignal(blockPath,dataModel)







    SignalProperties=getSignalProperties(dataModel,get_param(blockPath,'ActiveSignal'));

    workSpaceBlockProperties={
    'SampleTime','Interpolate','ZeroCross','OutputAfterFinalValue'
    };

    for id=1:length(workSpaceBlockProperties)
        if~strcmp(get_param(blockPath,workSpaceBlockProperties{id}),...
            SignalProperties.(workSpaceBlockProperties{id}))
            set_param(blockPath,workSpaceBlockProperties{id},...
            SignalProperties.(workSpaceBlockProperties{id}));
        end
    end

    outPortProperties={
'Unit'
    };

    for id=1:length(outPortProperties)
        if~strcmp(get_param(blockPath,outPortProperties{id}),...
            SignalProperties.(outPortProperties{id}))
            set_param(blockPath,outPortProperties{id},...
            SignalProperties.(outPortProperties{id}));
        end
    end


    if strcmp(SignalProperties.IsBus,'on')&&...
        ~strcmp(get_param(blockPath,'IsBus'),'on')
        set_param(blockPath,'IsBus','on');
    elseif strcmp(SignalProperties.IsBus,'off')&&...
        ~strcmp(get_param(blockPath,'IsBus'),'off')
        set_param(blockPath,'IsBus','off');
    else

    end

    if~strcmp(get_param(blockPath,'OutputBusObjectStr'),...
        SignalProperties.BusObject)
        set_param(blockPath,'OutputBusObjectStr',SignalProperties.BusObject);
    end

end

