function out=getPlatformDescription(cs)




    out='';


    dictionary=get_param(cs,'EmbeddedCoderDictionary');
    if~isempty(dictionary)
        platform=get_param(cs,'PlatformDefinition');
        if~strcmp(platform,configset.internal.getApplicationPlatformName)
            helper=coder.internal.CoderDataStaticAPI.getHelper();
            try
                info=helper.getSoftwarePlatform(dictionary,platform);
            catch
                info=[];
            end
            if~isempty(info)
                out=info.Description;
            end
        end
    end


    if isempty(out)
        out=getProp(cs.getComponent('Code Generation'),'Description');
    end
