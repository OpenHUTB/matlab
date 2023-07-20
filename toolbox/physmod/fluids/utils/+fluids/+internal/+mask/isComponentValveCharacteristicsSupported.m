function result=isComponentValveCharacteristicsSupported(componentPath)




    result=any(strcmp(componentPath,{
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_2_way';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_3_way';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_2_position';
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.directional_valve_4_way_3_position';...
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_2_way';
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way';...
    'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_4_way_3_position'}));
end