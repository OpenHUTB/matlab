function HtoIL_apply_vars(block,var_list,collected_vars)








    for i=length(var_list):-1:1
        set_param(block,var_list{i},collected_vars(i).base);
        set_param(block,[var_list{i},'_unit'],collected_vars(i).unit);
        set_param(block,[var_list{i},'_specify'],collected_vars(i).specify);
        set_param(block,[var_list{i},'_priority'],collected_vars(i).priority);
        set_param(block,[var_list{i},'_nominal_specify'],collected_vars(i).nominal_specify);
        set_param(block,[var_list{i},'_nominal_unit'],collected_vars(i).nominal_unit);
        set_param(block,[var_list{i},'_nominal_value'],collected_vars(i).nominal_value);
    end

end