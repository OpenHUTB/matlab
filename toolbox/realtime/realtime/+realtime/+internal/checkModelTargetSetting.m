function checkModelTargetSetting(modelName)




    target=get_param(modelName,'TargetExtensionPlatform');
    registeredTargets=realtime.getRegisteredTargets;
    if isempty(registeredTargets)
        error(message('realtime:build:MissingTargetError',target,target));
    end
    if~ismember(target,registeredTargets)
        if isequal(target,'None')
            error(message('realtime:build:TargetSetNoneError'));
        else
            error(message('realtime:build:MissingTargetError',target,target));
        end
    end