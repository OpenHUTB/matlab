
function setAllowableStorageClassesForElement(sourceDD,modelElementType,storageClasses)
















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    dd=hlp.openDD(sourceDD);
    if hlp.hasSWCT(dd)
        swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);


        hlp.checkForLegacyCSCs(storageClasses);
        cat=hlp.getProp(swc,modelElementType);
        if~isempty(cat)
            hlp.setProp(cat,'AllowableStorageClasses',storageClasses);
        end
    else
        hlp.moveSCToSWCT(dd,hlp.getCoderData(dd,'AbstractStorageClass'));
        swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
        cat=hlp.getProp(swc,modelElementType);
        if~isempty(cat)
            hlp.setProp(cat,'AllowableStorageClasses',storageClasses);
        end
    end
end
