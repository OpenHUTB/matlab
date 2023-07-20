function errors=pushControlVarsToGlobalOrTempWS(modelName,configName,controlVariables,...
    pushToTempWorspace,reportErrors,skipAssigninGlobalWkspce,usedByDefaultConfig)






    errors={};
    if~isempty(controlVariables)
        numVars=length(controlVariables);
        modelHandle=get_param(modelName,'Handle');
        overwrittenControlVars={};
        referencedDDsOfModel=Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries(modelName);
        for i=1:numVars
            controlVariable=controlVariables(i);
            defaultDataSource=slvariants.internal.config.utils.getGlobalWorkspaceName(get_param(modelHandle,'DataDictionary'));
            if~isfield(controlVariable,'Source')||isempty(controlVariable.Source)


                controlVariable.Source=defaultDataSource;
            end

            if strcmp(controlVariable.Source,slvariants.internal.config.utils.getGlobalWorkspaceName_R2020b(''))

                controlVariable.Source=slvariants.internal.config.utils.getGlobalWorkspaceName('');
            end



            if Simulink.variant.utils.isCharOrString(controlVariable.Value)
                val=convertStringsToChars(controlVariable.Value);
            elseif isa(controlVariable.Value,'Simulink.VariantControl')
                val=controlVariable.Value;
            elseif isa(controlVariable.Value,'Simulink.Parameter')
                assert(~controlVariable.Value.CoderInfo.HasContext,'Expected base workspace object only');
                val=copy(controlVariable.Value);
            else
                val=controlVariable.Value;
            end

            try


                if isa(val,'char')
                    controlVariableToSend=controlVariable;
                    eval(strcat('val = ',val,';'));
                    if Simulink.data.isSupportedEnumObject(val)||...
                        Simulink.variant.manager.configutils.isScalarParameterObj(val)||...
                        Simulink.variant.manager.configutils.isScalarVariantControlObj(val)
                        cv.Name=controlVariable.Name;
                        cv.ParameterObject=val;
                        cv.Source=controlVariable.Source;
                        controlVariableToSend=cv;
                    end
                elseif Simulink.data.isSupportedEnumObject(val)||...
                    Simulink.variant.manager.configutils.isScalarParameterObj(val)||...
                    Simulink.variant.manager.configutils.isScalarVariantControlObj(val)
                    cv.Name=controlVariable.Name;
                    cv.ParameterObject=val;
                    cv.Source=controlVariable.Source;
                    controlVariableToSend=cv;
                else
                    cv.Name=controlVariable.Name;
                    cv.ParameterObject=val;
                    cv.Source=controlVariable.Source;
                    controlVariableToSend=cv;
                end
                if~skipAssigninGlobalWkspce
                    if~strcmp(controlVariable.Source,slvariants.internal.config.utils.getGlobalWorkspaceName(''))
                        ddSpec=controlVariable.Source;
                    else
                        ddSpec='';
                    end
                    isValueOverwritten=Simulink.variant.utils.slddaccess.assignInGlobalScopeOfDataDictionary(...
                    controlVariable.Name,val,ddSpec);
                    if isValueOverwritten
                        overwrittenControlVars=[overwrittenControlVars,controlVariable.Name];%#ok<AGROW>
                    end
                end







                if pushToTempWorspace&&Simulink.variant.utils.slddaccess.isSourceAccessibleForModel(modelName,defaultDataSource,controlVariableToSend.Source,referencedDDsOfModel)




                    slInternal('pushControlVariableToTempWS',modelHandle,controlVariableToSend);
                end
            catch ME
                if reportErrors

                    excepHighLevel=MException(message('Simulink:Variants:InvalidControlVarValue'));
                    excepHighLevel=excepHighLevel.addCause(ME);
                    errors{end+1}=Simulink.variant.manager.errorutils.getValidationErrorForConfiguration...
                    (excepHighLevel,'ControlVariable',controlVariable.Name,configName,modelName);%#ok<AGROW>
                end
            end
        end

        if usedByDefaultConfig&&~isempty(overwrittenControlVars)



            warnState=warning('off','backtrace');
            overwrittenControlVarsStr=Simulink.variant.utils.i_cell2str(overwrittenControlVars);
            vcdoName=get_param(modelName,'VariantConfigurationObject');
            msgId='Simulink:VariantManager:DefaultConfigOverridesControlVars';
            warning(msgId,getString(message(msgId,configName,vcdoName,modelName,overwrittenControlVarsStr)));
            warning(warnState.state,'backtrace');
        end
    end
end


