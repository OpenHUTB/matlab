function result=eval_with_resolution(str,parameterName,model,buildData)





    if~Simulink.isRaccelDeployed
        [result,success]=slResolve(str,model);
    else
        [result,success]=eval_string_with_workspace_resolution(...
        str,model,buildData);
    end
    if~success
        DAStudio.error(...
        'Simulink:ConfigSet:ConfigSetEvalErr',...
        str,...
        parameterName,...
        model);
    end
end


