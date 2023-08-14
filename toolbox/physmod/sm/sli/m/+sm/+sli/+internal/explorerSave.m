function str=explorerSave(model,str)




    if~isempty(model)&&bdIsLoaded(model)
        param=pm_message('mech2:sli:explorer:explorerSettings:ParamName');
        set_param(model,param,str);
    end

end
