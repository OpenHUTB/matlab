function result=isComponentPlot2PPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties'}));
end
