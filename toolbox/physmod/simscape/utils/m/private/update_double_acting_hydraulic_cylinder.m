function out=update_double_acting_hydraulic_cylinder(hBlock)









    displacement_spec=eval(get_param(hBlock,'displacement_spec'));
    if displacement_spec==1
        port_names={'C','A','R','B'};
    else
        port_names={'C','A','R','p','B'};
    end
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'area_A','piston_area_A';
    'area_B','piston_area_B';
    'stroke','stroke';
    'init_pos','x0';
    'dead_vol_A','dead_volume_A';
    'dead_vol_B','dead_volume_B'
    'init_pressure_A','p0_A';
    'init_pressure_B','p0_B';
    'stiff','stiff_coeff';
    'D','damping_coeff';
    'hardstop_model','hardstop_model';
    'transition','transition'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or=eval(get_param(hBlock,'or'));
    init_pos=get_param(hBlock,'init_pos');
    init_pressures=HtoIL_collect_params(hBlock,{'init_pressure_A';'init_pressure_B'});



    k_sh=get_param(hBlock,'k_sh');







    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Double-Acting Actuator (IL)')

    if displacement_spec==1
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,4,5]);
    else
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,4,3,5]);
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'smoothing_factor_A','0');
    set_param(hBlock,'smoothing_factor_B','0');




    p0(1)=HtoIL_gauge_to_abs('p0_A',init_pressures(1));
    p0(2)=HtoIL_gauge_to_abs('p0_B',init_pressures(2));
    HtoIL_apply_params(hBlock,{'p0_A';'p0_B'},p0);


    if or==1
        mech_orientation='1';
    else
        mech_orientation='-1';
    end
    set_param(hBlock,'mech_orientation',mech_orientation);


    if or==2

        set_param(hBlock,'x0',['-(',init_pos,')']);
    end




    if isempty(str2num(k_sh))%#ok<*ST2NM>
        k_sh=['''''',k_sh,''''''];
    end

    il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
    il_predefined_properties_block='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)'''' )" >Isothermal Liquid Predefined Properties (IL) block</a>';
    warnings.messages={['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,' or ',il_predefined_properties_block,'.']};

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
    out.connections=connections;

end

