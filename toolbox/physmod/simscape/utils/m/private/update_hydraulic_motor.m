function out=update_hydraulic_motor(hBlock)










    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.pumps_motors.hydraulic_motor')
        port_names={'A','B','S'};
    elseif strcmp(SourceFile,'sh.pumps_motors.fx_displ_motor_ext_efficiencies')
        port_names={'EV','EM','A','B','S'};
    else
        port_names={'LV','LM','A','B','S'};
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


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Fixed-Displacement Motor (IL)')


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



    if strcmp(SourceFile,'sh.pumps_motors.hydraulic_motor')
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,4,2]);
    elseif strcmp(SourceFile,'sh.pumps_motors.fx_displ_motor_ext_efficiencies')

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_efficiency');

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3,6,4]);
    else

        set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_loss');

        switch quadCheck
        case '0'
            set_param(hBlock,'motor_mode_check','simscape.enum.assert.action.none');
        case '1'
            set_param(hBlock,'motor_mode_check','simscape.enum.assert.action.warn');
        end

        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3,6,4]);
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    p_min_valid=HtoIL_gauge_to_abs('min_valid_pressure',min_valid_pressure);
    HtoIL_apply_params(hBlock,{'p_min_valid'},p_min_valid);


    mech_eff_nominal=HtoIL_compute_mech_eff_nominal(params,'fixed_motor');
    HtoIL_apply_params(hBlock,{'mech_eff_nominal'},mech_eff_nominal);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    pump_ports=get_param(hBlock,'PortHandles');
    pump_C_port=pump_ports.RConn(2);
    add_line(connections.subsystem,pump_C_port,rotational_reference_port,'autorouting','on');


    if strcmp(lossSpec,'1')&&strcmp(SourceFile,'sh.pumps_motors.hydraulic_motor')
        warnings.messages={'Nominal fluid density and kinematic viscosity removed. Motor uses network fluid properties. Adjustment of Volumetric efficiency at nominal conditions may be required.'};
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end

    out.connections=connections;
end

