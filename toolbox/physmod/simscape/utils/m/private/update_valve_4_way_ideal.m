function out=update_valve_4_way_ideal(hBlock)








    port_names={'A','B','S','P'};
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={'opening_max','del_S_max';
    'C_d','Cd';
    'opening_max','S_max_PA';
    'opening_max','S_max_BT'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    opening_max=HtoIL_collect_params(hBlock,{'opening_max'});






    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/4-Way 3-Position Directional Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');
    set_param(hBlock,'neutral_assert_action','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    S_max_neg_orifice=opening_max;
    S_max_neg_orifice.base=['-(',opening_max.base,')'];
    HtoIL_apply_params(hBlock,{'S_max_PB'},S_max_neg_orifice);
    HtoIL_apply_params(hBlock,{'S_max_AT'},S_max_neg_orifice);


    valve_port_S=get_param(hBlock,'PortHandles').LConn(1);
    valve_port_A=get_param(hBlock,'PortHandles').LConn(2);
    valve_port_B=get_param(hBlock,'PortHandles').LConn(3);
    valve_port_P=get_param(hBlock,'PortHandles').RConn(1);
    valve_port_T=get_param(hBlock,'PortHandles').RConn(2);





    reservoir_block=add_block('fl_lib/Isothermal Liquid/Elements/Reservoir (IL)',[connections.subsystem,'/Reservoir (IL)']);
    reservoir_port=get_param(reservoir_block,'PortHandles').LConn;


    pressure_source_block=add_block('fl_lib/Isothermal Liquid/Sources/Pressure Source (IL)',[connections.subsystem,'/Pressure Source (IL)']);
    pressure_source_port_A=get_param(pressure_source_block,'PortHandles').LConn(1);
    pressure_source_port_B=get_param(pressure_source_block,'PortHandles').RConn;
    pressure_source_port_P=get_param(pressure_source_block,'PortHandles').LConn(2);



    add_line(connections.subsystem,pressure_source_port_A,reservoir_port);
    add_line(connections.subsystem,valve_port_T,reservoir_port);
    add_line(connections.subsystem,pressure_source_port_B,valve_port_P);


    connections.destination_ports=[valve_port_A,valve_port_B,valve_port_S,pressure_source_port_P];



    warnings.subsystem=getfullname(hBlock);
    leakage_area_val=get_param(hBlock,'area_leak');
    leakage_area_unit=get_param(hBlock,'area_leak_unit');
    Re_c_val=get_param(hBlock,'Re_c');
    warnings.messages{1}=['Block replaced with a 4-Way Directional Valve (IL) with Leakage area of ',leakage_area_val,' ',leakage_area_unit,' and Critical Reynolds number of ',Re_c_val,'. Behavior change not expected.'];


    out.warnings=warnings;
    out.connections=connections;

end