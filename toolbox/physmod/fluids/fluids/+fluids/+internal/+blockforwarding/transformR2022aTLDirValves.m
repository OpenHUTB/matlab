function out=transformR2022aTLDirValves(in)







    out=in;
    blk=string(getClass(out));






    del_S_max=getValue(out,'del_S_max');
    if isempty(del_S_max)
        thisIsFirstFunctionRun=1;
    else
        thisIsFirstFunctionRun=0;
    end


    if thisIsFirstFunctionRun



        if strcmp(blk,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_2_way')
            area_spec=1;
            valve_spec=getValue(out,'valve_spec');
            original_orifice_names={''};
            new_orifice_names={''};
            open_orientations=1;
            isOrifices=1;
        elseif strcmp(blk,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way')
            area_spec_block=getValue(out,'area_spec');
            if isempty(area_spec_block)

                area_spec=1;
                valve_spec=getValue(out,'valve_area_spec');
            else
                area_spec=eval(area_spec_block);
                if area_spec==1
                    valve_spec=getValue(out,'valve_spec_identical');
                else
                    valve_spec=getValue(out,'valve_spec_different');
                end
            end
            original_orifice_names={'','_P','_T'};
            new_orifice_names={'','_PA','_AT'};
            open_orientations=[1,1,-1];
            isOrifices=[0,1,1];
        else
            area_spec_block=getValue(out,'area_spec');
            if isempty(area_spec_block)

                area_spec=1;
                valve_spec=getValue(out,'valve_area_spec');
            else
                area_spec=eval(area_spec_block);
                if area_spec==1
                    valve_spec=getValue(out,'valve_spec_identical');
                else
                    valve_spec=getValue(out,'valve_spec_different');
                end
            end
            original_orifice_names={'','_P_A','_P_B','_A_T','_B_T'};
            new_orifice_names={'','_PA','_PB','_AT','_BT'};
            open_orientations=[1,1,-1,-1,1];
            isOrifices=[0,1,1,1,1];
            out=setValue(out,'neutral_assert_action','simscape.enum.assert.action.none');
        end


        valve_spec_val=eval(valve_spec);
        if valve_spec_val==1||valve_spec_val==2

            out=setValue(out,'valve_spec',valve_spec);
        else

            out=setValue(out,'valve_spec','fluids.thermal_liquid.valves.enum.orifice_spec.table2D_massflow_opening_pressure');
        end


        for i=1:length(original_orifice_names)

            OR_orig=original_orifice_names{i};
            OR_new=new_orifice_names{i};
            open_orientation=open_orientations(i);
            isOrifice=isOrifices(i);

            if area_spec==1
                orig_param_suffix='';
            else
                orig_param_suffix=OR_orig;
            end


            P=struct;
            P=get_params(out,P,'area_leak','');
            P=get_params(out,P,'opening_max',orig_param_suffix);
            P=get_params(out,P,'area_max',orig_param_suffix);
            if isOrifice
                P=get_params(out,P,'x0',OR_orig);
            end
            P=get_params(out,P,'opening_TLU',orig_param_suffix);
            P=get_params(out,P,'valve_area_TLU',orig_param_suffix);
            P=get_params(out,P,'opening_mdot_TLU',orig_param_suffix);
            P=get_params(out,P,'p_diff_TLU',orig_param_suffix);
            P=get_params(out,P,'mdot_TLU',orig_param_suffix);
            P=get_params(out,P,'T_ref_in',orig_param_suffix);
            P=get_params(out,P,'p_ref_in',orig_param_suffix);

            if isOrifice


                expr1=['(',P.opening_max,')*(',P.area_leak,')/(',P.area_max,')'];
                unit1=[P.opening_max_unit,'*',P.area_leak_unit,'/(',P.area_max_unit,')'];
                if valve_spec_val==1

                    expr1_converted=convertUnits(expr1,unit1,P.x0_unit);
                    if open_orientation==1
                        S_min=[expr1_converted,' - (',P.x0,')'];
                    else
                        S_min=['-',expr1_converted,' + (',P.x0,')'];
                    end
                    S_min_conf=getExprConf({P.opening_max_conf,P.area_leak_conf,P.area_max_conf,P.x0_conf});
                elseif valve_spec_val==2

                    opening_TLU_first=getVectorFirstLastElement(P.opening_TLU,'first');
                    opening_TLU_first_converted=convertUnits(opening_TLU_first,P.opening_TLU_unit,P.x0_unit);
                    if open_orientation==1
                        S_min=[opening_TLU_first_converted,' - (',P.x0,')'];
                    else
                        S_min=['-(',opening_TLU_first_converted,') + (',P.x0,')'];
                    end
                    S_min_conf=getExprConf({P.opening_TLU_conf,P.x0_conf});
                else

                    opening_mdot_TLU_first=getVectorFirstLastElement(P.opening_mdot_TLU,'first');
                    opening_mdot_TLU_first_converted=convertUnits(opening_mdot_TLU_first,P.opening_mdot_TLU_unit,P.x0_unit);
                    if open_orientation==1
                        S_min=[opening_mdot_TLU_first_converted,' - (',P.x0,')'];
                    else
                        S_min=['-(',opening_mdot_TLU_first_converted,') + (',P.x0,')'];
                    end
                    S_min_conf=getExprConf({P.opening_mdot_TLU_conf,P.x0_conf});
                end

                S_min_eval=protectedNumericConversion(S_min);
                if~isempty(S_min_eval)
                    S_min=num2str(double(S_min_eval),16);
                end
                S_min_unit=P.x0_unit;
            end



            expr2=['(',P.opening_max,')*(',P.area_leak,')/(',P.area_max,')'];
            unit2=[P.opening_max_unit,'*',P.area_leak_unit,'/(',P.area_max_unit,')'];
            expr2_converted=convertUnits(expr2,unit2,P.opening_max_unit);
            del_S_max=[P.opening_max,'-',expr2_converted];

            del_S_max_eval=protectedNumericConversion(del_S_max);
            if~isempty(del_S_max_eval)
                del_S_max=num2str(double(del_S_max_eval),16);
            end
            del_S_max_unit=P.opening_max_unit;
            del_S_max_conf=getExprConf({P.opening_max_conf,P.area_leak_conf,P.area_max_conf,P.opening_max_conf});

            out=setValue(out,['del_S_max',OR_new],del_S_max);
            out=setUnit(out,['del_S_max',OR_new],del_S_max_unit);
            out=setRTConfig(out,['del_S_max',OR_new],del_S_max_conf);




            opening_TLU_first=getVectorFirstLastElement(P.opening_TLU,'first');
            del_S_TLU=[P.opening_TLU,' - (',opening_TLU_first,')'];

            del_S_TLU_eval=protectedNumericConversion(del_S_TLU);
            if~isempty(del_S_TLU_eval)
                del_S_TLU_eval(1)=0;
                del_S_TLU=mat2str(double(del_S_TLU_eval),16);
            end
            del_S_TLU_unit=P.opening_TLU_unit;
            del_S_TLU_conf=P.opening_TLU_conf;

            out=setValue(out,['del_S_TLU',OR_new],del_S_TLU);
            out=setUnit(out,['del_S_TLU',OR_new],del_S_TLU_unit);
            out=setRTConfig(out,['del_S_TLU',OR_new],del_S_TLU_conf);




            if~isempty(P.opening_mdot_TLU)
                opening_mdot_TLU_first=getVectorFirstLastElement(P.opening_mdot_TLU,'first');
                del_S_flow_TLU=[P.opening_mdot_TLU,' - (',opening_mdot_TLU_first,')'];

                del_S_flow_TLU_eval=protectedNumericConversion(del_S_flow_TLU);
                if~isempty(del_S_flow_TLU_eval)
                    del_S_flow_TLU_eval(1)=0;
                    del_S_flow_TLU=mat2str(double(del_S_flow_TLU_eval),16);
                end
                del_S_flow_TLU_unit=P.opening_mdot_TLU_unit;
                del_S_flow_TLU_conf=P.opening_mdot_TLU_conf;

                out=setValue(out,['del_S_flow_TLU',OR_new],del_S_flow_TLU);
                out=setUnit(out,['del_S_flow_TLU',OR_new],del_S_flow_TLU_unit);
                out=setRTConfig(out,['del_S_flow_TLU',OR_new],del_S_flow_TLU_conf);
            end



            if isOrifice
                if valve_spec_val==1

                    del_S_max_converted=convertUnits(del_S_max,del_S_max_unit,S_min_unit);
                    if open_orientation==1
                        S_max=[S_min,' + ',del_S_max_converted];
                    else
                        S_max=[S_min,' - (',del_S_max_converted,')'];
                    end
                    S_max_conf=getExprConf({S_min_conf,del_S_max_conf});
                elseif valve_spec_val==2

                    del_S_TLU_end=getVectorFirstLastElement(del_S_TLU,'last');
                    del_S_TLU_end_converted=convertUnits(del_S_TLU_end,del_S_TLU_unit,S_min_unit);
                    if open_orientation==1
                        S_max=[S_min,' + ',del_S_TLU_end_converted];
                    else
                        S_max=[S_min,' - (',del_S_TLU_end_converted,')'];
                    end
                    S_max_conf=getExprConf({S_min_conf,del_S_TLU_conf});
                else






                    del_S_flow_TLU_end=getVectorFirstLastElement(del_S_flow_TLU,'last');
                    del_S_flow_TLU_end_converted=convertUnits(del_S_flow_TLU_end,del_S_flow_TLU_unit,S_min_unit);
                    if open_orientation==1
                        S_max=[S_min,' + ',del_S_flow_TLU_end_converted];
                    else
                        S_max=[S_min,' - (',del_S_flow_TLU_end_converted,')'];
                    end
                    S_max_conf=getExprConf({S_min_conf,del_S_flow_TLU_conf});
                end
                S_max_eval=protectedNumericConversion(S_max);
                if~isempty(S_max_eval)
                    S_max=mat2str(double(S_max_eval),16);
                end
                S_max_unit=S_min_unit;

                out=setValue(out,['S_max',OR_new],S_max);
                out=setUnit(out,['S_max',OR_new],S_max_unit);
                out=setRTConfig(out,['S_max',OR_new],S_max_conf);
            end








            params={'area_max','valve_area_TLU','p_diff_TLU','mdot_TLU','T_ref_in','p_ref_in'};
            for j=1:length(params)
                param=params{j};
                if~isempty(param)

                    out=setValue(out,[param,OR_new],P.(param));
                    out=setUnit(out,[param,OR_new],P.([param,'_unit']));
                    out=setRTConfig(out,[param,OR_new],P.([param,'_conf']));
                end
            end

        end








        if area_spec==2
            if strcmp(blk,'fluids.thermal_liquid.valves.directional_control_valves.directional_valve_3_way')
                P=get_params(out,P,'p_ref_in','_P');
                P=get_params(out,P,'T_ref_in','_P');
            else
                P=get_params(out,P,'p_ref_in','_P_A');
                P=get_params(out,P,'T_ref_in','_P_A');
            end
            if~isempty(P.p_ref_in)
                out=setValue(out,'p_ref_in',P.p_ref_in);
                out=setUnit(out,'p_ref_in',P.p_ref_in_unit);
                out=setRTConfig(out,'p_ref_in',P.p_ref_in_conf);

                out=setValue(out,'T_ref_in',P.T_ref_in);
                out=setUnit(out,'T_ref_in',P.T_ref_in_unit);
                out=setRTConfig(out,'T_ref_in',P.T_ref_in_conf);
            end
        end


        out=setValue(out,'pressure_recovery','simscape.enum.onoff.on');

    end

end


function conf=getExprConf(s2)



    if all(strcmp('runtime',s2))
        conf='runtime';
    else
        conf='compiletime';
    end

end


function paramStruct=get_params(out,paramStruct,param,OR_name)
    paramStruct.(param)=stripComments(getValue(out,[param,OR_name]));
    paramStruct.([param,'_unit'])=getUnit(out,[param,OR_name]);
    paramStruct.([param,'_conf'])=getRTConfig(out,[param,OR_name]);

end