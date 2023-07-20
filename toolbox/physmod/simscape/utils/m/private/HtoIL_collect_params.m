function collected_params=HtoIL_collect_params(block,param_list)








    for i=length(param_list):-1:1
        try
            collected_params(i).name=param_list{i};
            collected_params(i).base=get_param(block,param_list{i});
            collected_params(i).unit=get_param(block,[param_list{i},'_unit']);
            collected_params(i).conf=get_param(block,[param_list{i},'_conf']);

        catch
        end
    end


end