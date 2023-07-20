function out=transformR2022bValveSetPressure(in)






    out=in;
    blk=string(getClass(out));


    if strcmp(blk,'fluids.isothermal_liquid.valves_orifices.pressure_control_valves.pressure_compensator_valve')

        set_pressure_spec=double(eval(getValue(out,'set_pressure_spec')));
        valve_spec=double(eval(getValue(out,'valve_spec')));
        opening_spec=double(eval(getValue(out,'opening_spec')));


        if set_pressure_spec==1&&opening_spec==2


            if valve_spec==1

                p_diff_reducing_TLU_value=stripComments(getValue(out,'p_diff_reducing_TLU'));
                set_pressure_value=getVectorFirstLastElement(p_diff_reducing_TLU_value,'first');

                out=setValue(out,'p_set_differential',set_pressure_value);
                out=setUnit(out,'p_set_differential',getUnit(out,'p_diff_reducing_TLU'));
                out=setRTConfig(out,'p_set_differential',getRTConfig(out,'p_diff_reducing_TLU'));

            else

                p_diff_relief_TLU_value=stripComments(getValue(out,'p_diff_relief_TLU'));
                set_pressure_value=getVectorFirstLastElement(p_diff_relief_TLU_value,'first');

                out=setValue(out,'p_set_differential',set_pressure_value);
                out=setUnit(out,'p_set_differential',getUnit(out,'p_diff_relief_TLU'));
                out=setRTConfig(out,'p_set_differential',getRTConfig(out,'p_diff_relief_TLU'));
            end

        else

            out=setValue(out,'opening_spec','fluids.isothermal_liquid.valves_orifices.enum.opening_spec.linear');
        end

    end



    if strcmp(blk,'fluids.isothermal_liquid.valves_orifices.pressure_control_valves.pressure_reducing_valve')

        set_pressure_spec=double(eval(getValue(out,'set_pressure_spec')));
        opening_spec=double(eval(getValue(out,'opening_spec')));


        if set_pressure_spec==1&&opening_spec==2



            p_diff_TLU_value=stripComments(getValue(out,'p_diff_TLU'));
            set_pressure_value=getVectorFirstLastElement(p_diff_TLU_value,'first');

            out=setValue(out,'p_set_gauge',set_pressure_value);
            out=setUnit(out,'p_set_gauge',getUnit(out,'p_diff_TLU'));
            out=setRTConfig(out,'p_set_gauge',getRTConfig(out,'p_diff_TLU'));

        else

            out=setValue(out,'opening_spec','fluids.isothermal_liquid.valves_orifices.enum.opening_spec.linear');
        end

    end


end
