function result=isComponentPosDispCompressorCharacteristicsSupported(componentPath)




    result=any(strcmp(componentPath,{
'fluids.gas.turbomachinery.positive_displacement_compressor'...
    ,'fluids.two_phase_fluid.fluid_machines.positive_displacement_compressor'}));
end