function flag=isPublicGetProp(mp)


    flag=~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
    ~(isa(mp,'matlab.system.CustomMetaProp')&&(mp.DiscreteState||mp.ContinuousState))&&...
    ~(mp.Dependent&&isempty(mp.GetMethod));
end
