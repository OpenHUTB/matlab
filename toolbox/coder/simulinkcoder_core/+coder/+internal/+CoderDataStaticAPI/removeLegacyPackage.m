function removeLegacyPackage(sourceDD,package)













    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);
    if~strcmp(package,'SimulinkBuiltin')
        pkgs=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(sourceDD);
        if~ismember(package,pkgs)
            MSLDiagnostic('SimulinkCoderApp:core:PackageNotLoadedInCoderDictionary',package).reportAsWarning;
            return;
        end
    end
    txn=[];
    try
        txn=hlp.beginTxn(dd);

        dd.owner.removeReferencedContainer(package);

        legacyCSCs=hlp.getCoderData(dd,'AbstractStorageClass');
        for i=1:length(legacyCSCs)
            currentCS=legacyCSCs(i);
            pkg=hlp.getProp(currentCS,'Package');
            if strcmp(pkg,package)
                hlp.deleteEntry(dd,'AbstractStorageClass',currentCS.Name);
            end
        end
        legacyMSs=hlp.getCoderData(dd,'AbstractMemorySection');
        for i=1:length(legacyMSs)
            currentMS=legacyMSs(i);
            pkg=hlp.getProp(currentMS,'Package');
            if strcmp(pkg,package)
                hlp.deleteEntry(dd,'AbstractMemorySection',currentMS.Name);
            end
        end
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end


        rethrow(me);
    end
end
