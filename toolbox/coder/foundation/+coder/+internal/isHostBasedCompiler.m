function[isHostBasedCompiler,lToolchainAlias]=...
    isHostBasedCompiler(lToolchainInfo)





    lToolchainAlias='';
    isHostBasedCompiler=false;

    if~isempty(lToolchainInfo)
        isHostBasedCompiler=lToolchainInfo.SupportsBuildingMEXFuncs;
        lToolchainAlias=lToolchainInfo.Alias;
    end
end
