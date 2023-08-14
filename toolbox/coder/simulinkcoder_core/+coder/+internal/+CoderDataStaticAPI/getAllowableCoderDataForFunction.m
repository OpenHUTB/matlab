


function out=getAllowableCoderDataForFunction(sourceDD,~,coderDataType)













    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    out={};
    dd=hlp.openDD(sourceDD);
    switch coderDataType
    case 'FunctionClass'
        out=coder.internal.CoderDataStaticAPI.get(dd,coderDataType);
    case 'MemorySection'
        out=coder.internal.CoderDataStaticAPI.get(dd,coderDataType);
    end
end


