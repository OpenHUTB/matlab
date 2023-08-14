function out=update_fx_displ_pump(hBlock)










    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.pumps_motors.fx_displ_pump')
        port_names={'S','P','T'};
    elseif strcmp(SourceFile,'sh.pumps_motors.fixed_displacement_pump_input_efficiency')
        port_names={'EV','S','EM','P','T'};
    else
        port_names={'LV','S','LM','P','T'};
    end

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'D','displacement';
    'pr_nominal','p_nominal';
    'w_nominal','omega_nominal';
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
    {'torque_pressure_coeff';'D';'pr_nominal';'no_load_torque'});
    params=HtoIL_cellToStruct(params_for_derivation);



    lossSpec=get_param(hBlock,'loss_spec');
    quadCheck=get_param(hBlock,'quadrant_check');
    pressCheck=get_param(hBlock,'pressure_check');


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    min_valid_pressure=HtoIL_collect_params(hBlock,{'min_valid_pressure'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Fixed-Displacement Pump (IL)')


    switch lossSpec
    case '1'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.analytical');
    case '2'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.table_efficiency');
    case '3'
        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.table_loss');
    end
    switch quadCheck
    case '0'
        set_param(hBlock,'quadrant_check','simscape.enum.assert.action.none');
    case '1'
        set_param(hBlock,'quadrant_check','simscape.enum.assert.action.warn');
    end
    switch pressCheck
    case '0'
        set_param(hBlock,'pressure_check','simscape.enum.assert.action.none');
    case '1'
        set_param(hBlock,'pressure_check','simscape.enum.assert.action.warn');
    end



    if strcmp(SourceFile,'sh.pumps_motors.fx_displ_pump')
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,4]);
    elseif strcmp(SourceFile,'sh.pumps_motors.fixed_displacement_pump_input_efficiency')

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_efficiency');

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,4,2,3,6]);
    else

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_loss');

        switch quadCheck
        case '0'
            set_param(hBlock,'pump_mode_check','simscape.enum.assert.action.none');
        case '1'
            set_param(hBlock,'pump_mode_check','simscape.enum.assert.action.warn');
        end

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,4,2,3,6]);
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    p_min_valid=HtoIL_gauge_to_abs('min_valid_pressure',min_valid_pressure);
    HtoIL_apply_params(hBlock,{'p_min_valid'},p_min_valid);


    mech_eff_nominal=HtoIL_compute_mech_eff_nominal(params,'fixed_pump');
    HtoIL_apply_params(hBlock,{'mech_eff_nominal'},mech_eff_nominal);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    pump_ports=get_param(hBlock,'PortHandles');
    pump_C_port=pump_ports.RConn(2);
    add_line(connections.subsystem,pump_C_port,rotational_reference_port,'autorouting','on');


    if strcmp(lossSpec,'1')&&strcmp(SourceFile,'sh.pumps_motors.fx_displ_pump')
        warnings.messages={'Nominal fluid density and kinematic viscosity removed. Pump uses network fluid properties. Adjustment of Volumetric efficiency at nominal conditions may be required.'};
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end

    out.connections=connections;

end

