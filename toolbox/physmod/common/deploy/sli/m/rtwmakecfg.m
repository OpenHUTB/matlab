function makeInfo=rtwmakecfg()





    import physmod.deploy.internal.*;

    requiredLibraries=getAndClearRequiredLibraries(bdroot);
    requiredLibraries=transitiveClosure(requiredLibraries,metadataDirectory);
    requiredLibraries=requiredLibraries(end:-1:1);
    makeInfo=constructMakeConfiguration(requiredLibraries);

end
