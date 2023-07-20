function out=getPlatformConstraints(dictionary,platform)




    out=[];
    if~strcmp(platform,configset.internal.getApplicationPlatformName)
        out=configset.internal.util.getFunctionPlatformConstraints(dictionary);
    end
