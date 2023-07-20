function result=isComponentPlotGasPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'foundation.gas.utilities.gas_properties'}));
end
