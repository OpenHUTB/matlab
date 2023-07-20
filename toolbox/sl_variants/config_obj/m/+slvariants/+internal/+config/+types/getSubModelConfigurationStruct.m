function subModelConfigStruct=getSubModelConfigurationStruct(zeroSize)
    subModelConfigStruct=struct(...
    'ModelName','',...
    'ConfigurationName','');
    if nargin==1&&zeroSize
        subModelConfigStruct(end)=[];
    end
end
