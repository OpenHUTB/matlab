classdef ConfigurationInterface<handle




    methods(Abstract)
        validateConfiguration(obj,configName);
        configNames=getConfigurationNames(obj);
        defaultConfig=getDefaultConfiguration(obj);
        varExprMap=getSimExprMap(obj);
        resetSimVarExprMap(obj);
    end

end
