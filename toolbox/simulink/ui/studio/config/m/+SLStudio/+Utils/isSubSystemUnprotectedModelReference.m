function res=isSubSystemUnprotectedModelReference(block)




    res=false;
    if isa(block,'Simulink.ModelReference')
        is_protected_model=strcmp('on',get_param(block.Handle,'ProtectedModel'));
        if~is_protected_model
            name=get_param(block.Handle,'ModelName');
            default_name=slInternal('getModelRefDefaultModelName');
            if~strcmpi(name,default_name)
                res=true;
            end
        end
    end
end
