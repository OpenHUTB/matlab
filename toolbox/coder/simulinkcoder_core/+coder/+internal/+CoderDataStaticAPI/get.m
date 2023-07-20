function ret=get(sourceDD,type)














    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    dd=hlp.openDD(sourceDD);
    ret=hlp.getCoderData(dd,type);
end
