function collected_IC_vars=HtoIL_parameters_to_variables(collected_IC_params)







    for i=length(collected_IC_params):-1:1
        collected_IC_vars(i).base=collected_IC_params(i).base;
        collected_IC_vars(i).unit=collected_IC_params(i).unit;
        collected_IC_vars(i).specify='on';
        collected_IC_vars(i).priority='High';
        collected_IC_vars(i).nominal_specify='off';
        collected_IC_vars(i).nominal_unit=collected_IC_params(i).unit;
        collected_IC_vars(i).nominal_value=collected_IC_params(i).base;
    end

end