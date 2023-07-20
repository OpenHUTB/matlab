function out=isInitialized(sourceDD)
    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);
    out=hlp.hasSWCT(dd)||hlp.hasFunctionClass(dd);
end