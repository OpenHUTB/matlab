function out=update_pipe_res_low_press(hBlock)





    out=struct;


    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.low_pressure_blocks.pipe_res_low_press')
        elevations=HtoIL_collect_params(hBlock,{'elevation_A';'elevation_B'});

    else





        port_names={'el_A','A','el_B','B'};
        [out.connections.subsystem,out.connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    end





    param_list={...
    'd_in','pipe_diameter';...
    'area','pipe_area';...
    'D_h','Dh';...
    's_factor','shape_factor';...
    'length','pipe_length';...
    'length_ad','length_add';...
    'roughness','roughness';...
    'Re_lam','Re_lam';...
    'Re_turb','Re_tur'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));





    cross_sect_type=get_param(hBlock,'cs_type');


    beginning_variables=HtoIL_collect_vars(hBlock,{'pressure_drop';'flow_rate'},'sh_lib/Low-Pressure Blocks/Resistive Pipe LP');
    beginning_variable_names={'Pressure drop from port A to port B';'Flow rate from port A to port B'};



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Pipe (IL)')


    set_param(hBlock,'dynamic_compressibility','simscape.enum.onoff.off');

    if strcmp(cross_sect_type,'1')
        set_param(hBlock,'cross_section_geometry','fluids.isothermal_liquid.pipes_fittings.enum.cross_section_geometry.circular');
    else
        set_param(hBlock,'cross_section_geometry','fluids.isothermal_liquid.pipes_fittings.enum.cross_section_geometry.custom');
    end




    if strcmp(SourceFile,'sh.low_pressure_blocks.pipe_res_low_press')




        params=HtoIL_cellToStruct(elevations);
        name='elevation_gain';
        math_expression='elevation_B - elevation_A';
        dialog_unit_expression='elevation_B';
        evaluate=0;
        elevation_gain=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'elevation_gain'},elevation_gain);

    else


        set_param(hBlock,'elevation_spec','foundation.enum.constant_variable.variable');


        subtract_block=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[out.connections.subsystem,'/PS Subtract']);

        subtract_pos_in_port=get_param(subtract_block,'PortHandles').LConn(1);
        subtract_neg_in_port=get_param(subtract_block,'PortHandles').LConn(2);
        subtract_out_port=get_param(subtract_block,'PortHandles').RConn;


        pipe_A_port=get_param(hBlock,'PortHandles').LConn(1);
        pipe_EL_port=get_param(hBlock,'PortHandles').LConn(2);
        pipe_B_port=get_param(hBlock,'PortHandles').RConn;


        add_line(out.connections.subsystem,subtract_out_port,pipe_EL_port);


        out.connections.destination_ports=[subtract_neg_in_port,pipe_A_port,subtract_pos_in_port,pipe_B_port];

    end






    set_param(hBlock,'roughness_spec','fluids.isothermal_liquid.pipes_fittings.enum.roughness_spec.custom');





    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    warnings.messages={};
    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);
    warnings.subsystem=getfullname(hBlock);

    if~isempty(warnings.messages)
        out.warnings=warnings;
    end

end

