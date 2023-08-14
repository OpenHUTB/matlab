function out=update_pressure_control_valves(hBlock)







    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.valves.pressure_control_valves.pressure_compensator')
        RefBlock='SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Pressure Compensator Valve (IL)';
        p_diff_TLU_IL='p_diff_reducing_TLU';
        area_TLU_IL='valve_area_reducing_TLU';


        p_set_IL_name='p_set_differential';
        valve_area_spec=eval(get_param(hBlock,'valve_area_spec'));
        if valve_area_spec==1
            pres_set_IL=HtoIL_collect_params(hBlock,{'pres_set'});
        else
            p_diff_reducing_TLU=HtoIL_collect_params(hBlock,{'p_diff_TLU'});
            pres_set_IL=HtoIL_get_vector_element(p_diff_reducing_TLU,'first');
        end

    elseif strcmp(SourceFile,'sh.valves.pressure_control_valves.pressure_reducing_vlv')

        RefBlock='SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Pressure-Reducing Valve (IL)';
        p_diff_TLU_IL='p_diff_TLU';
        area_TLU_IL='valve_area_TLU';


        p_set_IL_name='p_set_gauge';
        valve_area_spec=eval(get_param(hBlock,'valve_area_spec'));
        if valve_area_spec==1
            pres_set_IL=HtoIL_collect_params(hBlock,{'pres_set'});
        else
            p_diff_TLU=HtoIL_collect_params(hBlock,{'p_diff_TLU'});
            pres_set_IL=HtoIL_get_vector_element(p_diff_TLU,'first');
        end

    else


        RefBlock='SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Pressure Relief Valve (IL)';
        p_diff_TLU_IL='p_diff_TLU';
        area_TLU_IL='valve_area_TLU';


        p_set_IL_name='p_set_differential';
        pres_set_IL=HtoIL_collect_params(hBlock,{'pres_set'});
    end





    param_list={'valve_area_spec','opening_spec';
    'reg_range','p_range';
    'A_leak','area_leak';
    'p_diff_TLU',p_diff_TLU_IL;
    'area_TLU',area_TLU_IL;
    'C_d','Cd'
    'Re_cr','Re_c';
    'dynamic','opening_dynamics'};












    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    dynamic=get_param(hBlock,'dynamic');


    HtoIL_set_block_files(hBlock,RefBlock)


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    HtoIL_apply_params(hBlock,{p_set_IL_name},pres_set_IL);


    warnings.messages={};

    if strcmp(dynamic,'1')
        warnings.messages={'Initial area removed. Adjustment of model initial conditions may be required.';
        'Opening time constant applied to control pressure instead of valve area. Adjustment of the time constant may be required.'};
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

    out.warnings=warnings;

end