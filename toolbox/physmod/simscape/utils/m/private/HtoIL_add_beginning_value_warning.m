function message_cell=HtoIL_add_beginning_value_warning(message_cell,var_list,var_friendly_names)










    num_variables=length(var_list);
    params_for_str={};
    num_variable_warnings=0;

    for i=1:num_variables
        if(strcmp(var_list(i).specify,'off')&&~strcmp(var_list(i).unspecified_priority,'None'))||...
            (strcmp(var_list(i).specify,'on')&&~strcmp(var_list(i).priority,'None'))

            params_for_str{end+1}=var_friendly_names{i};%#ok<AGROW>
            num_variable_warnings=num_variable_warnings+1;

        end
    end

    if num_variable_warnings>0

        if num_variable_warnings==1
            warning_str=['Beginning value of ',params_for_str{1},' removed.'];
        elseif num_variable_warnings==2
            warning_str=['Beginning values of ',params_for_str{1},' and ',params_for_str{2},' removed.'];
        elseif num_variable_warnings==3
            warning_str=['Beginning values of ',params_for_str{1},', ',params_for_str{2},', and ',params_for_str{3},' removed.'];
        else
            warning_str=['Beginning values of ',params_for_str{1},', ',params_for_str{2},', ',params_for_str{3},', and ',params_for_str{4},' removed.'];
        end

        warning_str=[warning_str,' Adjustment of model initial conditions may be required.'];

        message_cell{end+1,1}=warning_str;

    end

end