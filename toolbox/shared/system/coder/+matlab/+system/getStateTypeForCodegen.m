function stateType=getStateTypeForCodegen(className,propName)






    stateType='NotState';
    mc=meta.class.fromName(className);
    mps=mc.Properties;

    for ii=1:length(mps)
        mp=mps{ii};
        if strcmp(mp.Name,propName)&&isa(mp,'matlab.system.CustomMetaProp')
            if mp.DiscreteState
                stateType='DiscreteState';
            elseif mp.ContinuousState
                stateType='ContinuousState';
            end
            break;
        end
    end
