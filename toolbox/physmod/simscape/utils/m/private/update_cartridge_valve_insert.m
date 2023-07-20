function out=update_cartridge_valve_insert(hBlock)







    param_list={'ar_ratio','area_A_X_ratio';...
    'frc_preload','preload_force';...
    'spr_rate','stiff_coeff';...
    'poppet_str','stroke';...
    'time_constant','tau'
    'orif_sp_type','orifice_spec';
    'leak_area','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c';
    'opening_tab','S_TLU';
    'area_tab','orifice_area_TLU';
    'opening_tab','S_vol_flow_TLU';
    'pressure_tab','p_diff_TLU';
    'flow_rate_tab','vol_flow_TLU'};











    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));

    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    orif_sp_type=eval(get_param(hBlock,'orif_sp_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    pressure_tab=HtoIL_collect_params(hBlock,{'pressure_tab'});
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    vol_flow_tab=HtoIL_collect_params(hBlock,{'flow_rate_tab'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Cartridge Valve Insert (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'valve_seat_spec','2');
    set_param(hBlock,'smoothing_factor','0');


    warnings.subsystem=getfullname(hBlock);


    warnings.messages{1}='Initial opening removed. Adjustment of model initial conditions may be required.';

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end


    increase_decrease_str='ascending or descending';
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    orif_sp_type,interp_method,extrap_method,...
    pressure_tab,area_tab,vol_flow_tab,increase_decrease_str,...
    'Poppet position vector','Orifice area vector',...
    'Pressure drop vector','Volumetric flow rate table');

    out.warnings=warnings;

end