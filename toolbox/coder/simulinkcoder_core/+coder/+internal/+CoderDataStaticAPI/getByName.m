function[out,ref]=getByName(sourceDD,coderDataType,name)






















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    dd=hlp.openDD(sourceDD);
    [out,ref]=hlp.findEntry(dd,coderDataType,name);
end


