function result=isComponentPlotTLPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'foundation.thermal_liquid.utilities.thermal_liquid_settings'}));
end
