function out=transformR2022bGasFlowControlValveParameterization(in)





    out=in;


    valve_seat_spec=getValue(out,'valve_seat_spec');
    if~isempty(valve_seat_spec)
        if strcmp(valve_seat_spec,'fluids.gas.enum.ball_valve_spec.sharp')||strcmp(valve_seat_spec,'1')
            out=setValue(out,'valve_seat_geometry','fluids.gas.valves_orifices.flow_control_valves.enum.ValveSeatGeometry.Sharp');
        elseif strcmp(valve_seat_spec,'fluids.gas.enum.ball_valve_spec.conical')||strcmp(valve_seat_spec,'2')
            out=setValue(out,'valve_seat_geometry','fluids.gas.valves_orifices.flow_control_valves.enum.ValveSeatGeometry.Conical');
        end
    end

    diam_orifice=getValue(out,'diam_orifice');
    diam_orifice_unit=getUnit(out,'diam_orifice');
    diam_orifice_conf=getRTConfig(out,'diam_orifice');

    area_leak=getValue(out,'area_leak');
    area_leak_unit=getUnit(out,'area_leak');
    area_leak_conf=getRTConfig(out,'area_leak');


    area_max=['pi/4 * (',diam_orifice,')^2'];
    area_max_unit=['(',diam_orifice_unit,')^2'];
    area_max_conf=diam_orifice_conf;


    unit_conv=num2str(value(simscape.Value(1,area_leak_unit),area_max_unit));
    out=setValue(out,'leakage_fraction',['(',area_leak,')/(',area_max,') * ',unit_conv]);
    if strcmp(area_max_conf,'runtime')||strcmp(area_leak_conf,'runtime')
        out=setRTConfig(out,'leakage_fraction','runtime');
    end

    iso_cond_spec=getValue(out,'iso_cond_spec');
    if~isempty(iso_cond_spec)

        out=setValue(out,'valve_parameterization','fluids.gas.valves_orifices.flow_control_valves.enum.OrificeParameterization.SonicConductance');

        if strcmp(iso_cond_spec,'fluids.gas.enum.flow_control_valve_spec.conductance')||strcmp(iso_cond_spec,'2')

            out=setValue(out,'B_crit_linear',getValue(out,'B_crit'));
            out=setUnit(out,'B_crit_linear',getUnit(out,'B_crit'));
            out=setRTConfig(out,'B_crit_linear',getRTConfig(out,'B_crit'));

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.flow_control_valve_spec.Cv')||strcmp(iso_cond_spec,'3')

            Cv_max=getValue(out,'Cv_max');
            Cv_max_conf=getRTConfig(out,'Cv_max');


            out=setValue(out,'C_max',['4e-8 * (',Cv_max,')']);
            out=setUnit(out,'C_max','m^3/(s*Pa)');
            out=setRTConfig(out,'C_max',Cv_max_conf);

            out=setValue(out,'B_crit_linear','0.3');

            out=setValue(out,'m','0.5');

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.flow_control_valve_spec.Kv')||strcmp(iso_cond_spec,'4')

            Kv_max=getValue(out,'Kv_max');
            Kv_max_conf=getRTConfig(out,'Kv_max');


            out=setValue(out,'C_max',['4.78e-8 * (',Kv_max,')']);
            out=setUnit(out,'C_max','m^3/(s*Pa)');
            out=setRTConfig(out,'C_max',Kv_max_conf);

            out=setValue(out,'B_crit_linear','0.3');

            out=setValue(out,'m','0.5');

        elseif strcmp(iso_cond_spec,'fluids.gas.enum.flow_control_valve_spec.geometry')||strcmp(iso_cond_spec,'1')

            area=getValue(out,'area');
            area_unit=getUnit(out,'area');
            area_conf=getRTConfig(out,'area');


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
        end
    end


    out=setValue(out,'rho_ref_C',getValue(out,'rho0'));
    out=setUnit(out,'rho_ref_C',getUnit(out,'rho0'));
    out=setRTConfig(out,'rho_ref_C',getRTConfig(out,'rho0'));

    out=setValue(out,'T_ref_C',getValue(out,'T0'));
    out=setUnit(out,'T_ref_C',getUnit(out,'T0'));
    out=setRTConfig(out,'T_ref_C',getRTConfig(out,'T0'));

end