




function handleCppQuickEditorOutput(ss,proxyObjects,valuesJSON)
    titleView=ss.getTitleView();
    if~isa(titleView,'DAStudio.Dialog')
        return;
    end
    dataViewObj=titleView.getDialogSource;
    cm=coder.mapping.api.get(dataViewObj.m_Source.getFullName);
    mappingProxy=proxyObjects{1};
    nameValuePairs=Simulink.CodeMapping.createNameValuePairsForMappingAPI(valuesJSON);
    category=mappingProxy.getPropValue('Model Element Category');
    if isempty(nameValuePairs)
        return;
    end
    try
        if strcmp(category,'Inports')
            cm.setData('Inports',nameValuePairs{:});
        elseif strcmp(category,'Outports')
            cm.setData('Outports',nameValuePairs{:});
        elseif strcmp(category,'Model parameter arguments')
            cm.setData('ModelParameterArguments',nameValuePairs{:});
        end
    catch ME
        ME2=MSLException('coderdictionary:mapping:MappingInspectorError');
        ME2=ME2.addCause(ME);
        throw(ME2);
    end
end
