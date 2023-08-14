function out=update_valve_dir_4_way(hBlock)








    port_names={'A','B','S','P','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    SourceFile=get_param(hBlock,'SourceFile');
    last_letter=SourceFile(end);
    if last_letter=='y'
        letter='';
    else
        letter=last_letter;
    end





    param_list={...
    'A_leak','area_leak';
    'area_tab','valve_area_TLU';
    'flow_rate_tab','vol_flow_TLU';
    'pressure_tab','p_diff_TLU';
    'C_d','Cd';
    'Re_cr','Re_c'};

    if isempty(letter)

        param_list_append={...
        'area_max_P_A','area_max_PA';
        'area_max_P_B','area_max_PB';
        'area_max_A_T','area_max_AT';
        'area_max_B_T','area_max_BT';
        'area_tab_P_A','valve_area_TLU_PA';
        'area_tab_P_B','valve_area_TLU_PB';
        'area_tab_A_T','valve_area_TLU_AT';
        'area_tab_B_T','valve_area_TLU_BT';
        'flow_rate_tab_P_A','vol_flow_TLU_PA';
        'flow_rate_tab_P_B','vol_flow_TLU_PB';
        'flow_rate_tab_A_T','vol_flow_TLU_AT';
        'flow_rate_tab_B_T','vol_flow_TLU_BT';
        'pressure_tab_P_A','p_diff_TLU_PA';
        'pressure_tab_P_B','p_diff_TLU_PB';
        'pressure_tab_A_T','p_diff_TLU_AT';
        'pressure_tab_B_T','p_diff_TLU_BT'};

        param_list=[param_list;param_list_append];
    end

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));





    param_list_for_derivation=...
    {'mdl_type_identical'
'mdl_type_different'
'mdl_type'
'opening_max'
'opening_max_P_A'
'opening_max_P_B'
'opening_max_A_T'
'opening_max_B_T'
'area_max'
'area_max_P_A'
'area_max_P_B'
'area_max_A_T'
'area_max_B_T'
'A_leak'
'x_0_P_A'
'x_0_P_B'
'x_0_A_T'
'x_0_B_T'
'opening_tab'
'opening_area_tab'
'opening_area_tab_P_A'
'opening_area_tab_P_B'
'opening_area_tab_A_T'
'opening_area_tab_B_T'
'flow_rate_tab'
'opening_flow_rate_tab'
'opening_flow_rate_tab_P_A'
'opening_flow_rate_tab_P_B'
'opening_flow_rate_tab_A_T'
'opening_flow_rate_tab_B_T'
'area_tab'
'area'
'pressure_tab'
'x_0_P_T1'
'x_0_A_T1'
'x_0_B_T1'
'x_0_T1_T'
'x_0_P_A1'
'x_0_P_A2'
'x_0_P_B1'
'x_0_P_B2'
    };

    params_for_derivation=HtoIL_collect_params(hBlock,param_list_for_derivation);



    lam_spec=eval(get_param(hBlock,'lam_spec'));
    B_lam=get_param(hBlock,'B_lam');


    if~isempty(letter)


        area_spec_H=1;
        area_spec_IL=2;

        interp_method=eval(get_param(hBlock,'interp_method'));
        extrap_method=eval(get_param(hBlock,'extrap_method'));

    else
        area_spec_H=eval(get_param(hBlock,'area_spec'));
        area_spec_IL=area_spec_H;
        if area_spec_H==1
            interp_method=eval(get_param(hBlock,'interp_method_identical'));
            extrap_method=eval(get_param(hBlock,'extrap_method_identical'));
        else
            interp_method=eval(get_param(hBlock,'interp_method_different'));
            extrap_method=eval(get_param(hBlock,'extrap_method_different'));
        end
    end




    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/4-Way 3-Position Directional Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,3,1,4,5]);


    set_param(hBlock,'area','inf');
    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    evaluate=1;


    params=HtoIL_cellToStruct(params_for_derivation);


    if~isempty(letter)



        set_param(hBlock,'area_spec',num2str(area_spec_IL));
    end


    if~isempty(letter)
        params.opening_area_tab=params.opening_tab;
        params.opening_flow_rate_tab=params.opening_tab;
        params.opening_area_tab.name='opening_area_tab';
        params.opening_flow_rate_tab.name='opening_flow_rate_tab';
    end



    if isempty(letter)
        if area_spec_H==1
            mdl_type=eval(params.mdl_type_identical.base);
        else
            mdl_type=eval(params.mdl_type_different.base);
        end
    else
        mdl_type=eval(params.mdl_type.base);
    end
    set_param(hBlock,'valve_spec',num2str(mdl_type));








    switch letter
    case ''
        H_orifice_str_list={'','_P_A','_P_B','_A_T','_B_T'};
        H_sign_str_list={'n/a','+','-','-','+'};
        IL_orifice_str_list={'','_PA','_PB','_AT','_BT'};
        IL_sign_str_list=H_sign_str_list;

    case 'a'
        H_orifice_str_list={'','_P_A','_P_B','_A_T','_B_T','_P_T1','_T1_T'};
        H_sign_str_list={'n/a','+','-','-','+','-','+'};
        IL_orifice_str_list={'','_PA','_PB','_AT','_BT','_PT',''};
        IL_sign_str_list={'n/a','+','-','-','+','0',''};
        valve_configurations={'1','12','3'};
    case 'b'
        H_orifice_str_list={'','_P_B','_T1_T','_A_T1','_B_T'};
        H_sign_str_list={'n/a','+','-','+','-'};
        IL_orifice_str_list={'','_PB','_AT','','_BT'};
        IL_sign_str_list={'n/a','+','0','','-'};
        valve_configurations={'2','1','1'};
    case 'c'
        H_orifice_str_list={'','_P_A','_A_T','_T1_T','_B_T1'};
        H_sign_str_list={'n/a','-','+','-','+'};
        IL_orifice_str_list={'','_PA','_AT','_BT',''};
        IL_sign_str_list={'n/a','-','+','0',''};
        valve_configurations={'3','1','2'};
    case 'd'
        H_orifice_str_list={'','_P_A1','_P_A2','_P_B','_B_T'};
        H_sign_str_list={'n/a','-','+','+','-'};
        IL_orifice_str_list={'','_PA','','_PB','_BT'};
        IL_sign_str_list={'n/a','+-','','+','-'};
        valve_configurations={'2','0','1'};
    case 'e'
        H_orifice_str_list={'','_P_B2','_P_B1','_P_A','_A_T'};
        H_sign_str_list={'n/a','-','+','-','+'};
        IL_orifice_str_list={'','_PB','','_PA','_AT'};
        IL_sign_str_list={'n/a','+-','','-','+'};
        valve_configurations={'3','0','2'};
    case 'f'
        H_orifice_str_list={'','_P_A2','_P_A1','_P_B','_T1_T','_A_T1','_B_T'};
        H_sign_str_list={'n/a','-','+','+','-','+','-'};
        IL_orifice_str_list={'','_PA','','_PB','_AT','','_BT'};
        IL_sign_str_list={'n/a','+-','','+','0','','-'};
        valve_configurations={'2','2','1'};
    case 'g'
        H_orifice_str_list={'','_P_B2','_P_B1','_P_A','_B_T1','_T1_T','_A_T'};
        H_sign_str_list={'n/a','-','+','-','-','+','+'};
        IL_orifice_str_list={'','_PB','','_PA','_BT','','_AT'};
        IL_sign_str_list={'n/a','+-','','-','0','','+'};
        valve_configurations={'3','2','2'};
    case 'h'
        H_orifice_str_list={'','_P_B1','_P_B2','_P_A','_P_T1','_T1_T','_A_T'};
        H_sign_str_list={'n/a','-','+','+','-','+','-'};
        IL_orifice_str_list={'','_PB','','_PA','_PT','','_AT'};
        IL_sign_str_list={'n/a','+-','','+','0','','-'};
        valve_configurations={'2','12','3'};
    case 'k'
        H_orifice_str_list={'','_P_A2','_P_A1','_P_B','_T1_T','_P_T1','_B_T'};
        H_sign_str_list={'n/a','-','+','-','-','+','+'};
        IL_orifice_str_list={'','_PA','','_PB','_PT','','_BT'};
        IL_sign_str_list={'n/a','+-','','-','0','','+'};
        valve_configurations={'1','12','2'};
    end


    if~isempty(letter)
        set_param(hBlock,'open_orifices_pos',valve_configurations{1});
        set_param(hBlock,'open_orifices_neu',valve_configurations{2});
        set_param(hBlock,'open_orifices_neg',valve_configurations{3});
    end


    set_param(hBlock,'neutral_assert_action','0');



    for i=2:length(H_orifice_str_list)

        or_type=IL_sign_str_list(i);
        OR=H_orifice_str_list{i};


        if strcmp(or_type,'+')||strcmp(or_type,'-')

            sign_str=H_sign_str_list{i};
            [params,math_expression]=get_S_max_expression(params,OR,sign_str,mdl_type,area_spec_H);
            il_param_name=['S_max',IL_orifice_str_list{i}];
            dialog_unit_expression=['x_0',OR];
            derived_S_max=HtoIL_derive_params(il_param_name,math_expression,params,dialog_unit_expression,evaluate);
            HtoIL_apply_params(hBlock,{il_param_name},derived_S_max);


        elseif strcmp(or_type,'0')


            ORs=H_orifice_str_list(i:i+1);
            sign_strs=H_sign_str_list(i:i+1);


            not_sign_strs=cell(1,2);
            for j=1:2
                if strcmp(sign_strs{j},'+')
                    not_sign_strs{j}='-';
                else
                    not_sign_strs{j}='';
                end
            end


            math_expression=[not_sign_strs{1},'x_0',ORs{1},' + ',not_sign_strs{2},'x_0',ORs{2}];
            il_param_name='S_intersect';
            dialog_unit_expression=['x_0',ORs{1}];
            S_intersect=HtoIL_derive_params(il_param_name,math_expression,params,dialog_unit_expression,evaluate);
            S_intersect.base=['(',S_intersect.base,')/2'];
            params.S_intersect=S_intersect;





            if mdl_type==1


                math_expression1=[not_sign_strs{1},'opening_max/area_max*A_leak + ',not_sign_strs{1},'x_0',ORs{1}];
                math_expression2=[not_sign_strs{2},'opening_max/area_max*A_leak + ',not_sign_strs{2},'x_0',ORs{2}];

                S_min1=HtoIL_derive_params('Smin1',math_expression1,params,dialog_unit_expression,evaluate);
                S_min2=HtoIL_derive_params('Smin2',math_expression2,params,dialog_unit_expression,evaluate);

                params.opening_max_used=params.opening_max;
                params.opening_max_used.name='opening_max_used';

            else


                math_expression1=[not_sign_strs{1},'x_0',ORs{1}];
                math_expression2=[not_sign_strs{2},'x_0',ORs{2}];

                S_min1=HtoIL_derive_params('Smin1',math_expression1,params,dialog_unit_expression,evaluate);
                S_min2=HtoIL_derive_params('Smin2',math_expression2,params,dialog_unit_expression,evaluate);

                opening_tab_first=HtoIL_get_vector_element(params.opening_tab,'first');
                opening_tab_last=HtoIL_get_vector_element(params.opening_tab,'last');
                params.delS_max_1D=params.opening_tab;
                params.delS_max_1D.base=['(',opening_tab_last.base,') - (',opening_tab_first.base,')'];

                params.opening_max_used=opening_tab_last;
            end

            meanSmin.base=['( abs(',S_min1.base,') + abs(',S_min2.base,') )/2'];
            meanSmin.unit=S_min1.unit;
            if strcmp(S_min1.conf,'runtime')&&strcmp(S_min2.conf,'runtime')
                meanSmin.conf='runtime';
            else
                meanSmin.conf='compiletime';
            end
            params.meanSmin=meanSmin;



            Smax_saturated_expression='opening_max_used - meanSmin';

            Smax_saturated=HtoIL_derive_params('Smax_saturated',Smax_saturated_expression,params,dialog_unit_expression,evaluate);


            S_max.name=['S_max',IL_orifice_str_list{i}];
            S_max.unit=Smax_saturated.unit;
            S_max.base=['min(',S_intersect.base,', ',Smax_saturated.base,')'];
            if strcmp(S_intersect.conf,'runtime')&&strcmp(Smax_saturated.conf,'runtime')
                S_max.conf='runtime';
            else
                S_max.conf='compiletime';
            end

            HtoIL_apply_params(hBlock,{S_max.name},S_max);

        elseif strcmp(or_type,'+-')


            dialog_unit_expression=['x_0',OR];
            il_param_name=['S_max',IL_orifice_str_list{i}];


            sign_str=H_sign_str_list{i};
            [params,math_expression]=get_S_max_expression(params,OR,sign_str,mdl_type,area_spec_H);
            derived_S_max1=HtoIL_derive_params('S_max1',math_expression,params,dialog_unit_expression,evaluate);


            OR_2=H_orifice_str_list{i+1};
            sign_str_2=H_sign_str_list{i+2};
            [params,math_expression]=get_S_max_expression(params,OR_2,sign_str_2,mdl_type,area_spec_H);
            derived_S_max2=HtoIL_derive_params('S_max2',math_expression,params,dialog_unit_expression,evaluate);


            sign_str(sign_str=='+')='';
            sign_str_2(sign_str_2=='+')='';
            average_S_max.base=['(',sign_str,'(',derived_S_max1.base,') + ',sign_str_2,'(',derived_S_max2.base,') )/2'];
            average_S_max.unit=derived_S_max1.unit;
            if strcmp(derived_S_max1.conf,'runtime')&&strcmp(derived_S_max2.conf,'runtime')
                average_S_max.conf='runtime';
            else
                average_S_max.conf='compiletime';
            end

            HtoIL_apply_params(hBlock,{il_param_name},average_S_max);

        end
    end




    for i=1:length(H_orifice_str_list)

        or_type=IL_sign_str_list(i);
        il_name=['del_S_max',IL_orifice_str_list{i}];
        OR=H_orifice_str_list{i};
        if strcmp(or_type,'n/a')||strcmp(or_type,'+')||strcmp(or_type,'-')||strcmp(or_type,'+-')
            if strcmp(letter,'')
                math_expression=['opening_max',OR,' - opening_max',OR,'/area_max',OR,'*A_leak'];
                dialog_unit_expression=['opening_max',OR];
            else

                math_expression='opening_max - opening_max/area_max*A_leak';
                dialog_unit_expression='opening_max';
            end
            del_S_max=HtoIL_derive_params(il_name,math_expression,params,dialog_unit_expression,evaluate);
        elseif strcmp(or_type,'0')



            params.opening_max=HtoIL_derive_params('opening_max','opening_max',params,'meanSmin',evaluate);

            del_S_max.name=il_name;
            del_S_max.base=['min(',params.meanSmin.base,',',params.opening_max.base,')'];
            del_S_max.unit=params.opening_max.unit;
            if strcmp(params.meanSmin.conf,'runtime')&&strcmp(params.opening_max.conf,'runtime')
                del_S_max.conf='runtime';
            else
                del_S_max.conf='compiletime';
            end

        end

        HtoIL_apply_params(hBlock,{il_name},del_S_max);

    end



    if~strcmp(letter,'')
        for i=1:length(H_orifice_str_list)
            il_name=['area_max',IL_orifice_str_list{i}];
            or_type=IL_sign_str_list{i};
            OR=H_orifice_str_list{i};

            if strcmp(or_type,'+')||strcmp(or_type,'-')||strcmp(or_type,'-')||strcmp(or_type,'+-')

                HtoIL_apply_params(hBlock,{il_name},params.area_max);
            elseif strcmp(or_type,'0')


                math_expression=['area_max/opening_max*x_0',OR,' + ',H_sign_str_list{i},'area_max/opening_max*S_intersect'];
                dialog_unit_expression='area_max';
                A1_intersect=HtoIL_derive_params('A1_intersect',math_expression,params,dialog_unit_expression,evaluate);


                Amax_neutral=A1_intersect;
                Amax_neutral.base=['min((',A1_intersect.base,')./2^.5,',params.area_max.base,')'];


                HtoIL_apply_params(hBlock,{il_name},Amax_neutral);

            end
        end
    end



    if mdl_type==2||mdl_type==3


        for i=1:length(H_orifice_str_list)
            OR=H_orifice_str_list{i};
            or_type=IL_sign_str_list{i};
            if strcmp(or_type,'n/a')||strcmp(or_type,'+')||strcmp(or_type,'-')||strcmp(or_type,'+-')
                if isempty(letter)
                    del_S_TLU=params.(['opening_area_tab',OR]);
                    del_S_vol_flow_TLU=params.(['opening_flow_rate_tab',OR]);
                else
                    del_S_TLU=params.opening_area_tab;
                    del_S_vol_flow_TLU=params.opening_flow_rate_tab;
                end
                if mdl_type==2
                    del_S_TLU_first=HtoIL_get_vector_element(del_S_TLU,'first');
                    del_S_TLU.base=['(',del_S_TLU.base,') - (',del_S_TLU_first.base,')'];
                    HtoIL_apply_params(hBlock,{['del_S_TLU',IL_orifice_str_list{i}]},del_S_TLU);
                else
                    del_S_vol_flow_TLU_first=HtoIL_get_vector_element(del_S_vol_flow_TLU,'first');
                    del_S_vol_flow_TLU.base=['(',del_S_vol_flow_TLU.base,') - (',del_S_vol_flow_TLU_first.base,')'];
                    HtoIL_apply_params(hBlock,{['del_S_vol_flow_TLU',IL_orifice_str_list{i}]},del_S_vol_flow_TLU);
                end
            elseif strcmp(or_type,'0')



                del_S_TLU_init=params.opening_tab;
                del_S_TLU_init_first=HtoIL_get_vector_element(del_S_TLU_init,'first');
                del_S_TLU_init.base=['(',del_S_TLU_init.base,') - (',del_S_TLU_init_first.base,')'];
                params.del_S_TLU_init=del_S_TLU_init;



                sign_str=H_sign_str_list{i};

                dialog_unit_expression='opening_area_tab';
                [params,S_max_expression]=get_S_max_expression(params,OR,sign_str,mdl_type,area_spec_H);
                sign_str(sign_str=='+')='';
                math_expression=[sign_str,'S_intersect - ',sign_str,S_max_expression,' + delS_max_1D'];

                deltaS_maxNeed=HtoIL_derive_params('deltaS_maxNeed',math_expression,params,dialog_unit_expression,evaluate);
                deltaS_maxNeed.base=['min(',deltaS_maxNeed.base,', ',params.delS_max_1D.base,')'];


                last_ind_use=['max( find(',del_S_TLU_init.base,' < ',deltaS_maxNeed.base,', 1, ''last''), 1 )'];


                del_S_TLU=del_S_TLU_init;
                del_S_TLU.base=['[ getfield(',del_S_TLU_init.base,',{1:',last_ind_use,'}),  ',deltaS_maxNeed.base,']'];

                del_S_TLU_value=str2num(del_S_TLU.base);%#ok<ST2NM> for vector
                if~isempty(del_S_TLU_value)
                    del_S_TLU.base=mat2str(del_S_TLU_value);
                end

                if mdl_type==2
                    del_S_TLU.name=['del_S_TLU',IL_orifice_str_list{i}];
                else
                    del_S_TLU.name=['del_S_vol_flow_TLU',IL_orifice_str_list{i}];
                end
                HtoIL_apply_params(hBlock,{del_S_TLU.name},del_S_TLU);
            end
        end
    end


    if~strcmp(letter,'')&&mdl_type==2

        for i=1:length(H_orifice_str_list)
            or_type=IL_sign_str_list{i};
            valve_area_TLU=params.area_tab;


            if strcmp(or_type,'0')
                valve_area_TLU.base=['[ getfield(',valve_area_TLU.base,',{1:',last_ind_use,'}), interp1('...
                ,del_S_TLU_init.base,',',params.area_tab.base,',',deltaS_maxNeed.base,')]'];

                valve_area_TLU_value=str2num(valve_area_TLU.base);%#ok<ST2NM> for vector
                if~isempty(valve_area_TLU_value)
                    valve_area_TLU.base=mat2str(valve_area_TLU_value);
                end
                valve_area_TLU.base=['(',valve_area_TLU.base,')./2^.5'];

            elseif strcmp(or_type,'+-')

            end

            HtoIL_apply_params(hBlock,{['valve_area_TLU',IL_orifice_str_list{i}]},valve_area_TLU);
        end
    end


    if~strcmp(letter,'')&&mdl_type==3

        for i=1:length(H_orifice_str_list)
            or_type=IL_sign_str_list{i};
            vol_flow_TLU=params.flow_rate_tab;


            if strcmp(or_type,'0')
                vol_flow_TLU.base=['[ subsref(',params.flow_rate_tab.base,',struct(''type'',''()'',''subs'',{{1:',last_ind_use,',1:numel(',params.pressure_tab.base,')}}));'...
                ,'interp2(',params.pressure_tab.base,', ',del_S_TLU_init.base,',',params.flow_rate_tab.base,','...
                ,params.pressure_tab.base,',',deltaS_maxNeed.base,')]'];

                vol_flow_TLU_value=str2num(vol_flow_TLU.base);%#ok<ST2NM> for vector
                if~isempty(vol_flow_TLU_value)
                    vol_flow_TLU.base=mat2str(vol_flow_TLU_value);
                end
            end
            HtoIL_apply_params(hBlock,{['vol_flow_TLU',IL_orifice_str_list{i}]},vol_flow_TLU);


            p_diff_TLU=params.pressure_tab;
            if strcmp(or_type,'0')
                p_diff_TLU.base=['2.*(',p_diff_TLU.base,')'];
            end
            HtoIL_apply_params(hBlock,{['p_diff_TLU',IL_orifice_str_list{i}]},p_diff_TLU);

        end
    end





    if strcmp(letter,'b')||strcmp(letter,'c')
        if mdl_type~=3

            if letter=='b'
                area_const_param_name='area_const_PA';
            else
                area_const_param_name='area_const_PB';
            end
            HtoIL_apply_params(hBlock,{area_const_param_name},params.area);

        else






            vol_flow_TLU_const.name='vol_flow_TLU_const';
            vol_flow_TLU_const.base=['sqrt(2/850)*(0.7)*(',params.area.base,')*abs(',params.pressure_tab.base,').^0.5.*sign(',params.pressure_tab.base,')'];
            vol_flow_TLU_const.unit=['(m^3/kg)^0.5*',params.area.unit,'*(',params.pressure_tab.unit,')^0.5'];


            vol_flow_TLU_const_value=str2num(vol_flow_TLU_const.base);%#ok<ST2NM> for vector
            if~isempty(vol_flow_TLU_const_value)
                vol_flow_TLU_const.base=mat2str(vol_flow_TLU_const_value);
            end

            if strcmp(params.area.conf,'runtime')&&strcmp(params.pressure_tab.conf,'runtime')
                vol_flow_TLU_const.conf='runtime';
            else
                vol_flow_TLU_const.conf='compiletime';
            end


            if letter=='b'
                vol_flow_TLU_param_name='vol_flow_TLU_const_PA';
                p_diff_TLU_param_name='p_diff_TLU_const_PA';
            else
                vol_flow_TLU_param_name='vol_flow_TLU_const_PB';
                p_diff_TLU_param_name='p_diff_TLU_const_PB';
            end

            HtoIL_apply_params(hBlock,{vol_flow_TLU_param_name},vol_flow_TLU_const);
            HtoIL_apply_params(hBlock,{p_diff_TLU_param_name},params.pressure_tab);
        end
    end



    if any(strcmp(letter,{'d','e'}))
        set_param(hBlock,'area_spec','1');
    end



    warnings.messages={};


    if any(strcmp(letter,{'a','b','c','f','g','h','k'}))
        if any(letter==['a','h','k'])
            neutral_orifice_str='P-T';
        elseif any(letter==['b','f'])
            neutral_orifice_str='A-T';
        else
            neutral_orifice_str='B-T';
        end
        warnings.messages{end+1,1}=[neutral_orifice_str,' Orifice reparameterized. Adjustment of parameters on ',neutral_orifice_str,' Orifice tab may be required.'];
    end


    if any(strcmp(letter,{'d','e','f','g','h','k'}))
        if any(letter==['d','f','k'])
            posneg_orifice_str='P-A';
        else
            posneg_orifice_str='P-B';
        end
        warnings.messages{end+1,1}=['Spool position at maximum ',posneg_orifice_str,' Orifice area reparameterized. '...
        ,'Adjustment of Spool position at maximum ',posneg_orifice_str,' Orifice area may be required.'];
    end


    if mdl_type==3&&any(strcmp(letter,{'b','c'}))
        if letter=='b'
            constant_orifice_str='P-A';
        else
            constant_orifice_str='P-B';
        end
        warnings.messages{end+1,1}=[constant_orifice_str...
        ,' Constant volumetric flow-rate reparameterized assuming fluid density of 850 kg/m^3 and discharge coefficient of 0.7. '...
        ,'Adjustment of ',constant_orifice_str,' Constant volumetric flow rate vector may be required.'];
    end

    if lam_spec==1&&mdl_type~=3

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end


    if area_spec_H==2


        params.pressure_tab.base='pressure_tab';
        params.area_tab.base='area_tab';
        params.flow_rate_tab.base='flow_rate_tab';
    end
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    mdl_type,interp_method,extrap_method,...
    params.pressure_tab,params.area_tab,params.flow_rate_tab,'ascending',...
    'Spool travel vector','Orifice area vector',...
    'Pressure drop vector','Volumetric flow rate table');


    if~isempty(warnings.messages)
        out.warnings.messages=warnings.messages;
        out.warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;

end



function[params,math_expression]=get_S_max_expression(params,OR,sign_str,mdl_type,area_spec_H)


    if strcmp(sign_str,'+')
        not_or_str='-';
    else
        not_or_str='';
    end


    if mdl_type==1
        if area_spec_H==1
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_max'];
        else
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_max',OR];
        end

    elseif mdl_type==2
        if area_spec_H==1
            params.opening_area_tab_end=HtoIL_get_vector_element(params.opening_area_tab,'last');
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_area_tab_end'];
        else
            params.(['opening_area_tab',OR,'_end'])=HtoIL_get_vector_element(params.(['opening_area_tab',OR]),'last');
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_area_tab',OR,'_end'];
        end
    else
        if area_spec_H==1
            params.opening_flow_rate_tab_end=HtoIL_get_vector_element(params.opening_flow_rate_tab,'last');
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_flow_rate_tab_end'];
        else
            params.(['opening_flow_rate_tab',OR,'_end'])=HtoIL_get_vector_element(params.(['opening_flow_rate_tab',OR]),'last');
            math_expression=[not_or_str,'x_0',OR,sign_str,' opening_flow_rate_tab',OR,'_end'];
        end
    end
end

