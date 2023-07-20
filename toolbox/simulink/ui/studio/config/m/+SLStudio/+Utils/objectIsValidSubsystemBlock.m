function res=objectIsValidSubsystemBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidBlock(obj)
        res=strcmpi(get_param(obj.handle,'BlockType'),'SubSystem');
    end
end
