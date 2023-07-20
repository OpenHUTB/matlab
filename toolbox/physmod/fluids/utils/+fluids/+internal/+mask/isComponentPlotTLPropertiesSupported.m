function result=isComponentPlotTLPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'fluids.thermal_liquid.utilities.thermal_liquid_properties'}));
end

