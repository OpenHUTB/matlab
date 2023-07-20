function out=getDefaultCoderDataForElement(dd,modelElementType,coderDataType)
















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    modelElementType=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(modelElementType);
    out='';
    isStorageClass=strcmp(coderDataType,'StorageClass');
    isMemorySection=strcmp(coderDataType,'MemorySection');
    if isStorageClass||isMemorySection
        dd=hlp.openDD(dd);
        if hlp.hasSWCT(dd)
            swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
            cat=hlp.getProp(swc,modelElementType);
            if isStorageClass
                out=hlp.getProp(cat,'InitialStorageClass');
            elseif isMemorySection
                out=hlp.getProp(cat,'InitialMemorySection');
            elseif isFunctionClass
                out=hlp.getProp(cat,'InitialFunctionClass');
            end
        end
    else
        DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',coderDataType,modelElementType);
    end
    if~isempty(out)
        out=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeForContainer(dd.owner,coderDataType,out.Name);
    end
end


