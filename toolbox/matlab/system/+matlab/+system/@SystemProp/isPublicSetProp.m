function flag=isPublicSetProp(mp)


    flag=~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public')&&...
    ~(isa(mp,'matlab.system.CustomMetaProp')&&(mp.DiscreteState||mp.ContinuousState))&&...
    ~(mp.Dependent&&isempty(mp.SetMethod));
end
