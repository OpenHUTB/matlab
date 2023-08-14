function createExampleStorageClassesForSI(ddConnection)












    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    if~isa(ddConnection,'coderdictionary.softwareplatform.FunctionPlatform')
        cdict=hlp.openDD(ddConnection);
    else
        cdict=ddConnection;
    end
    txn=hlp.beginTxn(cdict);
    try



        cgEntrySig=hlp.createEntry(cdict,'StorageClass','MeasurementStruct');
        hlp.setProp(cgEntrySig,'Description',['A multi-instance storage class for measurements.',...
        'This is an example storage class. Please modify',...
        ' this storage class or a copy of it to suit your',...
        ' application needs.']);
        hlp.setProp(cgEntrySig,'StorageType','Structured');
        hlp.setProp(cgEntrySig,'DataInit','Dynamic');


        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','TypeNamingRule','$R$N_Measurements_T$M');
        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','InstanceNamingRule','$N_Measurements$M');
        hlp.setComponentInstanceProp(cgEntrySig,'SingleInstance','Placement','Standalone');


        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','TypeNamingRule','$R$N_Measurements_T$M');
        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','InstanceNamingRule','$N_Measurements$M');
        hlp.setComponentInstanceProp(cgEntrySig,'MultiInstance','Placement','InParent');
        cgEntrySig.HeaderFile='$R_Measurements.h';
        cgEntrySig.DefinitionFile='$R_Measurements.c';


        cgEntryParam=hlp.createEntry(cdict,'StorageClass','ParamStruct');
        hlp.setProp(cgEntryParam,'Description',['A multi-instance storage class for parameter and parameter argument tuning services.',...
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
        cgEntryParam.HeaderFile='$R_Params.h';
        cgEntryParam.DefinitionFile='$R_Params.c';

        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end
end


