function out=getPlatformCustomization(cs)









    out='';

    dictionary=get_param(cs,'EmbeddedCoderDictionary');
    platform=get_param(cs,'PlatformDefinition');
    constraints=configset.internal.util.getPlatformConstraints(dictionary,platform);
    if~isempty(constraints)
        out=constraints.getDialogCustomization(cs);
    end


