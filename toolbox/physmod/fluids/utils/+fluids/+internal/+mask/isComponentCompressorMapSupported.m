function result=isComponentCompressorMapSupported(componentPath)




    result=any(strcmp(componentPath,{
'fluids.gas.turbomachinery.compressor'...
    ,'fluids.two_phase_fluid.fluid_machines.compressor'}));
end