function out=getDataDefaultInstanceSpecificProperties(sourceDD,modelElementType)



    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    modelElementType=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(modelElementType);
    out=[];
    dd=hlp.openDD(sourceDD);
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
    dataConfig=hlp.getProp(swc,modelElementType);
    sc=hlp.getProp(dataConfig,'InitialStorageClass');
    if~isempty(sc)
        scSchema=hlp.getProp(sc,'CSCAttributesSchema');
        instSpecificSchema=hlp.getProp(dataConfig,'InitialCSCAttributesSchema');
        if~isempty(scSchema)
            out=jsondecode(scSchema);
            if~isempty(instSpecificSchema)


                instSp=jsondecode(instSpecificSchema);
                for i=1:length(instSp)
                    for j=1:length(out)
                        if strcmp(instSp(i).Name,out(j).Name)
                            out(j).Value=instSp(i).Value;
                            out(j).DisplayValue=instSp(i).DisplayValue;
                        end
                    end
                end
            end
        end
    end
end
