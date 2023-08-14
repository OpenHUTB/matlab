




function modeReceiverPortsCell=getModeReceiverPorts(mapping,runnableName)%#ok<INUSD>
    modeReceiverPortsCell=cell(1,1);
    modeReceiverPortsCell{1}=DAStudio.message('RTW:autosar:selectERstr');
    modelName=autosar.api.Utils.getModelNameFromMapping(mapping);
    dataObj=autosar.api.getAUTOSARProperties(modelName,true);
    compQualPath=dataObj.get('XmlOptions','ComponentQualifiedName');
    mrports=dataObj.get(compQualPath,'ModeReceiverPorts');
    for ii=1:numel(mrports)
        tokens=regexp(mrports{ii},'\/([^\/]*)','tokens');
        modeReceiverPortsCell{end+1}=tokens{end}{1};%#ok<AGROW>
    end



    rports=dataObj.get(compQualPath,'ReceiverPorts','PathType','FullyQualified');
    for ii=1:numel(rports)
        interface=dataObj.get(rports{ii},'Interface','PathType','FullyQualified');
        modeGroup=dataObj.get(interface,'ModeGroup');
        if~isempty(modeGroup)
            tokens=regexp(rports{ii},'\/([^\/]*)','tokens');
            modeReceiverPortsCell{end+1}=tokens{end}{1};%#ok<AGROW>
        end
    end

end


