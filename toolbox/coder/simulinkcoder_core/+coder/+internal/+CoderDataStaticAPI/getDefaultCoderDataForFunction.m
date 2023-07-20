function out=getDefaultCoderDataForFunction(dd,functionType,coderDataType)















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    out='';
    isMemorySection=strcmp(coderDataType,'MemorySection');
    isFunctionClass=strcmp(coderDataType,'FunctionClass');
    if~isFunctionClass&&~isMemorySection
        DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',coderDataType,modelElementType);
    end
    dd=hlp.openDD(dd);
    if isMemorySection
        prop='InitialMemorySection';
    elseif isFunctionClass
        prop='InitialFunctionClass';
    end
    if hlp.hasSWCT(dd)
        swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
        cat=hlp.getProp(swc,functionType);
        if~isempty(cat)
            out=hlp.getProp(cat,prop);
        end
        if~isempty(out)
            out=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeForContainer(dd.owner,coderDataType,out.Name);
        end
    end
end


