function res=objectIsValidScopeBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidBlock(obj)
        res=strcmpi(get_param(obj.handle,'BlockType'),'Scope');
    end
end
