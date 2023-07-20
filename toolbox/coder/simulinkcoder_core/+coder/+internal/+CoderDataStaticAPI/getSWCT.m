function swc=getSWCT(sourceDD)









    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);

    if~hlp.hasSWCT(dd)
        Utils.createSWCTOnly(dd);
    end
    swcs=hlp.getCoderData(dd,'SoftwareComponentTemplate');
    swc=swcs(1);
end
