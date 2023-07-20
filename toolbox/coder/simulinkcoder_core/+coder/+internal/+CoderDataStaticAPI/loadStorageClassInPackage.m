function retCellArray=loadStorageClassInPackage(sourceDD,package,guiEntry)















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    if nargin==2
        guiEntry=true;
    end

    txn=[];
    try
        dd=hlp.openDD(sourceDD);
        txn=hlp.beginTxn(dd);
        retCellArray={};


        hlp.createSWCT(dd);


        if~slfeature('SupportMultiplePackage')||isempty(package)
            pkgs=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(sourceDD);
            for i=1:length(pkgs)
                coder.internal.CoderDataStaticAPI.removeLegacyPackage(dd,pkgs{i});
            end
        end
        if~hlp.hasSWCT(dd)
            hlp.moveSCToSWCT(dd,hlp.getCoderData(dd,'AbstractStorageClass'));
        end


        if~isempty(package)
            coder.internal.CoderDataStaticAPI.importLegacyPackage(dd,package);
        end
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        if guiEntry
            errordlg(me.message);
        else
            throwAsCaller(me);
        end
    end
end


