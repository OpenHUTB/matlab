




function handleCQuickEditorOutput(ss,proxyObjects,valuesJSON)
    titleView=ss.getTitleView();
    if~isa(titleView,'DAStudio.Dialog')
        return;
    end
    modelName=titleView.getDialogSource.m_Source.getFullName;
    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelName);
    nameValuePairs=Simulink.CodeMapping.createNameValuePairsForMappingAPI(valuesJSON);
    if isempty(nameValuePairs)
        return;
    end
    mappingProxy=proxyObjects{1};
    mappingSource=mappingProxy.getForwardedObject;
    try
        if isa(mappingSource,'Simulink.Inport')&&...
            strcmp('off',get(mappingSource,'OutputFunctionCall'))
            mapIdx=find(arrayfun(@(x)isequal(get_param(x.Block,'Handle'),...
            mappingSource.Handle),modelMapping.Inports));
            mapping=modelMapping.Inports(mapIdx);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'Inports',nameValuePairs{:});
        elseif isa(mappingSource,'Simulink.Outport')
            mapIdx=find(arrayfun(@(x)isequal(get_param(x.Block,'Handle'),...
            mappingSource.Handle),modelMapping.Outports));
            mapping=modelMapping.Outports(mapIdx);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'Outports',nameValuePairs{:});
        elseif(isa(mappingSource,'Simulink.Parameter')||...
            isa(mappingSource,'Simulink.LookupTable')||...
            isa(mappingSource,'Simulink.Breakpoint'))
            paramName=mappingProxy.getPropValue('Source');
            mapping=modelMapping.ModelScopedParameters.findobj('Parameter',paramName);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'ModelParameters',nameValuePairs{:});
        elseif isa(mappingSource,'Simulink.Port')
            mapping=modelMapping.Signals.findobj('PortHandle',mappingSource.Handle);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'Signals',nameValuePairs{:});
        elseif isa(mappingSource,'Simulink.DataStoreMemory')
            mapping=modelMapping.DataStores.findobj('OwnerBlockHandle',mappingSource.Handle);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'DataStores',nameValuePairs{:});
        elseif isa(mappingSource,'Simulink.Signal')
            signalName=mappingProxy.getPropValue('Source');
            mapping=modelMapping.SynthesizedLocalDataStores.findobj('Name',signalName);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'SynthesizedDataStores',nameValuePairs{:});
        elseif strcmp(mappingSource.Type,'block')&&~isa(mappingSource,'Simulink.Inport')
            mapping=modelMapping.States.findobj('OwnerBlockHandle',mappingSource.Handle);
            coder.mapping.internal.setIndividualDataFromMappingInspector(...
            modelName,mapping,'States',nameValuePairs{:});
        else

            fcnId=mappingProxy.getPropValue('FunctionNameForAPI');
            if~isempty(fcnId)&&~strcmp(fcnId,'Auto')

                coder.mapping.internal.setIndividualFunctionsFromMappingInspector(...
                modelName,modelMapping,fcnId,nameValuePairs{:});
            else

                defaultCategory=mappingProxy.getDisplayLabel;
                coder.mapping.internal.setDefaultsMappingFromMappingInspector(...
                modelMapping,defaultCategory,nameValuePairs{:});
            end
        end
    catch ME
        ME2=MSLException('coderdictionary:mapping:MappingInspectorError');
        ME2=ME2.addCause(ME);
        throw(ME2);
    end
end
