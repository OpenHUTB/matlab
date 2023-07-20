function param_set(block,componentPath,oldParam,setParam)









    system=get_param(block,'Parent');


    component=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','On','ComponentPath',componentPath);

    for ii=1:numel(component)
        param=get_param(component(ii),oldParam);
        set_param(component(ii),setParam,param);
    end

end