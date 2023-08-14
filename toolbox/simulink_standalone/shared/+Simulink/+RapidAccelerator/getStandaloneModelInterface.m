function interface=getStandaloneModelInterface(model)
    persistent standaloneInterfaceMap;
    persistent lastModel;
    if(iscell(model))
        model=cell2mat(model);
    end
    if(isempty(model))
        model=lastModel;
    end
    model=regexprep(model,'/.*?$','');
    if(isempty(standaloneInterfaceMap))
        standaloneInterfaceMap=containers.Map;
    end
    if(~standaloneInterfaceMap.isKey(model))
        standaloneInterfaceMap(model)=Simulink.RapidAccelerator.StandaloneModelInterface(model);
    end
    interface=standaloneInterfaceMap(model);
    lastModel=model;
end