function out=getPlatformType(mdl)




    out=0;
    type=coder.dictionary.internal.getPlatformType(mdl);
    if strcmp(type,'FunctionPlatform')
        out=1;
    end

