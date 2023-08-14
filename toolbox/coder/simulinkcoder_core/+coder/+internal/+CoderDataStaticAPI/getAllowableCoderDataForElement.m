function out=getAllowableCoderDataForElement(sourceDD,modelElementType,coderDataType)


















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    out='';
    dd=hlp.openDD(sourceDD);
    isStorageClass=strcmp(coderDataType,'StorageClass');
    isMemorySection=strcmp(coderDataType,'MemorySection');
    if isStorageClass||isMemorySection
        if hlp.hasSWCT(dd)
            swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
            cat=hlp.getProp(swc,modelElementType);
            if~isempty(cat)
                if isStorageClass
                    out=hlp.getProp(cat,'CalculatedAllowableStorageClassesForModelLevel');
                elseif isMemorySection

                    initialStorageClass=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(dd,modelElementType,'StorageClass');
                    initialStorageClassName='';
                    if~isempty(initialStorageClass)
                        initialStorageClassName=initialStorageClass.getProperty('Name');
                    end
                    out=coder.internal.CoderDataStaticAPI.getAllowableMemorySectionForElementAndStorageClass(dd,modelElementType,initialStorageClassName);
                end
            end
        else
            out=coder.internal.CoderDataStaticAPI.get(dd,coderDataType);
        end
    end
end


