function collected_vars=HtoIL_collect_vars(block,var_list,RefBlock)






    reference_block_handle=getSimulinkBlockHandle(RefBlock,true);

    for i=length(var_list):-1:1
        collected_vars(i).name=var_list{i};
        collected_vars(i).base=get_param(block,var_list{i});
        collected_vars(i).unit=get_param(block,[var_list{i},'_unit']);
        collected_vars(i).specify=get_param(block,[var_list{i},'_specify']);
        collected_vars(i).priority=get_param(block,[var_list{i},'_priority']);
        collected_vars(i).unspecified_priority=get_param(reference_block_handle,[var_list{i},'_priority']);
        collected_vars(i).nominal_specify=get_param(block,[var_list{i},'_nominal_specify']);
        collected_vars(i).nominal_unit=get_param(block,[var_list{i},'_nominal_unit']);
        collected_vars(i).nominal_value=get_param(block,[var_list{i},'_nominal_value']);
    end

end