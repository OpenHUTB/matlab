function hasPlatformDef=hasPlatformDefinition(sourceDD)










    hasPlatformDef=false;
    if coder.dictionary.exist(sourceDD)
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        dd=hlp.openDD(sourceDD);
        hasPlatformDef=dd.owner.SoftwarePlatforms.Size>0;
    end
