function r=isRLS(ownerHandle)




    r=strcmp(get_param(ownerHandle,'BlockType'),'SubSystem')&&...
    bdIsLibrary(bdroot(ownerHandle))&&...
    (strcmp(get_param(ownerHandle,'TreatAsAtomicUnit'),'on')&&...
    strcmp(get_param(ownerHandle,'RTWSystemCode'),'Reusable function'));
end

