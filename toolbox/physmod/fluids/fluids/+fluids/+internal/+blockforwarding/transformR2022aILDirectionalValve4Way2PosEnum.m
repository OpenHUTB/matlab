function out=transformR2022aILDirectionalValve4Way2PosEnum(in)







    out=in;


    open_orifices_pos=getValue(out,'open_orifices_pos');
    open_orifices_pos_new=strrep(open_orifices_pos,...
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_open_orifices_pos_neg.',...
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.OpenOrifices4Way2Position.');
    out=setValue(out,'open_orifices_pos',open_orifices_pos_new);


    open_orifices_neg=getValue(out,'open_orifices_neg');
    open_orifices_neg_new=strrep(open_orifices_neg,...
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.directional_valve_open_orifices_pos_neg.',...
    'fluids.isothermal_liquid.valves_orifices.directional_control_valves.enum.OpenOrifices4Way2Position.');
    out=setValue(out,'open_orifices_neg',open_orifices_neg_new);

end