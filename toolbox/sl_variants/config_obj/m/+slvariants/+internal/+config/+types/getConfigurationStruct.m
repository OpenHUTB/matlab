function configStruct=getConfigurationStruct(zeroSize)




    configStruct=struct(...
    'Name','',...
    'Description','',...
    'ControlVariables',slvariants.internal.config.types.getControlVariableStruct(true));
    if nargin==1&&zeroSize
        configStruct(end)=[];
    end
end
