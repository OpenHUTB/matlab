function throwInvalidConfig(modelName,isVarConfigSpec,invalidConfig,errors)




    if isVarConfigSpec



        errid='Simulink:VariantReducer:VariableConfigInvalid';
        structofControlVars=invalidConfig.ControlVariables;
        stringofControlvars=convertControlVarsStructToString(structofControlVars);
        err=MSLException(get_param(modelName,'Handle'),message(errid,stringofControlvars,modelName));
    else



        errid='Simulink:Variants:InvalidConfigForModel';
        errmsg=message(errid,invalidConfig.Name,modelName);
        err=MSLException(get_param(modelName,'Handle'),errmsg);
    end
    if slfeature('VMgrV2UI')>0
        err=Simulink.variant.utils.addActivationCausesToDiagnostic(err,errors);
    else
        err=Simulink.variant.utils.addValidationCausesToDiagnostic(err,errors);
    end
    throw(err);
end

function stringofControlvars=convertControlVarsStructToString(structofControlVars)

    stringofControlvars='';



    for ii=1:numel(structofControlVars)
        if~(Simulink.variant.manager.configutils.isScalarParameterObj(structofControlVars(ii).Value)||...
            Simulink.variant.manager.configutils.isScalarVariantControlObj(structofControlVars(ii).Value))


            structofControlVars(ii).Value=str2num(structofControlVars(ii).Value);%#ok<ST2NM>
        end
        name=structofControlVars(ii).Name;
        val=Simulink.variant.reducer.utils.convertCVV2String(structofControlVars(ii).Value);
        stringofControlvars=[stringofControlvars,name,' = ',val,', '];%#ok<AGROW>
    end
    if isempty(stringofControlvars)
        return;
    end

    stringofControlvars(end-1:end)=[];
end
