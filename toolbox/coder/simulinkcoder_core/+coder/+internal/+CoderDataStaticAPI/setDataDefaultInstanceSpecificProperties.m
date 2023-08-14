


function setDataDefaultInstanceSpecificProperties(sourceDD,modelElementType,instSp)
    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    modelElementType=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(modelElementType);

    dd=hlp.openDD(sourceDD);
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
    dataConfig=hlp.getProp(swc,modelElementType);
    if~isempty(dataConfig)
        hlp.setProp(dataConfig,'InitialCSCAttributesSchema',jsonencode(instSp));
    end
end