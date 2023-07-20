function res=objectIsValidStateflowBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidBlock(obj)
        res=obj.isStateflow||obj.isStateflowLink;
    end
end
