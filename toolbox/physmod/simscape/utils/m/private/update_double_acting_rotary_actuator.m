function out=update_double_acting_rotary_actuator(hBlock)









    port_names={'A','B','S'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'displ','volume_displacement_A';
    'displ','volume_displacement_B';
    'stroke','stroke';
    'dead_vol_A','dead_volume_A';
    'dead_vol_B','dead_volume_B';
    'stiff','stiff_coeff';
    'damp','damping_coeff';
    'hardstop_model','hardstop_model';
    'transition','transition';
    'or',''};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));



    leak_coeff=HtoIL_collect_params(hBlock,{'leak_coeff'});
    or=get_param(hBlock,'or');
    init_ang=HtoIL_collect_params(hBlock,{'init_ang'});


    k_sh=get_param(hBlock,'k_sh');






    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Double-Acting Rotary Actuator (IL)')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,5,4]);



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational_Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    actuator_ports=get_param(hBlock,'PortHandles');
    actuator_C_port=actuator_ports.LConn(1);
    add_line(connections.subsystem,actuator_C_port,rotational_reference_port,'autorouting','on');


    leak_coeff.value=str2double(leak_coeff.base);
    if isnan(leak_coeff.value)||leak_coeff.value>0

        laminar_leakage_block=add_block('fl_lib/Isothermal Liquid/Elements/Laminar Leakage (IL)',[connections.subsystem,'/Laminar Leakage (IL)']);
        laminar_leakage_port_A=get_param(laminar_leakage_block,'PortHandles').LConn;
        laminar_leakage_port_B=get_param(laminar_leakage_block,'PortHandles').RConn;
        actuator_port_A=actuator_ports.LConn(2);
        actuator_port_B=actuator_ports.RConn(3);
        add_line(connections.subsystem,actuator_port_A,laminar_leakage_port_A,'autorouting','on');
        add_line(connections.subsystem,actuator_port_B,laminar_leakage_port_B,'autorouting','on');


        set_param(laminar_leakage_block,'cross_section_geometry','6');

        resistance.base=['1/(',leak_coeff.base,')'];
        resistance.unit=['(',leak_coeff.unit,')^-1'];
        resistance.conf=leak_coeff.conf;
        HtoIL_apply_params(laminar_leakage_block,{'resistance'},resistance);

    end



    if strcmp(or,'1')
        mech_orientation='1';
    else
        mech_orientation='-1';
        init_ang.base=['-(',init_ang.base,')'];
    end
    set_param(hBlock,'mech_orientation',mech_orientation);
    HtoIL_apply_params(hBlock,{'theta0'},init_ang);





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

