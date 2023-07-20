function out=update_valve_dir_6_way_a(hBlock)








    port_names={'A','C','B','S','T1','P','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'mdl_type','variable_orifice_spec';
    'A_leak','area_leak';
    'C_d','Cd';
    'area_tab','orifice_area_TLU';
    'pressure_tab','p_diff_TLU';
    'flow_rate_tab','vol_flow_TLU'};








    params_for_derivation=HtoIL_collect_params(hBlock,{'or';'opening_max';'area_max';'A_leak';'opening_tab';
    'x_0_P_A';'x_0_P_B';'x_0_A_T1';'x_0_B_T';'x_0_P_C1';'x_0_P_C2'});

    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    mdl_type=eval(get_param(hBlock,'mdl_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    pressure_tab=HtoIL_collect_params(hBlock,{'pressure_tab'});
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    vol_flow_tab=HtoIL_collect_params(hBlock,{'flow_rate_tab'});



    if strcmp(lam_spec,'2')
        param_list(end+1,:)={'Re_cr','Re_c'};
    end

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    delete_block(hBlock)


    orifice_PA_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice P-A']);
    set_param(orifice_PA_block,'Position','[180    87   220   123]');

    orifice_PA.A=get_param(orifice_PA_block,'PortHandles').LConn(1);
    orifice_PA.B=get_param(orifice_PA_block,'PortHandles').RConn;
    orifice_PA.S=get_param(orifice_PA_block,'PortHandles').LConn(2);

    orifice_PC1_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice P-C1']);
    set_param(orifice_PC1_block,'Position','[180   152   220   188]');

    orifice_PC1.A=get_param(orifice_PC1_block,'PortHandles').LConn(1);
    orifice_PC1.B=get_param(orifice_PC1_block,'PortHandles').RConn;
    orifice_PC1.S=get_param(orifice_PC1_block,'PortHandles').LConn(2);

    orifice_PB_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice P-B']);
    set_param(orifice_PB_block,'Position','[180   257   220   293]');

    orifice_PB.A=get_param(orifice_PB_block,'PortHandles').LConn(1);
    orifice_PB.B=get_param(orifice_PB_block,'PortHandles').RConn;
    orifice_PB.S=get_param(orifice_PB_block,'PortHandles').LConn(2);

    orifice_AT_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice A-T1']);
    set_param(orifice_AT_block,'Position','[365    77   405   113]');

    orifice_AT1.A=get_param(orifice_AT_block,'PortHandles').LConn(1);
    orifice_AT1.B=get_param(orifice_AT_block,'PortHandles').RConn;
    orifice_AT1.S=get_param(orifice_AT_block,'PortHandles').LConn(2);

    orifice_PC2_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice P-C2']);
    set_param(orifice_PC2_block,'Position','[365   142   405   178]');

    orifice_PC2.A=get_param(orifice_PC2_block,'PortHandles').LConn(1);
    orifice_PC2.B=get_param(orifice_PC2_block,'PortHandles').RConn;
    orifice_PC2.S=get_param(orifice_PC2_block,'PortHandles').LConn(2);

    orifice_BT_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',[connections.subsystem,'/Variable Orifice B-T']);
    set_param(orifice_BT_block,'Position','[365   247   405   283]');

    orifice_BT.A=get_param(orifice_BT_block,'PortHandles').LConn(1);
    orifice_BT.B=get_param(orifice_BT_block,'PortHandles').RConn;
    orifice_BT.S=get_param(orifice_BT_block,'PortHandles').LConn(2);



    add_line(connections.subsystem,orifice_PA.A,orifice_PC1.A);
    add_line(connections.subsystem,orifice_PA.A,orifice_PB.A);

    add_line(connections.subsystem,orifice_PA.B,orifice_AT1.A);

    add_line(connections.subsystem,orifice_PB.B,orifice_BT.A);

    add_line(connections.subsystem,orifice_PA.S,orifice_PB.S);
    add_line(connections.subsystem,orifice_PA.S,orifice_PC1.S);
    add_line(connections.subsystem,orifice_PA.S,orifice_PC2.S);
    add_line(connections.subsystem,orifice_PA.S,orifice_AT1.S);
    add_line(connections.subsystem,orifice_PA.S,orifice_BT.S);

    add_line(connections.subsystem,orifice_PC1.B,orifice_PC2.A);


    connections.destination_ports=[orifice_PA.B,orifice_PC2.B,orifice_PB.B,orifice_PA.S,orifice_AT1.B,orifice_PA.A,orifice_BT.B];



    HtoIL_apply_params(orifice_PA_block,param_list(:,2),collected_params);
    HtoIL_apply_params(orifice_PC1_block,param_list(:,2),collected_params);
    HtoIL_apply_params(orifice_PB_block,param_list(:,2),collected_params);
    HtoIL_apply_params(orifice_AT_block,param_list(:,2),collected_params);
    HtoIL_apply_params(orifice_PC2_block,param_list(:,2),collected_params);
    HtoIL_apply_params(orifice_BT_block,param_list(:,2),collected_params);


    set_param(orifice_PC1_block,'open_orientation','-1');
    set_param(orifice_PB_block,'open_orientation','-1');
    set_param(orifice_AT_block,'open_orientation','-1');





    params=HtoIL_cellToStruct(params_for_derivation);


    OR_vec={'_P_A','_P_C1','_P_B','_A_T1','_P_C2','_B_T'};
    or_block_vec=[orifice_PA_block,orifice_PC1_block,orifice_PB_block,orifice_AT_block,orifice_PC2_block,orifice_BT_block];

    for i=1:length(or_block_vec)

        or_block=or_block_vec(i);
        OR=OR_vec{i};


        set_param(or_block,'smoothing_factor','0');


        open_sign=eval(get_param(or_block,'open_orientation'));


        evaluate=1;


        name='S_min';


        if open_sign==1
            math_expression=['opening_max/area_max*A_leak - x_0',OR];
        else
            math_expression=['-opening_max/area_max*A_leak + x_0',OR];
        end
        dialog_unit_expression='opening_max/area_max*A_leak';
        S_min=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(or_block,{'S_min'},S_min);
        params.S_min=S_min;








        name='S_max';


        if open_sign==1
            math_expression=['-x_0',OR,' + opening_max'];
        else
            math_expression=['x_0',OR,' - opening_max'];
        end
        dialog_unit_expression='opening_max';
        S_max=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        params.S_max=S_max;


        name='del_S';


        if open_sign==1
            math_expression='S_max - S_min';
        else
            math_expression='-S_max + S_min';
        end
        dialog_unit_expression='S_min';
        del_S=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(or_block,{'del_S'},del_S);



        name='x0_in_opening_tab_units';
        math_expression=['x_0',OR];
        dialog_unit_expression='opening_tab';
        x0_in_opening_tab_units=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,0);

        S_TLU=params.opening_tab;
        if open_sign==1
            S_TLU.base=[params.opening_tab.base,' - ',x0_in_opening_tab_units.base];
        else
            S_TLU.base=['-(',params.opening_tab.base,') + ',x0_in_opening_tab_units.base];
        end
        if strcmp('runtime',{params.opening_tab.conf,params.(['x_0',OR]).conf})
            S_TLU.conf='runtime';
        else
            S_TLU.conf='compiletime';
        end
        HtoIL_apply_params(or_block,{'S_TLU'},S_TLU);


        HtoIL_apply_params(or_block,{'S_vol_flow_TLU'},S_TLU);

    end



    warnings.subsystem=connections.subsystem;
    warnings.messages={};

    if strcmp(lam_spec,'1')

        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150.';
        end
    end


    increase_decrease_str='ascending or descending';
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    mdl_type,interp_method,extrap_method,...
    pressure_tab,area_tab,vol_flow_tab,increase_decrease_str,...
    'Control member position vectors','Orifice area vectors',...
    'Pressure drop vectors','Volumetric flow rate tables');

    out.connections=connections;
    if~isempty(warnings.messages)
        out.warnings=warnings;
    end

end