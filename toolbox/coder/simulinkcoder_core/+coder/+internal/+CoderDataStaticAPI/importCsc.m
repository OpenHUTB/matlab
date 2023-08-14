function importCsc(sourceDD,package,classes)










    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);

    if isempty(classes)
        cscs=processcsc('GetCSCDefns',package);
        for ii=1:numel(cscs)
            csc=cscs(ii);
            transactionify(dd,@()coder.internal.CoderDataStaticAPI.importStorageClass(dd,package,csc));
        end
    else
        if~iscell(classes)
            classes={classes};
        end
        for ii=1:numel(classes)
            csc=processcsc('GetCSCDefn',package,classes{ii});
            transactionify(dd,@()coder.internal.CoderDataStaticAPI.importStorageClass(dd,package,csc));
        end
    end
end
