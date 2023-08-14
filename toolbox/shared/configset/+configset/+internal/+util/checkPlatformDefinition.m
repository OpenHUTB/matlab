function checkPlatformDefinition(model)




    cs=getActiveConfigSet(model);
    dictionary=get_param(cs,'EmbeddedCoderDictionary');
    if~isempty(dictionary)
        h=get_param(model,'Handle');
        if~exist(dictionary,'file')
            throw(MSLException(h,message('RTW:buildProcess:ExternalCoderDictionaryNotFound',...
            model,dictionary)));
        end
        platform=get_param(cs,'PlatformDefinition');
        helper=coder.internal.CoderDataStaticAPI.getHelper();
        info=helper.getSoftwarePlatform(dictionary,platform);
        if isempty(info)
            throw(MSLException(h,message('RTW:buildProcess:PlatformDefinitionNotFound',...
            model,dictionary)));
        end
    end


