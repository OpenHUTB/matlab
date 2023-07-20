function createBuiltinStorageClasses(ddConnection)












    import coder.internal.CoderDataStaticAPI.*;
    if slfeature('AutoDataInitForCoderDataGroup')<2
        return;
    end
    hlp=getHelper();

    cdict=hlp.openDD(ddConnection);
    txn=hlp.beginTxn(cdict);
    try



        multiInstance=hlp.createEntry(cdict,'StorageClass','MultiInstance');
        hlp.setProp(multiInstance,'Description',['Generate a variable for single-instance data or '...
        ,'generate a hierarchical structure for multi-instance data']);
        hlp.setProp(multiInstance,'StorageType','Mixed');
        hlp.setProp(multiInstance,'DataInit','Auto');
        hlp.setProp(multiInstance,'SingleInstanceStorageType','Unstructured');


        hlp.setComponentInstanceProp(multiInstance,'MultiInstance','TypeNamingRule','$R$N_T$M');
        hlp.setComponentInstanceProp(multiInstance,'MultiInstance','InstanceNamingRule','$N$M');
        hlp.setComponentInstanceProp(multiInstance,'MultiInstance','Placement','InParent');
        hlp.setProp(multiInstance,'isBuiltin',true);

        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end
end
