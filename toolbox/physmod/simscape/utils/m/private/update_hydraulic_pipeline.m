function out=update_hydraulic_pipeline(hBlock)







    param_list={...
    'd_in','pipe_diameter';...
    'area','pipe_area';...
    'D_h','Dh';...
    's_factor','shape_factor';...
    'length','pipe_length';...
    'length_ad','length_add';...
    'roughness','roughness';...
    'Re_lam','Re_lam';...
    'Re_turb','Re_tur';...
    'pr_r_coef','diameter_pressure_gain';...
    'time_const','wall_time_constant'};



    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.pipelines.pipeline_hyd')
        initial_pressure_name='initial_pressure';

    elseif strcmp(SourceFile,'sh.low_pressure_blocks.pipe_low_press')
        initial_pressure_name='p0';

        elevations=HtoIL_collect_params(hBlock,{'elevation_A';'elevation_B'});

    else
        initial_pressure_name='p0';






        port_names={'el_A','A','el_B','B'};
        [out.connections.subsystem,out.connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    end


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
    p_init_gauge=HtoIL_collect_params(hBlock,{initial_pressure_name});
    cross_sect_type=eval(get_param(hBlock,'cs_type'));
    s_factor=get_param(hBlock,'s_factor');
    wall_type=eval(get_param(hBlock,'wall_type'));
    k_sh=get_param(hBlock,'k_sh');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Pipe (IL)')








    if cross_sect_type==1
        set_param(hBlock,'cross_section_geometry','fluids.isothermal_liquid.pipes_fittings.enum.cross_section_geometry.circular');
    else
        set_param(hBlock,'cross_section_geometry','fluids.isothermal_liquid.pipes_fittings.enum.cross_section_geometry.custom');
    end




    if strcmp(SourceFile,'sh.low_pressure_blocks.pipe_low_press')

        params=HtoIL_cellToStruct(elevations);
        name='elevation_gain';
        math_expression='elevation_B - elevation_A';
        dialog_unit_expression='elevation_B';
        evaluate=0;
        elevation_gain=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'elevation_gain'},elevation_gain);

    elseif strcmp(SourceFile,'sh.low_pressure_blocks.pipe_low_press_var_elevation')

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


    if wall_type==1
        set_param(hBlock,'pipe_wall_spec','fluids.isothermal_liquid.pipes_fittings.enum.wall_spec.rigid');
    else
        set_param(hBlock,'pipe_wall_spec','fluids.isothermal_liquid.pipes_fittings.enum.wall_spec.flexible');
        set_param(hBlock,'vol_expansion_spec','fluids.isothermal_liquid.pipes_fittings.enum.vol_expansion_spec.diameter');
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    p_init_abs=HtoIL_gauge_to_abs('p0',p_init_gauge);
    HtoIL_apply_params(hBlock,{'p0'},p_init_abs);






    if isempty(str2num(k_sh))%#ok<*ST2NM>
        k_sh=['''''',k_sh,''''''];
    end

    il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
    il_predefined_properties_block='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)'''' )" >Isothermal Liquid Predefined Properties (IL) block</a>';
    warnings.messages={['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,' or ',il_predefined_properties_block,'.']};




    if isempty(str2num(s_factor))%#ok<*ST2NM>
        s_factor=['''''',s_factor,''''''];
    end
    if cross_sect_type==1&&~strcmp(s_factor,'64')
        warnings.messages{end+1,1}=['Original block had Laminar friction constant for Dary friction factor of ',s_factor,'. '...
        ,'Pipe with Circular Cross-sectional geometry uses Laminar friction constant of 64. Set Cross-sectional geometry to Custom '...
        ,'to specify Laminar friction constant for Darcy friciton factor.'];
    end

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
end



