function out=transformR2022bGasOrificeParameterization(in)






    out=in;


    pressure_spec=getValue(out,'pressure_spec');
    if~isempty(pressure_spec)
        if strcmp(pressure_spec,'fluids.gas.enum.pressure_control_spec.dp')||strcmp(pressure_spec,'1')
            out=setValue(out,'opening_pressure_spec','fluids.gas.valves_orifices.enum.PressureControlSpec.PressureDifference');
        elseif strcmp(pressure_spec,'fluids.gas.enum.pressure_control_spec.pA')||strcmp(pressure_spec,'2')
            out=setValue(out,'opening_pressure_spec','fluids.gas.valves_orifices.enum.PressureControlSpec.PressureA');
        end
    end

    iso_cond_spec=getValue(out,'iso_cond_spec');
    if~isempty(iso_cond_spec)

        out=setValue(out,'orifice_parameterization','fluids.gas.valves_orifices.enum.OrificeParameterization.SonicConductance');
        out=setValue(out,'valve_parameterization','fluids.gas.valves_orifices.enum.OrificeParameterization.SonicConductance');

        if strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.conductance')||strcmp(iso_cond_spec,'1')

            iso_opening_spec=getValue(out,'iso_opening_spec_C');
            if isempty(iso_opening_spec)
                iso_opening_spec=getValue(out,'iso_opening_spec');
            end

            if isempty(iso_opening_spec)

                out=setValue(out,'C_constant',getValue(out,'C'));
                out=setUnit(out,'C_constant',getUnit(out,'C'));
                out=setRTConfig(out,'C_constant',getRTConfig(out,'C'));

                out=setValue(out,'B_crit_constant',getValue(out,'B_crit'));
                out=setRTConfig(out,'B_crit_constant',getRTConfig(out,'B_crit'));
            else

                C_max=getValue(out,'C_max');
                C_max_unit=getUnit(out,'C_max');
                C_max_conf=getRTConfig(out,'C_max');

                C_min=getValue(out,'C_min');
                C_min_unit=getUnit(out,'C_min');
                C_min_conf=getRTConfig(out,'C_min');

                out=setValue(out,'B_crit_linear',getValue(out,'B_crit'));
                out=setRTConfig(out,'B_crit_linear',getRTConfig(out,'B_crit'));

                out=setValue(out,'L_C_TLU',getValue(out,'opening_C_TLU'));
                out=setRTConfig(out,'L_C_TLU',getRTConfig(out,'opening_C_TLU'));


                unit_conv=num2str(value(simscape.Value(1,C_min_unit),C_max_unit));
                out=setValue(out,'leakage_fraction',['(',C_min,')/(',C_max,') * ',unit_conv]);
                if strcmp(C_max_conf,'runtime')||strcmp(C_min_conf,'runtime')
                    out=setRTConfig(out,'leakage_fraction','runtime');
                end


                if strcmp(getClass(out),'fluids.gas.valves_orifices.pressure_control_valves.pressure_reducing_valve')
                    out=setValue(out,'p_set_gauge',getValue(out,'p_set_gauge_C'));
                    out=setUnit(out,'p_set_gauge',getUnit(out,'p_set_gauge_C'));
                    out=setRTConfig(out,'p_set_gauge',getRTConfig(out,'p_set_gauge_C'));

                    out=setValue(out,'p_range',getValue(out,'p_range_C'));
                    out=setUnit(out,'p_range',getUnit(out,'p_range_C'));
                    out=setRTConfig(out,'p_range',getRTConfig(out,'p_range_C'));
                end


                out=setValue(out,'p_diff_C_TLU',getValue(out,'p_control_C_TLU'));
                out=setUnit(out,'p_diff_C_TLU',getUnit(out,'p_control_C_TLU'));
                out=setRTConfig(out,'p_diff_C_TLU',getRTConfig(out,'p_control_C_TLU'));

                out=setValue(out,'p_gauge_C_TLU',getValue(out,'p_control_C_TLU'));
                out=setUnit(out,'p_gauge_C_TLU',getUnit(out,'p_control_C_TLU'));
                out=setRTConfig(out,'p_gauge_C_TLU',getRTConfig(out,'p_control_C_TLU'));


                if strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.linear')||strcmp(iso_opening_spec,'1')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Linear');
                elseif strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.tabulated')||strcmp(iso_opening_spec,'2')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Tabulated');
                end
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.Cv')||strcmp(iso_cond_spec,'2')

            iso_opening_spec=getValue(out,'iso_opening_spec_Cv');
            if isempty(iso_opening_spec)
                iso_opening_spec=getValue(out,'iso_opening_spec');
            end

            if isempty(iso_opening_spec)

                Cv=getValue(out,'Cv');
                Cv_conf=getRTConfig(out,'Cv');


                out=setValue(out,'C_constant',['4e-8 * (',Cv,')']);
                out=setUnit(out,'C_constant','m^3/(s*Pa)');
                out=setRTConfig(out,'C_constant',Cv_conf);

                out=setValue(out,'B_crit_constant','0.3');

                out=setValue(out,'m','0.5');
            else

                Cv_max=getValue(out,'Cv_max');
                Cv_max_conf=getRTConfig(out,'Cv_max');

                Cv_min=getValue(out,'Cv_min');
                Cv_min_conf=getRTConfig(out,'Cv_min');

                Cv_TLU=getValue(out,'Cv_TLU');
                Cv_TLU_conf=getRTConfig(out,'Cv_TLU');


                out=setValue(out,'C_max',['4e-8 * (',Cv_max,')']);
                out=setUnit(out,'C_max','m^3/(s*Pa)');
                out=setRTConfig(out,'C_max',Cv_max_conf);

                out=setValue(out,'B_crit_linear','0.3');

                out=setValue(out,'L_C_TLU',getValue(out,'opening_Cv_TLU'));
                out=setRTConfig(out,'L_C_TLU',getRTConfig(out,'opening_Cv_TLU'));

                out=setValue(out,'C_TLU',['4e-8 * (',Cv_TLU,')']);
                out=setUnit(out,'C_TLU','m^3/(s*Pa)');
                out=setRTConfig(out,'C_TLU',Cv_TLU_conf);

                out=setValue(out,'B_crit_TLU',['0.3 * ones(size(',Cv_TLU,'))']);

                out=setValue(out,'m','0.5');


                out=setValue(out,'leakage_fraction',['(',Cv_min,')/(',Cv_max,')']);
                if strcmp(Cv_max_conf,'runtime')||strcmp(Cv_min_conf,'runtime')
                    out=setRTConfig(out,'leakage_fraction','runtime');
                end


                if strcmp(getClass(out),'fluids.gas.valves_orifices.pressure_control_valves.pressure_reducing_valve')
                    out=setValue(out,'p_set_gauge',getValue(out,'p_set_gauge_Cv'));
                    out=setUnit(out,'p_set_gauge',getUnit(out,'p_set_gauge_Cv'));
                    out=setRTConfig(out,'p_set_gauge',getRTConfig(out,'p_set_gauge_Cv'));

                    out=setValue(out,'p_range',getValue(out,'p_range_Cv'));
                    out=setUnit(out,'p_range',getUnit(out,'p_range_Cv'));
                    out=setRTConfig(out,'p_range',getRTConfig(out,'p_range_Cv'));
                end


                out=setValue(out,'p_diff_C_TLU',getValue(out,'p_control_Cv_TLU'));
                out=setUnit(out,'p_diff_C_TLU',getUnit(out,'p_control_Cv_TLU'));
                out=setRTConfig(out,'p_diff_C_TLU',getRTConfig(out,'p_control_Cv_TLU'));

                out=setValue(out,'p_gauge_C_TLU',getValue(out,'p_control_Cv_TLU'));
                out=setUnit(out,'p_gauge_C_TLU',getUnit(out,'p_control_Cv_TLU'));
                out=setRTConfig(out,'p_gauge_C_TLU',getRTConfig(out,'p_control_Cv_TLU'));


                if strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.linear')||strcmp(iso_opening_spec,'1')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Linear');
                elseif strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.tabulated')||strcmp(iso_opening_spec,'2')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Tabulated');
                end
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.Kv')||strcmp(iso_cond_spec,'3')

            iso_opening_spec=getValue(out,'iso_opening_spec_Kv');
            if isempty(iso_opening_spec)
                iso_opening_spec=getValue(out,'iso_opening_spec');
            end

            if isempty(iso_opening_spec)

                Kv=getValue(out,'Kv');
                Kv_conf=getRTConfig(out,'Kv');


                out=setValue(out,'C_constant',['4.78e-8 * (',Kv,')']);
                out=setUnit(out,'C_constant','m^3/(s*Pa)');
                out=setRTConfig(out,'C_constant',Kv_conf);

                out=setValue(out,'B_crit_constant','0.3');
                out=setRTConfig(out,'B_crit_constant',Kv_conf);

                out=setValue(out,'m','0.5');
                out=setRTConfig(out,'m',Kv_conf);
            else

                Kv_max=getValue(out,'Kv_max');
                Kv_max_conf=getRTConfig(out,'Kv_max');

                Kv_min=getValue(out,'Kv_min');
                Kv_min_conf=getRTConfig(out,'Kv_min');

                Kv_TLU=getValue(out,'Kv_TLU');
                Kv_TLU_conf=getRTConfig(out,'Kv_TLU');


                out=setValue(out,'C_max',['4.78e-8 * (',Kv_max,')']);
                out=setUnit(out,'C_max','m^3/(s*Pa)');
                out=setRTConfig(out,'C_max',Kv_max_conf);

                out=setValue(out,'B_crit_linear','0.3');

                out=setValue(out,'L_C_TLU',getValue(out,'opening_Kv_TLU'));
                out=setRTConfig(out,'L_C_TLU',getRTConfig(out,'opening_Kv_TLU'));

                out=setValue(out,'C_TLU',['4.78e-8 * (',Kv_TLU,')']);
                out=setUnit(out,'C_TLU','m^3/(s*Pa)');
                out=setRTConfig(out,'C_TLU',Kv_TLU_conf);

                out=setValue(out,'B_crit_TLU',['0.3 * ones(size(',Kv_TLU,'))']);

                out=setValue(out,'m','0.5');


                out=setValue(out,'leakage_fraction',['(',Kv_min,')/(',Kv_max,')']);
                if strcmp(Kv_max_conf,'runtime')||strcmp(Kv_min_conf,'runtime')
                    out=setRTConfig(out,'leakage_fraction','runtime');
                end


                if strcmp(getClass(out),'fluids.gas.valves_orifices.pressure_control_valves.pressure_reducing_valve')
                    out=setValue(out,'p_set_gauge',getValue(out,'p_set_gauge_Kv'));
                    out=setUnit(out,'p_set_gauge',getUnit(out,'p_set_gauge_Kv'));
                    out=setRTConfig(out,'p_set_gauge',getRTConfig(out,'p_set_gauge_Kv'));

                    out=setValue(out,'p_range',getValue(out,'p_range_Kv'));
                    out=setUnit(out,'p_range',getUnit(out,'p_range_Kv'));
                    out=setRTConfig(out,'p_range',getRTConfig(out,'p_range_Kv'));
                end


                out=setValue(out,'p_diff_C_TLU',getValue(out,'p_control_Kv_TLU'));
                out=setUnit(out,'p_diff_C_TLU',getUnit(out,'p_control_Kv_TLU'));
                out=setRTConfig(out,'p_diff_C_TLU',getRTConfig(out,'p_control_Kv_TLU'));

                out=setValue(out,'p_gauge_C_TLU',getValue(out,'p_control_Kv_TLU'));
                out=setUnit(out,'p_gauge_C_TLU',getUnit(out,'p_control_Kv_TLU'));
                out=setRTConfig(out,'p_gauge_C_TLU',getRTConfig(out,'p_control_Kv_TLU'));


                if strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.linear')||strcmp(iso_opening_spec,'1')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Linear');
                elseif strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.tabulated')||strcmp(iso_opening_spec,'2')
                    out=setValue(out,'opening_characteristic',...
                    'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Tabulated');
                end
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.area')||strcmp(iso_cond_spec,'4')

            iso_opening_spec=getValue(out,'iso_opening_spec_area');
            if isempty(iso_opening_spec)
                iso_opening_spec=getValue(out,'iso_opening_spec');
            end

            if isempty(iso_opening_spec)

                restriction_area=getValue(out,'restriction_area');
                restriction_area_unit=getUnit(out,'restriction_area');
                restriction_area_conf=getRTConfig(out,'restriction_area');

                area=getValue(out,'area');
                area_unit=getUnit(out,'area');
                area_conf=getRTConfig(out,'area');


                unit_conv=num2str(value(simscape.Value(1,restriction_area_unit),'mm^2'));
                out=setValue(out,'C_constant',['0.128 * (',restriction_area,') * ',unit_conv,' * 4/pi']);
                out=setUnit(out,'C_constant','l/(s*bar)');
                out=setRTConfig(out,'C_constant',restriction_area_conf);

                unit_conv=num2str(value(simscape.Value(1,restriction_area_unit),area_unit));
                out=setValue(out,'B_crit_constant',['0.41 + 0.272 * ((',restriction_area,')/(',area,') * ',unit_conv,')^0.25']);
                if strcmp(restriction_area_conf,'runtime')||strcmp(area_conf,'runtime')
                    out=setRTConfig(out,'B_crit_constant','runtime');
                end

                out=setValue(out,'m','0.5');
            else

                area=getValue(out,'area');
                area_unit=getUnit(out,'area');
                area_conf=getRTConfig(out,'area');

                out=setValue(out,'m','0.5');


                out=setValue(out,'opening_characteristic',...
                'fluids.gas.valves_orifices.enum.OpeningCharacteristics.Tabulated');

                if strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.linear')||strcmp(iso_opening_spec,'1')
                    restriction_area_max=getValue(out,'restriction_area_max');
                    restriction_area_max_unit=getUnit(out,'restriction_area_max');
                    restriction_area_max_conf=getRTConfig(out,'restriction_area_max');
                    if isempty(restriction_area_max)
                        restriction_area_max=getValue(out,'area_max');
                        restriction_area_max_unit=getUnit(out,'area_max');
                        restriction_area_max_conf=getRTConfig(out,'area_max');
                    end

                    restriction_area_min=getValue(out,'restriction_area_min');
                    restriction_area_min_unit=getUnit(out,'restriction_area_min');
                    restriction_area_min_conf=getRTConfig(out,'restriction_area_min');
                    if isempty(restriction_area_min)
                        restriction_area_min=getValue(out,'area_leak');
                        restriction_area_min_unit=getUnit(out,'area_leak');
                        restriction_area_min_conf=getRTConfig(out,'area_leak');
                    end

                    p_set_differential=getValue(out,'p_set_differential');
                    p_set_differential_unit=getUnit(out,'p_set_differential');
                    p_set_differential_conf=getRTConfig(out,'p_set_differential');

                    p_set_gauge=getValue(out,'p_set_gauge');
                    p_set_gauge_unit=getUnit(out,'p_set_gauge');
                    p_set_gauge_conf=getRTConfig(out,'p_set_gauge');

                    p_range=getValue(out,'p_range');
                    p_range_unit=getUnit(out,'p_range');
                    p_range_conf=getRTConfig(out,'p_range');

                    p_set_gauge_area=getValue(out,'p_set_gauge_area');
                    p_set_gauge_area_unit=getUnit(out,'p_set_gauge_area');
                    p_set_gauge_area_conf=getRTConfig(out,'p_set_gauge_area');

                    p_range_area=getValue(out,'p_range_area');
                    p_range_area_unit=getUnit(out,'p_range_area');
                    p_range_area_conf=getRTConfig(out,'p_range_area');


                    out=setValue(out,'L_C_TLU','[0; 1]');

                    unit_conv_min=num2str(value(simscape.Value(1,restriction_area_min_unit),'mm^2'));
                    unit_conv_max=num2str(value(simscape.Value(1,restriction_area_max_unit),'mm^2'));
                    out=setValue(out,'C_TLU',['0.128 * [(',restriction_area_min,')*',unit_conv_min,'; (',restriction_area_max,')*',unit_conv_max,' ] * 4/pi']);
                    out=setUnit(out,'C_TLU','l/(s*bar)');
                    if strcmp(restriction_area_min_conf,'runtime')||strcmp(restriction_area_max_conf,'runtime')
                        out=setRTConfig(out,'C_TLU','runtime');
                    end

                    unit_conv_min=num2str(value(simscape.Value(1,restriction_area_min_unit),area_unit));
                    unit_conv_max=num2str(value(simscape.Value(1,restriction_area_max_unit),area_unit));
                    out=setValue(out,'B_crit_TLU',['0.41 + 0.272 * ([(',restriction_area_min,')*',unit_conv_min,'; (',restriction_area_max,')*',unit_conv_max,'] / (',area,')).^0.25']);
                    if strcmp(restriction_area_min_conf,'runtime')||strcmp(restriction_area_max_conf,'runtime')||strcmp(area_conf,'runtime')
                        out=setRTConfig(out,'B_crit_TLU','runtime');
                    end


                    if strcmp(getClass(out),'fluids.gas.valves_orifices.pressure_control_valves.pressure_relief_valve')
                        unit_conv=num2str(value(simscape.Value(1,p_range_unit),p_set_differential_unit));
                        out=setValue(out,'p_diff_C_TLU',['(',p_set_differential,') + [0; (',p_range,')*',unit_conv,']']);
                        out=setUnit(out,'p_diff_C_TLU',p_set_differential_unit);
                        if strcmp(p_set_differential_conf,'runtime')||strcmp(p_range_conf,'runtime')
                            out=setRTConfig(out,'p_diff_C_TLU','runtime');
                        end

                        unit_conv=num2str(value(simscape.Value(1,p_range_unit),p_set_gauge_unit));
                        out=setValue(out,'p_gauge_C_TLU',['(',p_set_gauge,') + [0; (',p_range,')*',unit_conv,']']);
                        out=setUnit(out,'p_gauge_C_TLU',p_set_gauge_unit);
                        if strcmp(p_set_gauge_conf,'runtime')||strcmp(p_range_conf,'runtime')
                            out=setRTConfig(out,'p_gauge_C_TLU','runtime');
                        end
                    end


                    if strcmp(getClass(out),'fluids.gas.valves_orifices.pressure_control_valves.pressure_reducing_valve')
                        unit_conv=num2str(value(simscape.Value(1,p_range_area_unit),p_set_gauge_area_unit));
                        out=setValue(out,'p_gauge_C_TLU',['(',p_set_gauge_area,') + [0; (',p_range_area,')*',unit_conv,']']);
                        out=setUnit(out,'p_gauge_C_TLU',p_set_gauge_area_unit);
                        if strcmp(p_set_gauge_area_conf,'runtime')||strcmp(p_range_area_conf,'runtime')
                            out=setRTConfig(out,'p_gauge_C_TLU','runtime');
                        end
                    end

                elseif strcmp(iso_opening_spec,'fluids.gas.enum.iso_opening_spec.tabulated')||strcmp(iso_opening_spec,'2')
                    restriction_area_TLU=getValue(out,'restriction_area_TLU');
                    restriction_area_TLU_unit=getUnit(out,'restriction_area_TLU');
                    restriction_area_TLU_conf=getRTConfig(out,'restriction_area_TLU');


                    out=setValue(out,'L_C_TLU',getValue(out,'opening_area_TLU'));
                    out=setRTConfig(out,'L_C_TLU',getRTConfig(out,'opening_area_TLU'));

                    unit_conv=num2str(value(simscape.Value(1,restriction_area_TLU_unit),'mm^2'));
                    out=setValue(out,'C_TLU',['0.128 * (',restriction_area_TLU,') * ',unit_conv,' * 4/pi']);
                    out=setUnit(out,'C_TLU','l/(s*bar)');
                    out=setRTConfig(out,'C_TLU',restriction_area_TLU_conf);

                    unit_conv=num2str(value(simscape.Value(1,restriction_area_TLU_unit),area_unit));
                    out=setValue(out,'B_crit_TLU',['0.41 + 0.272 * ((',restriction_area_TLU,')/(',area,') * ',unit_conv,').^0.25']);
                    if strcmp(restriction_area_TLU_conf,'runtime')||strcmp(area_conf,'runtime')
                        out=setRTConfig(out,'B_crit_TLU','runtime');
                    end


                    out=setValue(out,'p_diff_C_TLU',getValue(out,'p_control_area_TLU'));
                    out=setUnit(out,'p_diff_C_TLU',getUnit(out,'p_control_area_TLU'));
                    out=setRTConfig(out,'p_diff_C_TLU',getRTConfig(out,'p_control_area_TLU'));

                    out=setValue(out,'p_gauge_C_TLU',getValue(out,'p_control_area_TLU'));
                    out=setUnit(out,'p_gauge_C_TLU',getUnit(out,'p_control_area_TLU'));
                    out=setRTConfig(out,'p_gauge_C_TLU',getRTConfig(out,'p_control_area_TLU'));
                end
            end
        end
    end


    out=setValue(out,'rho_ref_C',getValue(out,'rho0'));
    out=setUnit(out,'rho_ref_C',getUnit(out,'rho0'));
    out=setRTConfig(out,'rho_ref_C',getRTConfig(out,'rho0'));

    out=setValue(out,'T_ref_C',getValue(out,'T0'));
    out=setUnit(out,'T_ref_C',getUnit(out,'T0'));
    out=setRTConfig(out,'T_ref_C',getRTConfig(out,'T0'));

end