function configSubsystemBuild(block)











    if nargin>0
        block=convertStringsToChars(block);
    end

    errMsg=coder.internal.configFcnProtoSSBuild(block,[],'Create');
    if~isempty(errMsg)
        error('RTW:fcnClass:ssConfigureFailed',errMsg);
    end


