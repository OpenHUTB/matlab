function presetPlatformDefinition(cc,platform)








    cs=cc.getConfigSet;
    dictionary=get_param(cc,'EmbeddedCoderDictionary');
    constraints=configset.internal.util.getPlatformConstraints(dictionary,platform);
    if isempty(constraints)

        configset.internal.Constraints.reset(cs);
    else
        if isempty(dictionary)
            error(message('configset:diagnostics:EmbeddedCoderDictionaryNotSet'));
        end
        helper=coder.internal.CoderDataStaticAPI.getHelper();

        info=helper.getSoftwarePlatform(dictionary,platform);
        if isempty(info)
            error(message('configset:diagnostics:PlatformDefinitionNotFound',...
            dictionary));
        end

        configset.internal.Constraints.reset(cs);
        constraints.apply(cs,'PlatformDefinition',platform);
    end


