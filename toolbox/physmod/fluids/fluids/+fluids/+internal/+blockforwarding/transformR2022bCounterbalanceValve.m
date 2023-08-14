function out=transformR2022bCounterbalanceValve(in)




    out=in;






    opening_spec=double(eval(getValue(out,'opening_spec')));
    if~isempty(opening_spec)
        if opening_spec==2


            check_p_crack_value=stripComments(getValue(out,'check_p_crack'));
            check_p_crack_unit=getUnit(out,'check_p_crack');
            check_p_crack_config=getRTConfig(out,'check_p_crack');

            check_p_max_value=stripComments(getValue(out,'check_p_max'));
            check_p_max_unit=getUnit(out,'check_p_max');
            check_p_max_config=getRTConfig(out,'check_p_max');
            check_p_max_value_converted=convertUnits(check_p_max_value,check_p_max_unit,check_p_crack_unit);

            check_p_diff_TLU_value=['[',check_p_crack_value,', ',check_p_max_value_converted,']'];
            check_p_diff_TLU_config=getExprConf({check_p_crack_config,check_p_max_config});

            out=setValue(out,'check_p_diff_TLU',check_p_diff_TLU_value);
            out=setUnit(out,'check_p_diff_TLU',check_p_crack_unit);
            out=setRTConfig(out,'check_p_diff_TLU',check_p_diff_TLU_config);


            check_area_max_value=stripComments(getValue(out,'check_area_max'));
            check_area_max_unit=getUnit(out,'check_area_max');
            check_area_max_config=getRTConfig(out,'check_area_max');

            valve_area_TLU_value=stripComments(getValue(out,'valve_area_TLU'));
            valve_area_TLU_first_value=getVectorFirstLastElement(valve_area_TLU_value,'first');
            valve_area_TLU_unit=getUnit(out,'valve_area_TLU');
            valve_area_TLU_config=getRTConfig(out,'valve_area_TLU');
            valve_area_TLU_first_value_converted=convertUnits(valve_area_TLU_first_value,valve_area_TLU_unit,check_area_max_unit);

            check_area_TLU_value=['[',valve_area_TLU_first_value_converted,', ',check_area_max_value,']'];
            check_area_TLU_config=getExprConf({valve_area_TLU_config,check_area_max_config});

            out=setValue(out,'check_area_TLU',check_area_TLU_value);
            out=setUnit(out,'check_area_TLU',check_area_max_unit);
            out=setRTConfig(out,'check_area_TLU',check_area_TLU_config);

        end
    end


end


function conf=getExprConf(s2)



    if all(strcmp('runtime',s2))
        conf='runtime';
    else
        conf='compiletime';
    end

end