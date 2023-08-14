function out=update_cylinder_cushion(hBlock)







    param_list={...
    'piston_area','area_plunger';...
    'piston_init_pos','x0';...
    'orifice_area','area_cushion_orifice';...
    'check_area','check_valve_area_max';...
    'check_cr_pr','p_crack_differential';...
    'check_op_pr','press_max_differential';...
    'check_leak_area','check_valve_area_leak';...
    'var_orif_leak','area_leak_plunger'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    orient=get_param(hBlock,'orient');
    opening=HtoIL_collect_params(hBlock,{'opening'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Auxiliary Components/Cylinder Cushion (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'smoothing_factor','0');



    if strcmp(orient,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end


    length_plunger=opening;
    opening_first=HtoIL_get_vector_element(opening,'first');
    opening_last=HtoIL_get_vector_element(opening,'last');
    length_plunger.base=['(',opening_last.base,') - (',opening_first.base,')'];
    HtoIL_apply_params(hBlock,{'length_plunger'},length_plunger);



    warnings.messages={'Variable orifice reparameterized to linear area - opening relationship. Adjustment of Cushion plunger cross-sectional area and Cushion plunger length may be required.';
    'Cushion plunger length set to default value of 1e-3 m. Adjustment of Cushion plunger length may be required.';
    'All orifice flow discharge coefficients internally set to 0.64 and critical Reynolds numbers internally set to 150.'};

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;

end



