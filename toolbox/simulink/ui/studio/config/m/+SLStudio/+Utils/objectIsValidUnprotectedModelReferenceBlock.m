function res=objectIsValidUnprotectedModelReferenceBlock(obj)




    res=false;
    if SLStudio.Utils.objectIsValidModelReferenceBlock(obj)
        is_protected_model=strcmp('on',get_param(obj.handle,'ProtectedModel'));
        if~is_protected_model
            name=get_param(obj.handle,'ModelName');
            default_name=slInternal('getModelRefDefaultModelName');
            if~strcmpi(name,default_name)
                res=true;
            end
        end
    end
end
