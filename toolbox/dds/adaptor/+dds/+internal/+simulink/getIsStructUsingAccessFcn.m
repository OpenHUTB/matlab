function isStructUsingAccessFcn=getIsStructUsingAccessFcn(modelName)






    vendorKey=dds.internal.simulink.getCurrentVendor(modelName);
    reg=dds.internal.vendor.DDSRegistry;
    ent=reg.getEntryFor(vendorKey);
    isStructUsingAccessFcn=ent.GetIsStructUsingAccessFcn();
end

