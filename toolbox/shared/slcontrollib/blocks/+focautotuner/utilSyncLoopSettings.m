function utilSyncLoopSettings(blkh,settingsType)










    if~strcmpi(get_param(bdroot(blkh),'SimulationStatus'),'stopped')
        return
    end

    switch settingsType
    case 'Current'
        loopNames={'AllInner';'Daxis';'Qaxis'};
    case 'Outer'
        loopNames={'AllOuter';'Speed';'Flux'};
    end





    params={'PIDType';'PIDForm';'Ts';'IntegratorMethod';'FilterMethod';...
    'Bandwidth';'TargetPM';'PlantType';'PlantSign';'AmpSine'};


    paramsAll=strcat(params,loopNames{1});
    paramsLoop1=strcat(params,loopNames{2});
    paramsLoop2=strcat(params,loopNames{3});


    maskNames=get_param(blkh,'MaskNames');
    maskValues=get_param(blkh,'MaskValues');
    maskParamIdx=contains(maskNames,paramsAll);


    maskParamValues=maskValues(maskParamIdx);

    for ii=1:length(maskParamValues)
        set_param(blkh,paramsLoop1{ii},maskParamValues{ii});
        set_param(blkh,paramsLoop2{ii},maskParamValues{ii});
    end

end