function tunable=isTunablePropForCodegen(className,propName)







    tunable=true;
    mc=meta.class.fromName(className);
    mps=mc.PropertyList;
    for ii=1:length(mps)
        mp=mps(ii);
        if strcmp(mp.Name,propName)
            if iscell(mp.SetAccess)||~strcmp(mp.SetAccess,'public')||...
                isa(mp,'matlab.system.CustomMetaProp')&&...
                (mp.Nontunable||mp.DiscreteState||mp.ContinuousState)
                tunable=false;
            elseif~isa(mp,'matlab.system.CustomMetaProp')


                tunable=false;
            end
            break;
        end
    end
