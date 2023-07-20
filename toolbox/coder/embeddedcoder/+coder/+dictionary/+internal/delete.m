function delete(coderDict,type,names)







    for j=1:length(names)
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        currentDict=hlp.openDD(coderDict);
        entry=hlp.findEntry(currentDict,type,names{j});
        if~isempty(entry)
            if isa(entry,'coderdictionary.data.LegacyStorageClass')||...
                isa(entry,'coderdictionary.data.LegacyMemorySection')||...
                (isa(entry,'coderdictionary.data.StorageClass')&&entry.owner.owner.isShippingDictionary)
                DAStudio.error('SimulinkCoderApp:data:CannotDeleteLegacyCoderData');
            end
        end
    end


    coder.internal.CoderDataStaticAPI.delete(coderDict,type,names);


end


