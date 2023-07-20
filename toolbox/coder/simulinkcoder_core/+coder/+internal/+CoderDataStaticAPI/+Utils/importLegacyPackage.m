function cdict=importLegacyPackage(package,m)





    import coder.internal.CoderDataStaticAPI.*;
    x=processcsc('GetAllDefns',package);

    cdict=Utils.createEmptyCoderDict(m);


    legacyMSs=x{2};
    if~isempty(legacyMSs)
        coder.internal.CoderDataStaticAPI.importLegacyMS(cdict,package);
    end


    coder.internal.CoderDataStaticAPI.importCsc(cdict,package,{});
end


