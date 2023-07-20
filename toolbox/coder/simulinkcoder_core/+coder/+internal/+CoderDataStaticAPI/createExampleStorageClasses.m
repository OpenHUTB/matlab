function createExampleStorageClasses(ddConnection)












    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    if~isa(ddConnection,'coderdictionary.softwareplatform.FunctionPlatform')
        cdict=hlp.openDD(ddConnection);
    else
        cdict=ddConnection;
    end
    txn=hlp.beginTxn(cdict);
    try



        cgEntrySig=hlp.createEntry(cdict,'StorageClass','SignalStruct');
        hlp.setProp(cgEntrySig,'Description',['A multi-instance storage class for signals.',...
        'This is an example storage class. Please modify',...
        ' this storage class or a copy of it to suit your',...
        ' application needs.']);
        hlp.setProp(cgEntrySig,'StorageType','Structured');
        hlp.setProp(cgEntrySig,'DataInit','Dynamic');


        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','TypeNamingRule','$R$N_Signals_T$M');
        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','InstanceNamingRule','$N_Signals$M');
        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','Placement','Standalone');


        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','TypeNamingRule','$R$N_Signals_T$M');
        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','InstanceNamingRule','$N_Signals$M');
        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','Placement','InParent');


        cgEntryParam=hlp.createEntry(cdict,'StorageClass','ParamStruct');
        hlp.setProp(cgEntryParam,'Description',['A multi-instance storage class for parameters.',...
        'This is an example storage class. Please modify',...
        ' this storage class or a copy of it to suit your',...
        ' application needs.']);
        hlp.setProp(cgEntryParam,'StorageType','Structured');
        hlp.setProp(cgEntryParam,'DataInit','Static');


        hlp.setComponentInstanceProp(cgEntryParam,'SingleInstance','TypeNamingRule','$R$N_Params_T$M');
        hlp.setComponentInstanceProp(cgEntryParam,'SingleInstance','InstanceNamingRule','$N_Params$M');
        hlp.setComponentInstanceProp(cgEntryParam,'SingleInstance','Placement','Standalone');


        hlp.setComponentInstanceProp(cgEntryParam,'MultiInstance','TypeNamingRule','$R$N_Params_T$M');
        hlp.setComponentInstanceProp(cgEntryParam,'MultiInstance','InstanceNamingRule','$N_Params$M');
        hlp.setComponentInstanceProp(cgEntryParam,'MultiInstance','Placement','InParent');
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end
end


