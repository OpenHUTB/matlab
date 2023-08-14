function fcnName=getSlFunctionDisplayName(block)





    if autosar.validation.ExportFcnValidator.isPortScopedSimulinkFunction(block)
        trigPort=find_system(block,'SearchDepth',1,...
        'FollowLinks','on','BlockType','TriggerPort');
        scopeName=get_param(trigPort,'ScopeName');
        unqualifiedFcnName=get_param(trigPort,'FunctionName');
        fcnName=[scopeName{:},'.',unqualifiedFcnName{:}];
    else
        fcnName=autosar.ui.utils.getSlFunctionName(block);
    end

end
