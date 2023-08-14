function [outData] = pre17aAXI4ReadForward(inData)

outData.NewBlockPath = '';
outData.NewInstanceData = [];

instanceData = inData.InstanceData;
% Get the field type 'Name' from instanceData
[ParameterNames{1:length(instanceData)}] = instanceData.Name;

[~,interface_idx] = ismember('AXIInterfaceType',ParameterNames);
[~,datalen_idx] = ismember('DataLength',ParameterNames);
if (interface_idx) && (isequal(instanceData(interface_idx).Value,'AXI4-Lite') || isequal(instanceData(interface_idx).Value,'AXI4'))
    if (datalen_idx)
        instanceData(datalen_idx).Value = '1';
    end
end

outData.NewInstanceData = instanceData;
end
