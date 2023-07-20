function out=update_double_actuator_H_G(hBlock)








    port_names={'C','A','p','H','R','B'};
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'compressibility','dynamic_compressibility';
    'environment_spec','environment_spec_B'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    mech_orientation=eval(get_param(hBlock,'mech_orientation'));
    p0_A=HtoIL_collect_params(hBlock,{'p0_A'});
    piston_measurement=eval(get_param(hBlock,'piston_measurement'));
    compressibility=eval(get_param(hBlock,'compressibility'));
    k_sh=get_param(hBlock,'k_sh');
    x0=HtoIL_collect_params(hBlock,{'x0'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Fluid Network Interfaces/Actuators/Double-Acting Actuator (G-IL)')





    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,5,2,3,4,6]);



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    p0_A=HtoIL_gauge_to_abs('p0_A',p0_A);
    HtoIL_apply_params(hBlock,{'p0_A'},p0_A);


    if mech_orientation==-1
        x0.base=['-(',x0.base,')'];
        set_param(hBlock,'x0',x0.base);
    end


    if piston_measurement==2

        PS_subtract=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[connections.subsystem,'/PS Subtract']);
        PS_subtract_ports=get_param(PS_subtract,'PortHandles');


        pos_subtract_port=PS_subtract_ports.LConn(1);
        actuator_p_port=get_param(hBlock,'PortHandles').LConn(2);
        add_line(connections.subsystem,actuator_p_port,pos_subtract_port,'autorouting','on');


        const_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',...
        [connections.subsystem,'/Initial piston displacement',newline,'from chamber A cap']);
        HtoIL_apply_params(const_block,{'constant'},x0);
        const_port=get_param(const_block,'PortHandles').RConn;
        neg_subtract_port=PS_subtract_ports.LConn(2);
        add_line(connections.subsystem,const_port,neg_subtract_port,'autorouting','on');



        out_subtract_port=PS_subtract_ports.RConn;
        connections.destination_ports(3)=out_subtract_port;
    end


    if compressibility==1

        if isempty(str2num(k_sh))%#ok<*ST2NM>
            k_sh=['''''',k_sh,''''''];
        end

        il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
        il_predefined_properties_block='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)'''' )" >Isothermal Liquid Predefined Properties (IL) block</a>';
        warnings.messages={['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,' or ',il_predefined_properties_block,'.']};

    else

        warnings.messages={['Block uses Dead volume in chamber A of 1e-5 m^3. Adjustment of Dead volume may be required.']};
    end

    warnings.subsystem=getfullname(hBlock);

    out.connections=connections;
    out.warnings=warnings;

end

