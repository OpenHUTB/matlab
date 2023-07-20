
function dt=processDataTypeObject(type,model)

    import systemcomposer.internal.parameters.arch.sync.*


    dt=string(type);


    try
        resolvedDT=slResolve(type,model);
    catch
        return;
    end

    if isempty(resolvedDT)
        return;
    end


    if isa(resolvedDT,'Simulink.AliasType')

        dt=processDataTypeObject(resolvedDT.BaseType,model);
    elseif isa(resolvedDT,'Simulink.NumericType')


        supportedModes=["Double","Single","Boolean"];
        dtMode=string(resolvedDT.DataTypeMode);
        if find(strcmp(dtMode,supportedModes),1)
            dt=lower(dtMode);
        end
    end
end