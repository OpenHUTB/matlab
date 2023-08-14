function out=update_motor_var_displ(hBlock)










    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.pumps_motors.motor_var_displ')
        port_names={'A','C','B','S'};
    elseif strcmp(SourceFile,'sh.pumps_motors.variable_displacement_motor_input_efficiency')
        port_names={'A','EV','EM','D','B','S'};
    else
        port_names={'A','LV','LM','D','B','S'};
    end

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'pr_nominal','p_nominal';
    'w_nominal','omega_nominal';
    'D_max','displacement_nominal';
    'efficiency_vol','vol_eff_nominal';
    'no_load_torque','no_load_torque';
    'p_diff_eff_TLU','p_diff_eff_TLU';
    'omega_eff_TLU','omega_eff_TLU';
    'vol_eff_TLU','vol_eff_TLU';
    'mech_eff_TLU','mech_eff_TLU';
    'p_diff_loss_TLU','p_diff_loss_TLU';
    'omega_loss_TLU','omega_loss_TLU';
    'vol_loss_TLU','vol_loss_TLU';
    'mech_loss_TLU','mech_loss_TLU';
    'pressure_threshold','pressure_threshold';
    'omega_threshold','omega_threshold';
    'vol_eff_min','vol_eff_min';
    'vol_eff_max','vol_eff_max';
    'mech_eff_min','mech_eff_min';
    'mech_eff_max','mech_eff_max'};


    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'torque_pressure_coeff';'D_max';'pr_nominal';'no_load_torque'});
    params=HtoIL_cellToStruct(params_for_derivation);



    modelType=get_param(hBlock,'mdl_type');
    lossSpec=get_param(hBlock,'loss_spec');
    octCheck=get_param(hBlock,'octant_check');
    pressCheck=get_param(hBlock,'pressure_check');


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    min_valid_pressure=HtoIL_collect_params(hBlock,{'min_valid_pressure'});


    params_derivation=HtoIL_cellToStruct(HtoIL_collect_params(hBlock,{'stroke_max','D_max'}));


    table1d_x=HtoIL_collect_params(hBlock,{'cntrl_mem_tab'});
    table1d_y=HtoIL_collect_params(hBlock,{'displ_tab'});
    interp_method=HtoIL_collect_params(hBlock,{'interp_method'});
    extrap_method=HtoIL_collect_params(hBlock,{'extrap_method'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Variable-Displacement Motor (IL)')


    switch lossSpec
    case '1'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.analytical');
    case '2'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.table_efficiency');
    case '3'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.table_loss');
    end
    switch octCheck
    case '0'
        set_param(hBlock,'octant_check','simscape.enum.assert.action.none');
    case '1'
        set_param(hBlock,'octant_check','simscape.enum.assert.action.warn');
    end
    switch pressCheck
    case '0'
        set_param(hBlock,'pressure_check','simscape.enum.assert.action.none');
    case '1'
        set_param(hBlock,'pressure_check','simscape.enum.assert.action.warn');
    end



    if strcmp(SourceFile,'sh.pumps_motors.motor_var_displ')
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,5,3]);
    elseif strcmp(SourceFile,'sh.pumps_motors.variable_displacement_motor_input_efficiency')

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_efficiency');

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,2,3,1,7,5]);
    else

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_loss');

        switch octCheck
        case '0'
            set_param(hBlock,'motor_mode_check','simscape.enum.assert.action.none');
        case '1'
            set_param(hBlock,'motor_mode_check','simscape.enum.assert.action.warn');
        end

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,2,3,1,7,5]);
    end



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    p_min_valid=HtoIL_gauge_to_abs('min_valid_pressure',min_valid_pressure);
    HtoIL_apply_params(hBlock,{'p_min_valid'},p_min_valid);


    mech_eff_nominal=HtoIL_compute_mech_eff_nominal(params,'variable_motor');
    HtoIL_apply_params(hBlock,{'mech_eff_nominal'},mech_eff_nominal);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    motor_ports=get_param(hBlock,'PortHandles');
    motor_C_port=motor_ports.RConn(2);
    add_line(connections.subsystem,motor_C_port,rotational_reference_port,'autorouting','on');


    if strcmp(SourceFile,'sh.pumps_motors.motor_var_displ')


        ps_sat_block=add_block('fl_lib/Physical Signals/Nonlinear Operators/PS Saturation',[connections.subsystem,'/Maximum displacement']);
        ps_sat_port_in=get_param(ps_sat_block,'PortHandles').LConn;
        ps_sat_port_out=get_param(ps_sat_block,'PortHandles').RConn;

        HtoIL_apply_params(ps_sat_block,{'upper_limit'},params_derivation.D_max);
        lower_limit=params_derivation.D_max;
        lower_limit.base=['-(',params_derivation.D_max.base,')'];
        HtoIL_apply_params(ps_sat_block,{'lower_limit'},lower_limit);


        if strcmp(modelType,'1')
            ps_block=add_block('fl_lib/Physical Signals/Functions/PS Gain',[connections.subsystem,'/stroke2disp']);
            ps_port_in=get_param(ps_block,'PortHandles').LConn;
            ps_port_out=get_param(ps_block,'PortHandles').RConn;
            motor_ports=get_param(hBlock,'PortHandles');
            motor_D_port=motor_ports.LConn(1);


            name='gain';
            math_expression='D_max/stroke_max';
            dialog_unit_expression='D_max/stroke_max';
            evaluate=0;
            gain=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

            HtoIL_apply_params(ps_block,{'gain'},gain);

        else

            ps_block=add_block('fl_lib/Physical Signals/Lookup Tables/PS Lookup Table (1D)',[connections.subsystem,'/stroke2disp']);
            ps_port_in=get_param(ps_block,'PortHandles').LConn;
            ps_port_out=get_param(ps_block,'PortHandles').RConn;
            motor_ports=get_param(hBlock,'PortHandles');
            motor_D_port=motor_ports.LConn(1);


            HtoIL_apply_params(ps_block,{'x'},table1d_x);
            HtoIL_apply_params(ps_block,{'f'},table1d_y);
            HtoIL_apply_params(ps_block,{'interp_method'},interp_method);
            HtoIL_apply_params(ps_block,{'extrap_method'},extrap_method);
        end


        add_line(connections.subsystem,ps_port_out,ps_sat_port_in);
        add_line(connections.subsystem,ps_sat_port_out,motor_D_port);
        connections.destination_ports(2)=ps_port_in;
    end


    if strcmp(SourceFile,'sh.pumps_motors.motor_var_displ')&&strcmp(lossSpec,'1')
        warnings.messages{1,1}='Nominal fluid density and kinematic viscosity removed. Motor uses network fluid properties. Adjustment of Volumetric efficiency at nominal conditions may be required.';
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end

    out.connections=connections;

end

