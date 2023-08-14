function out=getStorageClassInstanceSpecificProperties(sourceDD,scName)
    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    sc=coder.internal.CoderDataStaticAPI.getByName(sourceDD,'StorageClass',scName);
    out='';
    if~isempty(sc)
        scSchema=hlp.getProp(sc,'CSCAttributesSchema');
        if~isempty(scSchema)
            out=jsondecode(scSchema);
        end
    end
end
