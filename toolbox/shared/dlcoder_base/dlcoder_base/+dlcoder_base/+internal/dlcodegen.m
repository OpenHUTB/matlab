function dlcodegen(net,dlcodegenConfig)















































































    try
        dlcodegenConfig.validateAndSetBuildConfig;
        dltargets.internal.cnncodegenpriv(net,dlcodegenConfig,true);
    catch err
        throwAsCaller(err)
    end


end



