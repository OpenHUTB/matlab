function ConfigSet_PlatformDefinition(obj)










    if isR2022aOrEarlier(obj.ver)
        name=getConfigSets(obj.modelName);
        for k=1:length(name)
            cs=getConfigSet(obj.modelName,name{k});
            if~isa(cs,'Simulink.ConfigSetRef')

                cs.setPropEnabled('PlatformDefinition',true);
                cs.setPropEnabled('EmbeddedCoderDictionary',true);

                set_param(cs,'EmbeddedCoderDictionary','');
            end
        end
    end
