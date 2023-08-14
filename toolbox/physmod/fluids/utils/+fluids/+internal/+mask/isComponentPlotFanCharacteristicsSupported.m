function result=isComponentPlotFanCharacteristicsSupported(componentPath)




    result=any(strcmp(componentPath,{
'fluids.gas.turbomachinery.fan'
    'fluids.moist_air.turbomachinery.fan'}));
end