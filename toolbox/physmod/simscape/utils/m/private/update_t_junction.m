function out=update_t_junction(hBlock)









    port_names={'A','A1','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list_resistanceAB={'kp_ab','loss_coeff_AB';
    'kp_ba','loss_coeff_BA';
    'Re_cr','Re_c'};

    param_list_resistanceAA1={'kp_aa1','loss_coeff_AB';
    'kp_a1a','loss_coeff_BA';
    'Re_cr','Re_c'};

    param_list_resistanceA1B={'kp_a1b','loss_coeff_AB';
    'kp_ba1','loss_coeff_BA';
    'Re_cr','Re_c'};

    collected_paramsAB=HtoIL_collect_params(hBlock,param_list_resistanceAB(:,1));
    collected_paramsAA1=HtoIL_collect_params(hBlock,param_list_resistanceAA1(:,1));
    collected_paramsA1B=HtoIL_collect_params(hBlock,param_list_resistanceA1B(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'main_diam';'branch_diam'});


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Local Resistance (IL)')
    set_param(hBlock,'name','Local Resistance A-B');
    resistanceAB_port_A=get_param(hBlock,'PortHandles').LConn;
    resistanceAB_port_B=get_param(hBlock,'PortHandles').RConn;


    resistanceAA1_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Local Resistance (IL)',[connections.subsystem,'/Local Resistance A-A1']);
    resistanceAA1_port_A=get_param(resistanceAA1_block,'PortHandles').LConn;
    resistanceAA1_port_B=get_param(resistanceAA1_block,'PortHandles').RConn;


    resistanceA1B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Local Resistance (IL)',[connections.subsystem,'/Local Resistance A1-B']);
    resistanceA1B_port_A=get_param(resistanceA1B_block,'PortHandles').LConn;
    resistanceA1B_port_B=get_param(resistanceA1B_block,'PortHandles').RConn;


    add_line(connections.subsystem,resistanceAB_port_A,resistanceAA1_port_A,'autorouting','on');
    add_line(connections.subsystem,resistanceAA1_port_B,resistanceA1B_port_A,'autorouting','on');
    add_line(connections.subsystem,resistanceA1B_port_B,resistanceAB_port_B,'autorouting','on');


    connections.destination_ports=[resistanceAB_port_A,resistanceA1B_port_A,resistanceAB_port_B];



    HtoIL_apply_params(hBlock,param_list_resistanceAB(:,2),collected_paramsAB);
    HtoIL_apply_params(resistanceAA1_block,param_list_resistanceAA1(:,2),collected_paramsAA1);
    HtoIL_apply_params(resistanceA1B_block,param_list_resistanceA1B(:,2),collected_paramsA1B);



    params=HtoIL_cellToStruct(params_for_derivation);


    main_area.base=['pi*(',params.main_diam.base,')^2/4'];
    main_area.unit=['(',params.main_diam.unit,')^2'];
    main_area.conf=params.main_diam.conf;


    branch_area.base=['pi*(',params.branch_diam.base,')^2/4'];
    branch_area.unit=['(',params.branch_diam.unit,')^2'];
    branch_area.conf=params.branch_diam.conf;


    HtoIL_apply_params(hBlock,{'flow_area'},main_area);
    HtoIL_apply_params(resistanceAA1_block,{'flow_area'},branch_area);
    HtoIL_apply_params(resistanceA1B_block,{'flow_area'},branch_area);


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        set_param(resistanceAA1_block,'Re_c','150');
        set_param(resistanceA1B_block,'Re_c','150');
        if strcmp(B_lam,'0.999')
            out.warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            out.warnings.messages={'Critical Reynolds number set to 150.'};
        end
        out.warnings.subsystem=connections.subsystem;
    end


    out.connections=connections;

end