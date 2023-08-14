function out=update_reservoir(hBlock)











    port_names={'V','P','R'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    params_for_derivation=HtoIL_collect_params(hBlock,{'press';'init_volume';'ret_diam';'loss_coeff'});
    params=HtoIL_cellToStruct(params_for_derivation);


    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Reservoir (IL)');
    set_param(hBlock,'pressure_spec','2');
    reservoir_pressure=HtoIL_gauge_to_abs('reservoir_pressure',params.press);
    HtoIL_apply_params(hBlock,{'reservoir_pressure'},reservoir_pressure);
    reservoir_port_A=get_param(hBlock,'PortHandles').LConn;


    sensor_block=add_block('fl_lib/Isothermal Liquid/Sensors/Flow Rate Sensor (IL)',[connections.subsystem,'/Flow Rate Sensor (IL)']);
    set_param(sensor_block,'sensor_type','2');
    sensor_port_A=get_param(sensor_block,'PortHandles').LConn;
    sensor_port_B=get_param(sensor_block,'PortHandles').RConn(1);
    sensor_port_V=get_param(sensor_block,'PortHandles').RConn(2);


    integrator_block=add_block('fl_lib/Physical Signals/Linear Operators/PS Integrator',[connections.subsystem,'/PS Integrator']);
    HtoIL_apply_params(integrator_block,{'x0'},params.init_volume);
    integrator_input=get_param(integrator_block,'PortHandles').LConn;
    integrator_output=get_param(integrator_block,'PortHandles').RConn;


    resistance_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Local Resistance (IL)',[connections.subsystem,'/Local Resistance (IL)']);
    HtoIL_apply_params(resistance_block,{'loss_coeff_AB'},params.loss_coeff);
    HtoIL_apply_params(resistance_block,{'loss_coeff_BA'},params.loss_coeff);
    set_param(resistance_block,'Re_c','15');

    flow_area.base=['pi*(',params.ret_diam.base,')^2/4'];
    flow_area.unit=['(',params.ret_diam.unit,')^2'];
    flow_area.conf=params.ret_diam.conf;
    HtoIL_apply_params(resistance_block,{'flow_area'},flow_area);
    HtoIL_apply_params(integrator_block,{'x0'},params.init_volume);
    resistance_port_A=get_param(resistance_block,'PortHandles').LConn;
    resistance_port_B=get_param(resistance_block,'PortHandles').RConn;


    add_line(connections.subsystem,reservoir_port_A,sensor_port_B,'autorouting','on');
    add_line(connections.subsystem,sensor_port_V,integrator_input,'autorouting','on');
    add_line(connections.subsystem,sensor_port_A,resistance_port_B,'autorouting','on');



    connections.destination_ports=[integrator_output,sensor_port_A,resistance_port_A];

    out.connections=connections;

end