function selectConfigSet(obj,data)




    setActiveConfigSet(data.model,data.config);
    cs=obj.Source.getCS;
    model=cs.getModel;
    csNew=getConfigSet(model,data.config);
    setSource(obj,csNew,true);
end
