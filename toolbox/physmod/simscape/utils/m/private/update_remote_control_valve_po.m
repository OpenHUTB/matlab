function out=update_remote_control_valve_po(hBlock)









    port_names={'X','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'pres_crack','p_set_differential';
    'A_leak','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c';
    'dynamic','opening_dynamics'};











    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'pres_max';'pres_crack'});

    valve_type=get_param(hBlock,'valve_type');
    dynamic=get_param(hBlock,'dynamic');
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Pressure Compensator Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    if strcmp(valve_type,'1')
        set_param(hBlock,'valve_spec','2');
    else
        set_param(hBlock,'valve_spec','1');
    end


    params=HtoIL_cellToStruct(params_for_derivation);
    math_expression='pres_max - pres_crack';
    dialog_unit_expression='pres_crack';
    evaluate=1;
    p_range=HtoIL_derive_params('p_range',math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'p_range'},p_range);




    reservoir_block=add_block('fl_lib/Isothermal Liquid/Elements/Reservoir (IL)',[connections.subsystem,'/Reservoir (IL)']);
    reservoir_port=get_param(reservoir_block,'PortHandles').LConn;
    valve_ports=get_param(hBlock,'PortHandles');
    valve_port_Y=valve_ports.RConn(3);
    add_line(connections.subsystem,reservoir_port,valve_port_Y,'autorouting','on');



    warnings.messages={};

    if strcmp(dynamic,'1')
        warnings.messages={'Initial area removed. Adjustment of model initial conditions may be required.';
        'Opening time constant applied to control pressure instead of valve area. Adjustment of Opening time constant may be required.'};
    end

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end

    if~isempty(warnings.messages)
        warnings.subsystem=getfullname(hBlock);
    else
        warnings={};
    end

    out.connections=connections;
    out.warnings=warnings;

end