function out=transformR2021bTLPressureControlSpec(in)




    out=in;

    pressure_spec=getValue(out,'pressure_spec');
    if~isempty(pressure_spec)
        if strcmp(pressure_spec,'2')
            pressure_spec='fluids.thermal_liquid.valves.enum.PressureControlSpec.PressureDifferential';
        elseif strcmp(pressure_spec,'1')
            pressure_spec='fluids.thermal_liquid.valves.enum.PressureControlSpec.PressureA';
        end
        out=setValue(out,'pressure_spec',pressure_spec);
    end

end