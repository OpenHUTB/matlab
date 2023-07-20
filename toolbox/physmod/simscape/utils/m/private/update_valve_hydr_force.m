function out=update_valve_hydr_force(hBlock)








    port_names={'A','S','B','F'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    lookup_table_param_list={...
    'opening_tab','x2'
    'pressure_tab','x1'
    'force_tab','f'};





    collected_params=HtoIL_collect_params(hBlock,lookup_table_param_list(:,1));


    x_0=HtoIL_collect_params(hBlock,{'x_0'});
    or=eval(get_param(hBlock,'or'));



    HtoIL_set_block_files(hBlock,'fl_lib/Physical Signals/Lookup Tables/PS Lookup Table (2D)')


    HtoIL_apply_params(hBlock,lookup_table_param_list(:,2),collected_params);

    TLU_port_x1=get_param(hBlock,'PortHandles').LConn(1);
    TLU_port_x2=get_param(hBlock,'PortHandles').LConn(2);
    TLU_outport=get_param(hBlock,'PortHandles').RConn;


    if or~=1

        gain_block=add_block('fl_lib/Physical Signals/Functions/PS Gain',[connections.subsystem,'/PS Gain']);
        set_param(gain_block,'gain','-1');
        gain_in_port=get_param(gain_block,'PortHandles').LConn;
        gain_out_port=get_param(gain_block,'PortHandles').RConn;
    end


    if or==1

        sum_block=add_block('fl_lib/Physical Signals/Functions/PS Add',[connections.subsystem,'/PS Add']);
    else

        sum_block=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[connections.subsystem,'/PS Subtract']);
    end

    sum_top_port=get_param(sum_block,'PortHandles').LConn(1);
    sum_bot_port=get_param(sum_block,'PortHandles').LConn(2);
    sum_out_port=get_param(sum_block,'PortHandles').RConn;


    x0_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/Initial opening']);

    HtoIL_apply_params(x0_block,{'constant'},x_0);

    x0_port=get_param(x0_block,'PortHandles').RConn;


    sensor_block=add_block('fl_lib/Isothermal Liquid/Sensors/Pressure Sensor (IL)',[connections.subsystem,'/Pressure Sensor (IL)']);
    sensor_port_A=get_param(sensor_block,'PortHandles').LConn;
    sensor_port_B=get_param(sensor_block,'PortHandles').RConn(1);
    sensor_port_P=get_param(sensor_block,'PortHandles').RConn(2);


    add_line(connections.subsystem,x0_port,sum_top_port);
    add_line(connections.subsystem,sum_out_port,TLU_port_x2);
    add_line(connections.subsystem,sensor_port_P,TLU_port_x1);

    if or==1

        connections.destination_ports=[sensor_port_A,sum_bot_port,sensor_port_B,TLU_outport];
    else
        add_line(connections.subsystem,TLU_outport,gain_in_port);
        connections.destination_ports=[sensor_port_A,sum_bot_port,sensor_port_B,gain_out_port];
    end

    out.connections=connections;

end



