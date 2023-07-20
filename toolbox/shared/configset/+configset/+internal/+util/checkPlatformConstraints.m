function checkPlatformConstraints(model)




    cs=getActiveConfigSet(model);
    dictionary=get_param(cs,'EmbeddedCoderDictionary');
    if~isempty(dictionary)
        platform=get_param(cs,'PlatformDefinition');
        constraints=configset.internal.util.getPlatformConstraints(dictionary,platform);
        if~isempty(constraints)
            p=constraints.getIncompatibleParameters(cs);
            if~isempty(p)

                if any(p=="SystemTargetFile")


                    p="SystemTargetFile";
                end

                link=arrayfun(@(x)configset.internal.util.getHyperlink(x),...
                p,'UniformOutput',false);

                throw(MSLException([],message('RTW:configSet:ParametersIncompatibleWithPlatform',...
                model,dictionary,...
                ['<ul>',sprintf('<li>%s</li>',link{:}),'</ul>'])));
            end


            constraints.applyStatus(cs);
        end
    end
