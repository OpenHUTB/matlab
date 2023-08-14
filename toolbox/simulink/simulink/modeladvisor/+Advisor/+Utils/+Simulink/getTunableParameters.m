















function[tunableParameters,varUsages]=getTunableParameters(system,CSCisConsideredTunable)




    tunableStorageClasses=coder.internal.getBuiltinStorageClasses(false);








    if slprivate('isUsingAnyDataDictionary',bdroot(system))
        usedVars=Simulink.findVars(system,'SearchMethod','cached','SourceType','data dictionary');
        tunableVars='';
        if slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&...
            strcmp(get_param(bdroot(system),'HasAccessToBaseWorkspace'),'on')

            varBWS=Simulink.findVars(system,...
            'SearchMethod','cached',...
            'SourceType','base workspace');
            usedVars=cat(1,usedVars,varBWS);
            tunableVars=regexp(get_param(bdroot(system),'TunableVars'),',','split');
        end
    else
        usedVars=Simulink.findVars(system,'SearchMethod','cached','SourceType','base workspace');

        tunableVars=regexp(get_param(bdroot(system),'TunableVars'),',','split');
        if~isempty(tunableVars)
            tunableVars=strtrim(tunableVars);
        end
    end

    tunableParameters={};
    varUsages=Simulink.VariableUsage.empty(0,0);

    for n=1:length(usedVars)
        if usedVars(n).isvalid
            tempVar=evalinGlobalScope(bdroot(system),usedVars(n).Name);



            if isa(tempVar,'Simulink.Parameter')&&...
                any(strcmp(tunableStorageClasses,tempVar.CoderInfo.StorageClass))

                tunableParameters{end+1}=tempVar;%#ok<AGROW>
                varUsages(end+1)=usedVars(n);%#ok<AGROW>

            elseif CSCisConsideredTunable&&isa(tempVar,'Simulink.Parameter')&&...
                ~strcmp('Auto',tempVar.CoderInfo.StorageClass)


                tunableParameters{end+1}=tempVar;%#ok<AGROW>
                varUsages(end+1)=usedVars(n);%#ok<AGROW>

            elseif~isempty(tunableVars)&&any(strcmp(tunableVars,usedVars(n).Name))


                tunableParameters{end+1}=tempVar;%#ok<AGROW>
                varUsages(end+1)=usedVars(n);%#ok<AGROW>
            end
        end
    end
end
