function out=update_gate_valve(hBlock)







    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={'d_gate','diameter_sleeve';
    'd_gate','diameter_case';
    'C_d','Cd';
    'A_leak','area_leak';
    'Re_cr','Re_c'};






    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'x_0';'d_gate'});


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Variable Overlapping Orifice (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);




    params=HtoIL_cellToStruct(params_for_derivation);
    evaluate=0;


    name='S0';
    math_expression='d_gate - x_0';
    dialog_unit_expression='x_0';
    S0=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},S0);


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            out.warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            out.warnings.messages={'Critical Reynolds number set to 150.'};
        end
        out.warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;
end