function out=update_vert_pipe_partially_filled(hBlock)









    port_names={'V','A','L','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={'length_ad','length_add';
    's_factor','shape_factor'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));










    params_for_derivation=HtoIL_collect_params(hBlock,{'cs_type';'d_in';'D_h';'elevation_A';'elevation_B';'minimum_volume'});
    params=HtoIL_cellToStruct(params_for_derivation);


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Partially Filled Pipe (IL)');
    A_port=get_param(hBlock,'PortHandles').LConn(2);
    B_port=get_param(hBlock,'PortHandles').RConn(2);
    AL_port=get_param(hBlock,'PortHandles').LConn(1);
    L_port=get_param(hBlock,'PortHandles').RConn(1);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'level_check','1');





    if strcmp(params.cs_type.base,'1')
        area=params.d_in;
        area.base=['pi/4*(',params.d_in.base,')^2'];
        area.unit=['(',params.d_in.unit,')^2'];
        HtoIL_apply_params(hBlock,{'area'},area);
        Dh=params.d_in;
    else

        Dh=params.D_h;
    end
    HtoIL_apply_params(hBlock,{'Dh'},Dh);


    name='elevation_drop';
    math_expression='elevation_A - elevation_B';
    dialog_unit_expression='elevation_A';
    evaluate=0;
    elevation_drop=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'elevation_drop'},elevation_drop);
    HtoIL_apply_params(hBlock,{'level_init'},elevation_drop);




    subtract_block=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[connections.subsystem,'/PS Subtract']);
    subtract_add_input=get_param(subtract_block,'PortHandles').LConn(1);
    subtract_minus_input=get_param(subtract_block,'PortHandles').LConn(2);
    subtract_output=get_param(subtract_block,'PortHandles').RConn;


    divide_block=add_block('fl_lib/Physical Signals/Functions/PS Divide',[connections.subsystem,'/PS Divide']);
    divide_mult_input=get_param(divide_block,'PortHandles').LConn(1);
    divide_div_input=get_param(divide_block,'PortHandles').LConn(2);
    divide_output=get_param(divide_block,'PortHandles').RConn;


    min_volume_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/Tank Minimum Volume']);
    HtoIL_apply_params(min_volume_block,{'constant'},params.minimum_volume);
    min_volume_port=get_param(min_volume_block,'PortHandles').RConn;


    tank_area_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/Tank Cross-sectional Area']);
    set_param(tank_area_block,'constant_unit','m^2');
    tank_area_port=get_param(tank_area_block,'PortHandles').RConn;


    add_line(connections.subsystem,min_volume_port,subtract_minus_input);
    add_line(connections.subsystem,subtract_output,divide_mult_input);
    add_line(connections.subsystem,tank_area_port,divide_div_input);
    add_line(connections.subsystem,divide_output,AL_port);


    connections.destination_ports=[subtract_add_input,A_port,L_port,B_port];
    out.connections=connections;


    out.warnings.subsystem=getfullname(hBlock);
    tank_block_hyperlink='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Tanks & Accumulators'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Tanks & Accumulators/Tank (IL)'''' )" > Tank (IL) </a>';
    out.warnings.messages{1}=['Tank liquid volume input signal, V, converted to relative liquid level of '...
    ,'connected block, AL, by assuming a constant '...
    ,'tank cross-sectional area of 1 m^2. Connect AL to the liquid level '...
    ,'output, L, of a',tank_block_hyperlink,'block or another Partially Filled Pipe (IL) block, '...
    ,'or adjust the assumed Tank cross-sectional area.'];


end