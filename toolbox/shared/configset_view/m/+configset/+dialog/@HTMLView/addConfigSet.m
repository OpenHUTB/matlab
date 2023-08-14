function addConfigSet(obj,data)



    cs=Simulink.ConfigSet;
    attachConfigSet(data.model,cs,true);
    setActiveConfigSet(data.model,cs.Name);
    newSource=getActiveConfigSet(data.model);
    setSource(obj,newSource,true);
end
