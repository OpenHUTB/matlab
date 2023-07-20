function out=update_orifice_vrb_slot(hBlock)









    param_list={'w','width';
    'A_leak','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    x_0=HtoIL_collect_params(hBlock,{'x_0'});
    or=get_param(hBlock,'or');
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Spool Orifice (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'smoothing_factor','0');


    set_param(hBlock,'orifice_spec','2');
    set_param(hBlock,'del_S_max','1');










    if strcmp(or,'1')
        set_param(hBlock,'open_orientation','1');
    else
        set_param(hBlock,'open_orientation','-1');
    end


    S_min=x_0;

    if strcmp(or,'1')
        S_min.base=['-(',x_0.base,')'];
    end
    HtoIL_apply_params(hBlock,{'S_min'},S_min);




    warnings.subsystem=getfullname(hBlock);
    warnings.messages={['New parameter Spool travel between closed and open orifice set to 1 m. '...
    ,'Adjustment of Spool travel between closed and open orifice may be required.']};

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{2}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{2}='Critical Reynolds number set to 150.';
        end
    end

    out.warnings=warnings;

end