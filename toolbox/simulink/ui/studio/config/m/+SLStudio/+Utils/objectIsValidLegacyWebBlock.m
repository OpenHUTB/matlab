function res=objectIsValidLegacyWebBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidSubsystemBlock(obj)&&...
        SLStudio.Utils.objectIsValidBlock(obj)
        res=any(strcmpi(get_param(obj.handle,'IsWebBlock'),'on'));
    end
end
