function HtoIL_apply_params(block,param_list,collected_params)








    for i=1:length(param_list)
        if~isempty(param_list{i})
            set_param(block,param_list{i},collected_params(i).base);
            set_param(block,[param_list{i},'_unit'],collected_params(i).unit);
            try


                set_param(block,[param_list{i},'_conf'],collected_params(i).conf);
            catch
            end
        end
    end

end