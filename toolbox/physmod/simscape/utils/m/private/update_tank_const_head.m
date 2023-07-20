function out=update_tank_const_head(hBlock)









    port_names={'V','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'press';
    'fluid_level';
    'pipe_diam';
    'loss_coeff';
    'g',};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
    params=HtoIL_cellToStruct(collected_params);


    volume=HtoIL_collect_vars(hBlock,{'volume'},'sh_lib/Low-Pressure Blocks/Constant Head Tank');
    reference_block=getSimulinkBlockHandle(get_param(hBlock,'ReferenceBlock'));


    params.p_atm.name='p_atm';
    params.p_atm.base='0.101325';
    params.p_atm.unit='MPa';
    params.p_atm.conf='runtime';

    params.rho.name='rho';
    params.rho.base='850';
    params.rho.unit='kg/m^3';
    params.rho.conf='runtime';




    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Reservoir (IL)')

    set_param(hBlock,'pressure_spec','2');

    math_expression='rho*g*fluid_level + press + p_atm';
    dialog_unit_expression='press';
    evaluate=0;
    reservoir_pressure=HtoIL_derive_params('reservoir_pressure',math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'reservoir_pressure'},reservoir_pressure);

    reservoir_port=get_param(hBlock,'PortHandles').LConn;



    orifice_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Orifice (IL)']);

    set_param(orifice_block,'orifice_type','1');
    set_param(orifice_block,'Re_c','15');

    params.loss_coeff.base=['sqrt(1/(',params.loss_coeff.base,'))'];
    params.loss_coeff.unit=['(',params.loss_coeff.unit,')^-0.5'];
    HtoIL_apply_params(orifice_block,{'Cd'},params.loss_coeff);

    orifice_area_constant=params.pipe_diam;
    orifice_area_constant.base=['pi/4*(',params.pipe_diam.base,')^2'];
    orifice_area_constant.unit=['(',params.pipe_diam.unit,')^2'];
    HtoIL_apply_params(orifice_block,{'orifice_area_constant'},orifice_area_constant);

    orifice_port_A=get_param(orifice_block,'PortHandles').LConn;
    orifice_port_B=get_param(orifice_block,'PortHandles').RConn;



    sensor_block=add_block('fl_lib/Isothermal Liquid/Sensors/Flow Rate Sensor (IL)',[connections.subsystem,'/Flow Rate Sensor (IL)']);

    set_param(sensor_block,'sensor_type','2');
    sensor_port_A=get_param(sensor_block,'PortHandles').LConn;
    sensor_port_B=get_param(sensor_block,'PortHandles').RConn(1);
    sensor_port_V=get_param(sensor_block,'PortHandles').RConn(2);



    integrator_block=add_block('fl_lib/Physical Signals/Linear Operators/PS Integrator',[connections.subsystem,'/PS Integrator']);

    if strcmp(volume.specify,'on')
        HtoIL_apply_params(integrator_block,{'x0'},volume);
    else
        default_initial_volume.base=get_param(reference_block,'volume');
        default_initial_volume.unit=get_param(reference_block,'volume_unit');
        default_initial_volume.conf='compiletime';
        HtoIL_apply_params(integrator_block,{'x0'},default_initial_volume);
    end
    integrator_inport=get_param(integrator_block,'PortHandles').LConn;
    integrator_outport=get_param(integrator_block,'PortHandles').RConn;



    add_line(connections.subsystem,reservoir_port,orifice_port_A);
    add_line(connections.subsystem,orifice_port_B,sensor_port_B);
    add_line(connections.subsystem,sensor_port_V,integrator_inport);


    connections.destination_ports=[integrator_outport,sensor_port_A];

    out.connections=connections;


    out.warnings.messages{1}=['Reservoir pressure assumed fluid density of ',params.rho.base,' ',params.rho.unit,'. Adjustment of Reservoir pressure may be required.'];
    out.warnings.subsystem=getfullname(hBlock);

end

