function ctrlVarStruct=getControlVariableStruct(zeroSize)
    ctrlVarStruct=struct(...
    'Name','',...
    'Value',[],...
    'Source','base workspace');
    if nargin==1&&zeroSize
        ctrlVarStruct(end)=[];
    end
end
