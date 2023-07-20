function out=update_cartridge_valve_insert_conical_seat(hBlock)







    param_list={'ar_ratio','area_A_X_ratio';...
    'frc_preload','preload_force';...
    'spr_rate','stiff_coeff';...
    'poppet_str','stroke';...
    'd_poppet','diam_poppet';...
    'C_d','Cd'
    'leak_area','area_leak';
    'Re_cr','Re_c';
    'time_constant','tau'};





    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Cartridge Valve Insert (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    warnings.messages(1:2,1)={'Initial poppet position removed. Adjustment of system model initial conditions may be required.';
    'Stroke reparameterized as function of Seat cone angle and Poppet diameter. Adjustment of these parameters may be required.'};

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
end