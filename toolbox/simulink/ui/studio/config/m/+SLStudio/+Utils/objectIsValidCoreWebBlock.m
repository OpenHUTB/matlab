function res=objectIsValidCoreWebBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidBlock(obj)
        res=strcmp(get_param(obj.handle,'IsCoreWebBlock'),'on');
    end
end
