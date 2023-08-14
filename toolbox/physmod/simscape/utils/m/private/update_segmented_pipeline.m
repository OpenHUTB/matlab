function out=update_segmented_pipeline(hBlock)







    param_list={...
    'd_in','pipe_diameter';...
    'length','pipe_length';...
    'segm_num','num_segments';...
    'length_ad','length_add';...
    'roughness','roughness';...
    'Re_lam','Re_lam';...
    'Re_turb','Re_tur';...
    'pr_r_coef','diameter_pressure_gain';...
    'time_const','wall_time_constant'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
    wall_type=eval(get_param(hBlock,'wall_type'));
    k_sh=get_param(hBlock,'k_sh');


    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.pipelines.pipeline_hyd_segm')
        init_pr_option=eval(get_param(hBlock,'init_pr_option'));
        if init_pr_option==1
            p_init_gauge=HtoIL_collect_params(hBlock,{'initial_pressure'});
        else
            p_init_gauge=HtoIL_collect_params(hBlock,{'initial_pressure_vector'});
        end


        flow_rate=HtoIL_collect_params(hBlock,{'initial_flow_rate'});

    else
        p_init_gauge=HtoIL_collect_params(hBlock,{'p0_vec'});


        flow_rate=HtoIL_collect_params(hBlock,{'q0'});

        flow_rate.name='initial_flow_rate';

        elevations=HtoIL_collect_params(hBlock,{'elevation_A';'elevation_B'});
    end

    params_derivation=HtoIL_cellToStruct(flow_rate);

    params_derivation.rho.name='rho';
    params_derivation.rho.base='850';
    params_derivation.rho.unit='kg/m^3';
    params_derivation.rho.conf='compiletime';



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Pipe (IL)')




    set_param(hBlock,'inertia','simscape.enum.onoff.on');





    if strcmp(SourceFile,'sh.low_pressure_blocks.pipe_low_press_segm')
        params=HtoIL_cellToStruct(elevations);
        name='elevation_gain';
        math_expression='elevation_B - elevation_A';
        dialog_unit_expression='elevation_B';
        evaluate=0;
        elevation_gain=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'elevation_gain'},elevation_gain);
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


    name='mdot0';
    math_expression='initial_flow_rate*rho';
    dialog_unit_expression='initial_flow_rate*rho';
    evaluate=false;
    mdot0=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


    HtoIL_apply_params(hBlock,{'mdot0'},mdot0);


    warnings.messages{1}=['Initial mass flow rate from port A to port B set to Initial volumetric flow rate * ',params_derivation.rho.base,' ',params_derivation.rho.unit,'. '...
    ,'Adjustment of Initial mass flow rate may be required.'];



    if isempty(str2num(k_sh))%#ok<*ST2NM>
        k_sh=['''''',k_sh,''''''];
    end

    il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
    il_predefined_properties_block='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)'''' )" >Isothermal Liquid Predefined Properties (IL) block</a>';
    warnings.messages{2}=['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,' or ',il_predefined_properties_block,'.'];

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
end



