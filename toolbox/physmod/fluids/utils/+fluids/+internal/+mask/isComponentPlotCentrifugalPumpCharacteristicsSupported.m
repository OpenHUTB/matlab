function result=isComponentPlotCentrifugalPumpCharacteristicsSupported(componentPath)





    result=any(strcmp(componentPath,{
'fluids.isothermal_liquid.pumps_motors.centrifugal_pump'
    'fluids.thermal_liquid.pumps_motors.centrifugal_pump'}));
end