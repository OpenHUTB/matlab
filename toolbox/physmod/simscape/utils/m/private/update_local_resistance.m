function out=update_local_resistance(hBlock)







    param_list={'mdl_type','resistance_loss_spec';
    'area','flow_area';
    'kp_d','loss_coeff_AB';
    'kp_r','loss_coeff_BA';
    'Re_cr','Re_c';
    'Re_vec','Re_TLU'
    'loss_coeff_vec','loss_coeff_TLU'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate';'pressure_drop'},'sh_lib/Local Hydraulic Resistances/Local Resistance');
    beginning_variable_names={'Flow rate';'Pressure differential'};
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    mdl_type=get_param(hBlock,'mdl_type');
    interp_method=get_param(hBlock,'interp_method');
    extrap_method=get_param(hBlock,'extrap_method');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Local Resistance (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    out.warnings.messages={};



    out.warnings.messages=HtoIL_add_beginning_value_warning(out.warnings.messages,beginning_variables,beginning_variable_names);

    if strcmp(mdl_type,'2')&&strcmp(interp_method,'2')
        out.warnings.messages{end+1,1}='Interpolation method changed to Linear. Additional elements in Reynolds number vector and Loss coefficient vector may be required.';
    end
    if strcmp(mdl_type,'2')&&strcmp(extrap_method,'1')
        out.warnings.messages{end+1,1}='Extrapolation method changed to Nearest. Extension of Reynolds number vector and Loss coefficient vector may be required.';
    end

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            out.warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            out.warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end

    if~isempty(out.warnings.messages)
        out.warnings.subsystem=getfullname(hBlock);
    end

end