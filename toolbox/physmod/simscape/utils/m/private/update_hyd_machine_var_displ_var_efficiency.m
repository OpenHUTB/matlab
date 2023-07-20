function out=update_hyd_machine_var_displ_var_efficiency(hBlock)










    port_names={'A','C','B','S'};
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    mdl_type=get_param(hBlock,'mdl_type');



    param_list1={...
    'D_max','Dmax';...
    'pr_nominal','Pnom';...
    'w_nominal','Wnom';...
    'w_max','Wmax';...
    'vol_prop_coeff','kL1';...
    'vol_pr_coeff','kLp';...
    'vol_w_coeff','kLw';...
    'vol_d_coeff','kLd';...
    'mech_prop_coeff','kF1';...
    'mech_pr_coeff','kFp';...
    'mech_w_coeff','kFw';...
    'mech_d_coeff','kFd'};

    if strcmp(mdl_type,'1')


        param_list2={
        'stroke_max','Xmax'};
    else


        param_list2={
        'displ_tab','displ_tab';...
        'cntrl_mem_tab','cntrl_mem_tab';...
        'interp_method','interp_method';...
        'extrap_method','extrap_method'};
    end

    param_list=[param_list1;param_list2];


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params=HtoIL_cellToStruct(collected_params);


    delete_block(hBlock);
    if strcmp(mdl_type,'1')
        newBlockName=['/Variable-Displacement',newline,'Hydraulic Machine',newline,'Linear Displacement'];
    else
        newBlockName=['/Variable-Displacement',newline,'Hydraulic Machine',newline,'Tabulated Displacement'];
    end
    hBlock=add_block(['sh_legacy_hyd_machine_var_displ_var_efficiency',newBlockName],...
    [connections.subsystem,newBlockName]);
    set_param(hBlock,'LinkStatus','none');






    params.displacement_units.unit='m^3/rad';
    params.stroke_units.unit='m';
    params.Pnom_units.unit='Pa';
    params.W_units.unit='rad/s';


    params.displacement_units.base='1';
    params.stroke_units.base='1';
    params.Pnom_units.base='1';
    params.W_units.base='1';

    params.displacement_units.conf='runtime';
    params.stroke_units.conf='runtime';
    params.Pnom_units.conf='runtime';
    params.W_units.conf='runtime';


    if strcmp(mdl_type,'1')
        params_withUnits.stroke_max=HtoIL_derive_params('stroke_max','stroke_max',params,'stroke_units',0);
        set_param(hBlock,'Xmax',params_withUnits.stroke_max.base);
    else
        params_withUnits.displ_tab=HtoIL_derive_params('displ_tab','displ_tab',params,'displacement_units',0);
        params_withUnits.cntrl_mem_tab=HtoIL_derive_params('cntrl_mem_tab','cntrl_mem_tab',params,'stroke_units',0);
        set_param(hBlock,'displ_tab',params_withUnits.displ_tab.base);
        set_param(hBlock,'cntrl_mem_tab',params_withUnits.cntrl_mem_tab.base);
    end
    params_withUnits.D_max=HtoIL_derive_params('D_max','D_max',params,'displacement_units',0);
    params_withUnits.pr_nominal=HtoIL_derive_params('pr_nominal','pr_nominal',params,'Pnom_units',0);
    params_withUnits.w_nominal=HtoIL_derive_params('w_nominal','w_nominal',params,'W_units',0);
    params_withUnits.w_max=HtoIL_derive_params('w_max','w_max',params,'W_units',0);


    set_param(hBlock,'Dmax',params_withUnits.D_max.base);
    set_param(hBlock,'Pnom',params_withUnits.pr_nominal.base);
    set_param(hBlock,'Wnom',params_withUnits.w_nominal.base);
    set_param(hBlock,'Wmax',params_withUnits.w_max.base);







    hBlock_path=getfullname(hBlock);
    efficiency_block_paths=...
    {'Leakage Flow Coefficient 1/kL1'
'Leakage Flow Coefficient 2/PS Math Function'
'Leakage Flow Coefficient 3/PS Math Function'
'Leakage Flow Coefficient 1/PS Math Function'
'Friction Torque Coefficient 1/mech_prop_coeff'
'Friction Torque Coefficient 2/PS Math Function'
'Friction Torque Coefficient 3/PS Math Function'
'Friction Torque Coefficient 1/PS Math Function'
    };

    for i=5:12
        set_param(hBlock,param_list{i,2},collected_params(i).base);
        if strcmp(collected_params(i).conf,'runtime')
            j=i-4;
            if j==1||j==5

                set_param([hBlock_path,'/',efficiency_block_paths{j}],'constant_conf','runtime')
            else

                set_param([hBlock_path,'/',efficiency_block_paths{j}],'v_conf','runtime')
            end
        end
    end


    if strcmp(mdl_type,'2')
        set_param([connections.subsystem,newBlockName,'/c2disp/stroke2disp'],'interp_method',params.interp_method.base);
        set_param([connections.subsystem,newBlockName,'/c2disp/stroke2disp'],'extrap_method',params.extrap_method.base);
    end


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3,4]);

    out.connections=connections;

end

