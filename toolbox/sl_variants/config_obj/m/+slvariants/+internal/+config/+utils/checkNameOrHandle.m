function err=checkNameOrHandle(nameOrHandle)




    err=[];
    if ischar(nameOrHandle)
        err=slvariants.internal.config.utils.checkName(nameOrHandle);
        return;
    end
    if~(isa(nameOrHandle,'double')&&isscalar(nameOrHandle))
        err=MException(message('Simulink:Variants:InvalidModelNameOrHandle'));
    end
end
