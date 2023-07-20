function out=transformGearInertiasR2020a_private(in)





    out=in;










    carrier_inertia=getValue(in,'carrier_inertia');
    if~isempty(carrier_inertia)
        carrier_inertia_value=str2double(carrier_inertia);
        planet_inertia=getValue(in,'planet_inertia');
        planet_inertia_value=str2double(planet_inertia);
        if~isnan(carrier_inertia_value)&&~isnan(planet_inertia_value)...
            &&carrier_inertia_value==0&&planet_inertia_value==0
            out=setValue(out,'model_inertia','0');
            out=setValue(out,'carrier_inertia','0.001');
            out=setValue(out,'carrier_inertia_unit','kg*m^2');
            out=setValue(out,'planet_inertia','0.001');
            out=setValue(out,'planet_inertia_unit','kg*m^2');
        else
            out=setValue(out,'model_inertia','1');
        end
    else
        planet_inertia=getValue(in,'planet_inertia');
        if~isempty(planet_inertia)
            planet_inertia_value=str2double(planet_inertia);
            if~isnan(planet_inertia_value)&&planet_inertia_value==0
                out=setValue(out,'model_inertia','0');
                out=setValue(out,'planet_inertia','0.001');
                out=setValue(out,'planet_inertia_unit','kg*m^2');
            else
                out=setValue(out,'model_inertia','1');
            end
        end
    end

    inner_planet_inertia=getValue(in,'inner_planet_inertia');
    if~isempty(inner_planet_inertia)
        inner_planet_inertia_value=str2double(inner_planet_inertia);
        outer_planet_inertia=getValue(in,'outer_planet_inertia');
        outer_planet_inertia_value=str2double(outer_planet_inertia);
        if~isnan(inner_planet_inertia_value)&&~isnan(outer_planet_inertia_value)...
            &&inner_planet_inertia_value==0&&outer_planet_inertia_value==0
            out=setValue(out,'model_inertia','0');
            out=setValue(out,'inner_planet_inertia','0.001');
            out=setValue(out,'inner_planet_inertia_unit','kg*m^2');
            out=setValue(out,'outer_planet_inertia','0.001');
            out=setValue(out,'outer_planet_inertia_unit','kg*m^2');
        else
            out=setValue(out,'model_inertia','1');
        end
    end

end