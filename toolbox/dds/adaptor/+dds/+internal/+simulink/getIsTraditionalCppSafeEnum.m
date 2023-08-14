function isTraditionalCppSafeEnum=getIsTraditionalCppSafeEnum(modelName)






    vendorKey=dds.internal.simulink.getCurrentVendor(modelName);
    reg=dds.internal.vendor.DDSRegistry;
    ent=reg.getEntryFor(vendorKey);
    isTraditionalCppSafeEnum=ent.GetIsTraditionalCppSafeEnum();
end

