function result=isComponentTurbineMapSupported(componentPath)




    result=any(strcmp(componentPath,{
'fluids.gas.turbomachinery.turbine'...
    ,'fluids.two_phase_fluid.fluid_machines.turbine'}));
end