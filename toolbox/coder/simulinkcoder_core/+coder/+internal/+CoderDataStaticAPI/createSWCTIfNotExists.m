function hasSWC=createSWCTIfNotExists(sourceDD)






    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
    hasSWC=isempty(swc);
end
