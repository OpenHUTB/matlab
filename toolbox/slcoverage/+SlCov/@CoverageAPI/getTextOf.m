function str=getTextOf(id,index,elements,detailLevel)



    try
        if cvi.CascMCDC.isCascMcdcCondition(id)
            str=cvi.CascMCDC.getTextOfCascMcdcCondition(id);
        else
            str=cv('TextOf',id,index,elements,detailLevel);
        end
    catch MEx
        rethrow(MEx);
    end
