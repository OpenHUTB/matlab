function out=update_area_change(hBlock)










    port_names={'B','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'kp_c','k_expansion';
    'kp_c','k_contraction';
    'Re_cr','Re_c'};

    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.local_resistances.gradual_area_change')
        param_list(end+1,:)={'angle','cone_angle'};
    end

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'mdl_type';'large_diam';'small_diam';'Re_vec';'loss_coeff_vec';'kp_c';'angle'});


    mdl_type=get_param(hBlock,'mdl_type');
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    interp_method=get_param(hBlock,'interp_method');
    extrap_method=get_param(hBlock,'extrap_method');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Area Change (IL)')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    params=HtoIL_cellToStruct(params_for_derivation);


    if strcmp(SourceFile,'sh.local_resistances.gradual_area_change')
        if strcmp(mdl_type,'1')
            loss_coeff_spec='2';
        else
            loss_coeff_spec='3';
        end
    else
        if strcmp(mdl_type,'1')
            loss_coeff_spec='1';
        else
            loss_coeff_spec='3';
        end
    end
    set_param(hBlock,'loss_coeff_spec',loss_coeff_spec);


    area_B.base=['pi*(',params.small_diam.base,')^2/4'];
    area_B.unit=['(',params.small_diam.unit,')^2'];
    area_B.conf=params.small_diam.conf;
    HtoIL_apply_params(hBlock,{'area_B'},area_B);


    if strcmp(mdl_type,'1')
        area_A.base=['pi*(',params.large_diam.base,')^2/4'];
        area_A.unit=['(',params.large_diam.unit,')^2'];
        area_A.conf=params.large_diam.conf;
        HtoIL_apply_params(hBlock,{'area_A'},area_A);
    else

        HtoIL_apply_params(hBlock,{'area_A'},area_B);
    end


    name='AR';
    math_expression='small_diam*small_diam/large_diam/large_diam';
    dialog_unit_expression='kp_c';
    evaluate=1;
    params.AR=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);





    if strcmp(SourceFile,'sh.local_resistances.gradual_area_change')
        params.forty_five_deg.name='forty_five_deg';
        params.forty_five_deg.base='45';
        params.forty_five_deg.unit='deg';
        params.forty_five_deg.conf='runtime';


        angle_degrees=HtoIL_derive_params('angle_deg','angle',params,'forty_five_deg',1);
    end


    k_contraction=params.kp_c;
    if strcmp(SourceFile,'sh.local_resistances.sudden_area_change')

        k_contraction.base=['max(1e-3, ',params.kp_c.base,'/(1- (',params.AR.base,'))^0.25 - 2*(1+(',params.AR.base,')))'];

        if all(strcmp('runtime',{params.kp_c.conf,params.AR.conf}))
            k_contraction.conf='runtime';
        else
            k_contraction.conf='compiletime';
        end
    else

        denom=['((0.8*sind(',angle_degrees.base,'/2 ))*(',angle_degrees.base,'< 45) + (0.5*sqrt(sind(',angle_degrees.base,'/2))*(',angle_degrees.base,'>= 45))'];
        k_contraction.base=['max(1e-3, ',params.kp_c.base,'/(1- (',params.AR.base,'))^0.25 - (1+',params.AR.base,')/(',denom,' ) ))'];

        if all(strcmp('runtime',{params.kp_c.conf,params.angle.conf,params.AR.conf}))
            k_contraction.conf='runtime';
        else
            k_contraction.conf='compiletime';
        end
    end
    HtoIL_apply_params(hBlock,{'k_contraction'},k_contraction);



    k_expansion=params.kp_c;
    if strcmp(SourceFile,'sh.local_resistances.sudden_area_change')

        k_expansion.base=[params.kp_c.base,'+ 1'];
    else

        denom=['(2.6*sind((',angle_degrees.base,')/2 )*(1-',params.AR.base,')*(',angle_degrees.base,'< 45) + (1-',params.AR.base,')*(',angle_degrees.base,'>= 45))'];
        k_expansion.base=[params.kp_c.base,' + (1 + ',params.AR.base,')/(',denom,')'];

        if all(strcmp('runtime',{params.kp_c.conf,params.angle.conf,params.AR.conf}))
            k_expansion.conf='runtime';
        else
            k_expansion.conf='compiletime';
        end
    end
    HtoIL_apply_params(hBlock,{'k_expansion'},k_expansion);


    if strcmp(mdl_type,'2')

        set_param(hBlock,'Re_c','150');
    end


    if strcmp(mdl_type,'2')


        Re_TLU=params.Re_vec;
        Re_vec_value=str2num(params.Re_vec.base);%#ok<ST2NM>
        if~isempty(Re_vec_value)
            Re_TLU.base=['[',num2str(Re_vec_value(Re_vec_value>0)),']'];
        elseif isvarname(params.Re_vec.base)
            Re_TLU.base=[params.Re_vec.base,'(',params.Re_vec.base,'>0)'];
        else
            Re_TLU.base=['getfield( [',params.Re_vec.base,'], { [',params.Re_vec.base,'] > 0 }) '];
        end
        HtoIL_apply_params(hBlock,{'Re_TLU'},Re_TLU);


        loss_expansion_TLU=params.loss_coeff_vec;
        loss_coeff_vec_value=str2num(params.loss_coeff_vec.base);%#ok<ST2NM>
        if~isempty(loss_coeff_vec_value)&&~isempty(Re_vec_value)
            loss_expansion_TLU.base=['[',num2str(loss_coeff_vec_value(Re_vec_value>0)),']'];
        elseif isvarname(params.loss_coeff_vec.base)&&isvarname(params.Re_vec.base)
            loss_expansion_TLU.base=[params.loss_coeff_vec.base,'(',params.Re_vec.base,'>0)'];
        else
            loss_expansion_TLU.base=['getfield( [',params.loss_coeff_vec.base,'], { [',params.Re_vec.base,'] > 0 }) '];
        end
        HtoIL_apply_params(hBlock,{'loss_expansion_TLU'},loss_expansion_TLU);


        loss_contraction_TLU=params.loss_coeff_vec;
        if~isempty(loss_coeff_vec_value)&&~isempty(Re_vec_value)
            loss_contraction_TLU.base=['[',num2str(...
            interp1(-fliplr(Re_vec_value(Re_vec_value<0)),fliplr(loss_coeff_vec_value(Re_vec_value<0)),...
            Re_vec_value(Re_vec_value>0),...
            'linear',loss_coeff_vec_value(1))),']'];
        elseif isvarname(params.loss_coeff_vec.base)&&isvarname(params.Re_vec.base)
            loss_contraction_TLU.base=[...
            '[ interp1( -fliplr(',params.Re_vec.base,'(',params.Re_vec.base,'<0)), '...
            ,'fliplr(',params.loss_coeff_vec.base,'(',params.Re_vec.base,'<0)), '...
            ,params.Re_vec.base,'(',params.Re_vec.base,'>0), '...
            ,'''linear'', ',params.loss_coeff_vec.base,'(1))',']'];
        else
            Xref=['-fliplr( getfield( [',params.Re_vec.base,'], { [',params.Re_vec.base,'] < 0 }) )'];
            Yref=['fliplr( getfield( [',params.loss_coeff_vec.base,'], { [',params.Re_vec.base,'] < 0 }) )'];
            extrapYvalue=['getfield( [',params.loss_coeff_vec.base,'], { numel(',params.loss_coeff_vec.base,') }) '];
            loss_contraction_TLU.base=['interp1(',Xref,',',Yref,',',Re_TLU.base,', ''linear'', ',extrapYvalue,')'];
        end
        HtoIL_apply_params(hBlock,{'loss_contraction_TLU'},loss_contraction_TLU);

    end



    warnings.messages={};

    if strcmp(mdl_type,'1')&&strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    elseif strcmp(mdl_type,'2')
        set_param(hBlock,'Re_c','150');
        warnings.messages{end+1,1}='Critical Reynolds number, which is used for flow reversal threshold, set to 150. Behavior change not expected.';
    end

    if strcmp(mdl_type,'1')
        warnings.messages{end+1,1}=['The block now models pressure loss due to kinetic energy change. Correction factors have been '...
        ,'reformulated to minimize difference in numerical results. Further adjustment of Expansion correction factor and Contraction correction factor may be required.'];
        warnings.messages{end+1,1}=['Power in the contraction loss coefficient has been reformulated from 0.75 to 1. '...
        ,'Contraction correction factor has been reformulated to minimize difference in numerical results. Further adjustment of Contraction correction factor may be required.'];
    end

    if strcmp(mdl_type,'2')
        warnings.messages{end+1,1}=['Only elements greater than or equal to 0 retained in Reynolds number vector. Expansion loss coefficient values mapped to these Reynolds numbers.'...
        ,' Adjustment of Reynolds number vector, Contraction loss coefficient vector, and Expansion loss coefficient vector may be required.'];
    end

    if strcmp(mdl_type,'2')&&strcmp(interp_method,'2')
        warnings.messages{end+1,1}=['Interpolation method changed to Linear.'...
        ,' Additional elements in Reynolds number vector, Contraction loss coefficient vector, and Expansion loss coefficient vector may be required.'];
    end
    if strcmp(mdl_type,'2')&&strcmp(extrap_method,'1')
        warnings.messages{end+1,1}=['Extrapolation method changed to Nearest.'...
        ,' Extension of Reynolds number vector, Contraction loss coefficient vector, and Expansion loss coefficient vector may be required.'];
    end

    if~isempty(warnings.messages)
        out.warnings.messages=warnings.messages;
        out.warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;

end