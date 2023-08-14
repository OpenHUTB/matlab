function ret=isMemorySectionInstanceSpecific(mdlH,scName)





    ret=false;

    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cdict=hlp.openDD(mdlH);

    scEntry=hlp.findEntry(cdict,'StorageClass',scName);
    if isa(scEntry,'coderdictionary.data.LegacyStorageClass')
        if isequal(hlp.getProp(scEntry,'MemorySection'),...
            '<Instance specific>')
            ret=true;
        end
    end
end
