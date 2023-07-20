function flag=isStateProperty(obj,prop)








    mp=findprop(obj,prop);
    flag=~isempty(mp)&&isa(mp,'matlab.system.CustomMetaProp')&&...
    (mp.DiscreteState||mp.ContinuousState);

end
