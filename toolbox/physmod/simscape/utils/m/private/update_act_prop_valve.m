function out=update_act_prop_valve(hBlock)









    port_names={'I','O'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'gain';
    'time_constant';
    'saturation'};

    collected_params=HtoIL_collect_params(hBlock,param_list);
    params=HtoIL_cellToStruct(collected_params);


    HtoIL_set_block_files(hBlock,'fl_lib/Physical Signals/Functions/PS Subtract')
    set_param(hBlock,'name','PS Subtract');
    subtract_out_port=get_param(hBlock,'PortHandles').RConn;
    subtract_minus_in_port=get_param(hBlock,'PortHandles').LConn(2);


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);



    saturation_block=add_block('fl_lib/Physical Signals/Nonlinear Operators/PS Saturation',[connections.subsystem,'/PS Saturation']);

    HtoIL_apply_params(saturation_block,{'upper_limit'},params.saturation);
    lower_limit=params.saturation;
    lower_limit.base=['-(',lower_limit.base,')'];
    HtoIL_apply_params(saturation_block,{'lower_limit'},lower_limit);

    saturation_in_port=get_param(saturation_block,'PortHandles').LConn;
    saturation_out_port=get_param(saturation_block,'PortHandles').RConn;


    gain_block=add_block('fl_lib/Physical Signals/Functions/PS Gain',[connections.subsystem,'/PS Gain']);

    params.gain.unit='1/s';
    HtoIL_apply_params(gain_block,{'gain'},params.gain);

    gain_in_port=get_param(gain_block,'PortHandles').LConn;
    gain_out_port=get_param(gain_block,'PortHandles').RConn;


    integrator_block=add_block('fl_lib/Physical Signals/Linear Operators/PS Integrator',[connections.subsystem,'/PS Integrator']);
    set_param(integrator_block,'x0_unit','1');

    integrator_in_port=get_param(integrator_block,'PortHandles').LConn;
    integrator_out_port=get_param(integrator_block,'PortHandles').RConn;


    tf_block=add_block('fl_lib/Physical Signals/Linear Operators/PS Transfer Function',[connections.subsystem,'/PS Transfer Function']);

    HtoIL_apply_params(tf_block,{'T'},params.time_constant);


    tf_in_port=get_param(tf_block,'PortHandles').LConn;
    tf_out_port=get_param(tf_block,'PortHandles').RConn;



    add_line(connections.subsystem,subtract_out_port,saturation_in_port,'autorouting','on');
    add_line(connections.subsystem,saturation_out_port,gain_in_port,'autorouting','on');
    add_line(connections.subsystem,gain_out_port,integrator_in_port,'autorouting','on');
    add_line(connections.subsystem,integrator_out_port,tf_in_port,'autorouting','on');
    add_line(connections.subsystem,tf_out_port,subtract_minus_in_port,'autorouting','on');

    out.connections=connections;

    out.warnings.subsystem=connections.subsystem;
    out.warnings.messages={'Converted subsystem assumes input and output signals have units of 1. Adjustment of input and output PS signal units may be required.'};
end

