function importLegacyPackage(sourceDD,package)














    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);



    if~coder.internal.CoderDataStaticAPI.isInitialized(dd)
        coder.internal.CoderDataStaticAPI.initializeDictionary(dd);
    end

    txn=[];
    try
        txn=hlp.beginTxn(dd);
        cm=CacheManager;
        cm.loadPackage(package,dd);
        chksumStruct=processcsc('GetCSCChecksums',package);
        chksum=chksumStruct.Checksum;
        chksumSrc=chksumStruct.ChecksumSource;
        [~,fName,fExt]=fileparts(chksumSrc.(package));
        dd.addLegacyPackageChecksum(package,chksum.(package),[fName,fExt]);
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end


        rethrow(me);
    end

end


