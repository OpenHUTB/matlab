function result=isComponentPlotILPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'fluids.isothermal_liquid.utilities.isothermal_liquid_predefined_properties'}));
end

