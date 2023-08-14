





function datapathCtleConfigUpdate(block)



    DCGain=str2num(get_param(block,'DCGain'));%#ok<*ST2NM>
    ACGain=str2num(get_param(block,'ACGain'));
    PeakingGain=str2num(get_param(block,'PeakingGain'));
    PeakingFrequency=str2num(get_param(block,'PeakingFrequency'));
    GPZ=slResolve(get_param(block,'GPZ'),bdroot(block));
    lenvec=[length(PeakingFrequency),length(DCGain),...
    length(ACGain),length(PeakingGain),size(GPZ,1)];

    Specification=get_param(block,'Specification');
    switch Specification
    case 'DC Gain and Peaking Gain'
        lenvecMask=logical([1,1,0,1,0]);
    case 'DC Gain and AC Gain'
        lenvecMask=logical([1,1,1,0,0]);
    case 'AC Gain and Peaking Gain'
        lenvecMask=logical([1,0,1,1,0]);
    otherwise
        lenvecMask=logical([0,0,0,0,1]);
    end



    ConfigCount=max([1,min(lenvec((lenvec~=1)&lenvecMask))]);
    newConfigSelect=cellstr(string((0:(ConfigCount-1))'));

    mask=Simulink.Mask.get(block);
    parameter=mask.getParameter('ConfigSelect');
    configSelect=parameter.TypeOptions;
    if~isequal(configSelect,newConfigSelect)
        parameter.TypeOptions=newConfigSelect;
    end
