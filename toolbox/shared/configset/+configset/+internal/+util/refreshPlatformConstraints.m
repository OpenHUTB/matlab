function refreshPlatformConstraints(model)











    cs=getActiveConfigSet(model);
    dictionary=get_param(cs,'EmbeddedCoderDictionary');
    if~isempty(dictionary)
        platform=get_param(cs,'PlatformDefinition');
        constraints=configset.internal.util.getPlatformConstraints(dictionary,platform);
        if~isempty(constraints)
            constraints.fix(cs);
        end
    end
