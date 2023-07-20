function result=isComponentPlot2PPropertiesSupported(componentPath)




    result=any(strcmp(componentPath,{
    'foundation.two_phase_fluid.utilities.two_phase_fluid_properties'}));
end
