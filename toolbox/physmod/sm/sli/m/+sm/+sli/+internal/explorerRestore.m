function str=explorerRestore(model)




    str='';
    if~isempty(model)&&bdIsLoaded(model)
        param=pm_message('mech2:sli:explorer:explorerSettings:ParamName');
        str=get_param(model,param);
    end

end
