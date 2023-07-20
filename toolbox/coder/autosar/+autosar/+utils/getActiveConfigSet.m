function[activeConfigSet,isConfigurationReference]=getActiveConfigSet(model)




    activeConfigSet=getActiveConfigSet(model);
    if isa(activeConfigSet,'Simulink.ConfigSetRef')
        isConfigurationReference=true;
        activeConfigSet=activeConfigSet.getRefConfigSet;
    end
end
