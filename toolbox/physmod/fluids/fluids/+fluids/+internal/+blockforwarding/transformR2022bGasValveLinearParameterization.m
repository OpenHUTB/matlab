function out=transformR2022bGasValveLinearParameterization(in)






    out=in;


    pressure_spec=getValue(out,'pressure_spec');
    if~isempty(pressure_spec)
        if strcmp(pressure_spec,'fluids.gas.enum.pressure_control_spec.dp')||strcmp(pressure_spec,'1')
            out=setValue(out,'opening_pressure_spec','fluids.gas.valves_orifices.enum.PressureControlSpec.PressureDifference');
        elseif strcmp(pressure_spec,'fluids.gas.enum.pressure_control_spec.pA')||strcmp(pressure_spec,'2')
            out=setValue(out,'opening_pressure_spec','fluids.gas.valves_orifices.enum.PressureControlSpec.PressureA');
        end
    end


    pressure_spec=getValue(out,'pressure_spec');
    if~isempty(pressure_spec)
        if strcmp(pressure_spec,'fluids.gas.enum.pilot_pressure_control_spec.dp')||strcmp(pressure_spec,'1')
            out=setValue(out,'pilot_pressure_spec','fluids.gas.valves_orifices.directional_control_valves.enum.PilotPressureControlSpec.PressureDifference');
            out=setValue(out,'pilot_config','fluids.gas.valves_orifices.directional_control_valves.enum.PilotConfig.Disconnected');
        elseif strcmp(pressure_spec,'fluids.gas.enum.pilot_pressure_control_spec.pX')||strcmp(pressure_spec,'2')
            out=setValue(out,'pilot_pressure_spec','fluids.gas.valves_orifices.directional_control_valves.enum.PilotPressureControlSpec.PressureX');
            out=setValue(out,'pilot_config','fluids.gas.valves_orifices.directional_control_valves.enum.PilotConfig.Connected');
        end
    end


    valve_operation=getValue(out,'valve_operation');
    if~isempty(valve_operation)
        if strcmp(valve_operation,'fluids.gas.enum.temperature_valve_spec.open')||strcmp(valve_operation,'1')
            out=setValue(out,'valve_operation','fluids.gas.valves_orifices.flow_control_valves.enum.TemperatureValveOperation.Opens');
        elseif strcmp(valve_operation,'fluids.gas.enum.temperature_valve_spec.close')||strcmp(valve_operation,'2')
            out=setValue(out,'valve_operation','fluids.gas.valves_orifices.flow_control_valves.enum.TemperatureValveOperation.Closes');
        end
    end

    iso_cond_spec=getValue(out,'iso_cond_spec');
    if~isempty(iso_cond_spec)

        out=setValue(out,'valve_parameterization','fluids.gas.valves_orifices.enum.OrificeParameterization.SonicConductance');

        if strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.conductance')||strcmp(iso_cond_spec,'1')
            C_max=getValue(out,'C_max');
            C_max_unit=getUnit(out,'C_max');
            C_max_conf=getRTConfig(out,'C_max');

            C_min=getValue(out,'C_min');
            C_min_unit=getUnit(out,'C_min');
            C_min_conf=getRTConfig(out,'C_min');

            out=setValue(out,'B_crit_linear',getValue(out,'B_crit'));
            out=setUnit(out,'B_crit_linear',getUnit(out,'B_crit'));
            out=setRTConfig(out,'B_crit_linear',getRTConfig(out,'B_crit'));


            unit_conv=num2str(value(simscape.Value(1,C_min_unit),C_max_unit));
            out=setValue(out,'leakage_fraction',['(',C_min,')/(',C_max,') * ',unit_conv]);
            if strcmp(C_max_conf,'runtime')||strcmp(C_min_conf,'runtime')
                out=setRTConfig(out,'leakage_fraction','runtime');
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.Cv')||strcmp(iso_cond_spec,'2')
            Cv_max=getValue(out,'Cv_max');
            Cv_max_conf=getRTConfig(out,'Cv_max');

            Cv_min=getValue(out,'Cv_min');
            Cv_min_conf=getRTConfig(out,'Cv_min');


            out=setValue(out,'C_max',['4e-8 * (',Cv_max,')']);
            out=setUnit(out,'C_max','m^3/(s*Pa)');
            out=setRTConfig(out,'C_max',Cv_max_conf);

            out=setValue(out,'B_crit_linear','0.3');

            out=setValue(out,'m','0.5');


            out=setValue(out,'leakage_fraction',['(',Cv_min,')/(',Cv_max,')']);
            if strcmp(Cv_max_conf,'runtime')||strcmp(Cv_min_conf,'runtime')
                out=setRTConfig(out,'leakage_fraction','runtime');
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.Kv')||strcmp(iso_cond_spec,'3')
            Kv_max=getValue(out,'Kv_max');
            Kv_max_conf=getRTConfig(out,'Kv_max');

            Kv_min=getValue(out,'Kv_min');
            Kv_min_conf=getRTConfig(out,'Kv_min');


            out=setValue(out,'C_max',['4.78e-8 * (',Kv_max,')']);
            out=setUnit(out,'C_max','m^3/(s*Pa)');
            out=setRTConfig(out,'C_max',Kv_max_conf);

            out=setValue(out,'B_crit_linear','0.3');

            out=setValue(out,'m','0.5');


            out=setValue(out,'leakage_fraction',['(',Kv_min,')/(',Kv_max,')']);
            if strcmp(Kv_max_conf,'runtime')||strcmp(Kv_min_conf,'runtime')
                out=setRTConfig(out,'leakage_fraction','runtime');
            end

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.iso_cond_spec.area')||strcmp(iso_cond_spec,'4')
            area=getValue(out,'area');
            area_unit=getUnit(out,'area');
            area_conf=getRTConfig(out,'area');

            area_max=getValue(out,'area_max');
            area_max_unit=getUnit(out,'area_max');
            area_max_conf=getRTConfig(out,'area_max');

            area_leak=getValue(out,'area_leak');
            area_leak_unit=getUnit(out,'area_leak');
            area_leak_conf=getRTConfig(out,'area_leak');


            unit_conv=num2str(value(simscape.Value(1,area_max_unit),'mm^2'));
            out=setValue(out,'C_max',['0.128 * (',area_max,') * ',unit_conv,' * 4/pi']);
            out=setUnit(out,'C_max','l/(s*bar)');
            out=setRTConfig(out,'C_max',area_max_conf);

            unit_conv=num2str(value(simscape.Value(1,area_max_unit),area_unit));
            out=setValue(out,'B_crit_linear',['0.41 + 0.272 * ((',area_max,')/(',area,') * ',unit_conv,')^0.25']);
            if strcmp(area_max_conf,'runtime')||strcmp(area_conf,'runtime')
                out=setRTConfig(out,'B_crit_linear','runtime');
            end

            out=setValue(out,'m','0.5');


            unit_conv=num2str(value(simscape.Value(1,area_leak_unit),area_max_unit));
            out=setValue(out,'leakage_fraction',['(',area_leak,')/(',area_max,') * ',unit_conv]);
            if strcmp(area_max_conf,'runtime')||strcmp(area_leak_conf,'runtime')
                out=setRTConfig(out,'leakage_fraction','runtime');
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