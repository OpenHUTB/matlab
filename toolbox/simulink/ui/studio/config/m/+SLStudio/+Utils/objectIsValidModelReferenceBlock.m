function res=objectIsValidModelReferenceBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidBlock(obj)
        res=strcmpi(get_param(obj.handle,'BlockType'),'ModelReference');
    end
end
