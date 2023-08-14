function out=getAllowableMemorySectionForElementAndStorageClass(sourceDD,modelElementType,storageClass)

















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    dd=hlp.openDD(sourceDD);
    allowedMemorySections=getAllowableMemorySections(dd,modelElementType);


    if strcmp(storageClass,message('SimulinkCoderApp:core:CoderDataSimulinkModelDefaultEntryName').getString)||isempty(storageClass)
        out=allowedMemorySections;
        return;
    end
    currentStorageClass=coder.internal.CoderDataStaticAPI.getByName(dd,'StorageClass',storageClass);
    if~isempty(currentStorageClass)
        storageClassMemorySection='';
        if isa(currentStorageClass,'coderdictionary.data.StorageClass')

            storageClassMemorySection=hlp.getProp(currentStorageClass,'MemorySection');
        end
        if~isempty(storageClassMemorySection)&&isa(storageClassMemorySection,'mf.zero.ModelElement')
            storageClassMemorySection=storageClassMemorySection.Name;
        end



        if strcmpi(storageClassMemorySection,'Instance Specific')||isempty(storageClassMemorySection)||...
            strcmp(storageClassMemorySection,message('coderdictionary:mapping:MappingNone').getString)
            out=allowedMemorySections;
        elseif strcmpi(storageClassMemorySection,'default')


            out=coderdictionary.data.MemorySection.empty;
        else


            out=coder.internal.CoderDataStaticAPI.getByName(dd,'MemorySection',storageClassMemorySection);
        end
    else



        out=allowedMemorySections;
    end
end

function out=getAllowableMemorySections(dd,modelElementType)
    refs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(dd.owner,modelElementType,'MemorySection','ModelLevel');
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    out=hlp.getEntriesFromReferences(refs);
end


