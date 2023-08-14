




function handleARQuickEditorOutput(ss,proxyObjects,valuesJSON)
    titleView=ss.getTitleView();
    if~isa(titleView,'DAStudio.Dialog')
        return;
    end
    dataViewObj=titleView.getDialogSource;
    modelName=dataViewObj.m_Source.getFullName;
    modelH=get_param(modelName,'Handle');
    mappingProxy=proxyObjects{1};
    mappingSource=mappingProxy.getForwardedObject;
    nameValuePairs=Simulink.CodeMapping.createNameValuePairsForMappingAPI(valuesJSON);
    if isempty(nameValuePairs)
        return
    end
    try
        if isa(mappingSource,'Simulink.Inport')&&...
            strcmp('off',get(mappingSource,'OutputFunctionCall'))
            blockName=mappingProxy.getFullName;
            Simulink.CodeMapping.setCommunicationAttributesFromJSON(modelH,'Inports',blockName,valuesJSON);
        elseif isa(mappingSource,'Simulink.Outport')
            blockName=mappingProxy.getFullName;
            Simulink.CodeMapping.setCommunicationAttributesFromJSON(modelH,'Outports',blockName,valuesJSON);
        else
            slMap=autosar.api.getSimulinkMapping(modelName);
            if isempty(nameValuePairs)
                return
            end
            if isa(mappingSource,'Simulink.BlockDiagram')||...
                isa(mappingSource,'Simulink.Inport')||...
                isa(mappingSource,'Simulink.SubSystem')


                functionType=mappingProxy.getPropValue('FunctionNameForAPI');
                runnable=slMap.getFunction(functionType);
                if~isempty(runnable)
                    slMap.mapFunction(functionType,runnable,nameValuePairs{:});
                end
            elseif(isa(mappingSource,'Simulink.Parameter')||...
                isa(mappingSource,'Simulink.LookupTable')||...
                isa(mappingSource,'Simulink.Breakpoint'))
                paramName=mappingProxy.getPropValue('Source');
                mappedTo=slMap.getParameter(paramName);
                slMap.mapParameter(paramName,mappedTo,nameValuePairs{:});
            elseif isa(mappingSource,'Simulink.Signal')
                sigName=mappingProxy.getPropValue('Source');
                mappedTo=slMap.getSynthesizedDataStore(sigName);
                slMap.mapSynthesizedDataStore(sigName,mappedTo,nameValuePairs{:});
            else
                blockOrPortHandle=mappingSource.Handle;
                if isa(mappingSource,'Simulink.Port')
                    mappedTo=slMap.getSignal(blockOrPortHandle);
                    slMap.mapSignal(blockOrPortHandle,mappedTo,nameValuePairs{:});
                elseif isa(mappingSource,'Simulink.DataStoreMemory')
                    mappedTo=slMap.getDataStore(blockOrPortHandle);
                    nameValuePairs=...
                    autosar.mm.util.NvBlockNeedsCodePropsHelper.updateNvBlockNeedCodeMappingArguments(nameValuePairs);
                    slMap.mapDataStore(blockOrPortHandle,mappedTo,nameValuePairs{:});
                elseif strcmp(mappingSource.Type,'block')
                    mappedTo=slMap.getState(blockOrPortHandle);
                    slMap.mapState(blockOrPortHandle,'',mappedTo,nameValuePairs{:});
                end
            end
        end
    catch ME
        ME2=MSLException('coderdictionary:mapping:MappingInspectorError');
        ME2=ME2.addCause(ME);
        throw(ME2);
    end
end
