function result=isComponentValveCharacteristicsMWayNPosSupported(componentPath)




    result=any(strcmp(componentPath,{
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_M_way_N_position'}));
end