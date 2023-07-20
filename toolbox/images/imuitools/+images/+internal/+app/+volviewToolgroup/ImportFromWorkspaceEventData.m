

classdef(ConstructOnLoad)ImportFromWorkspaceEventData<event.EventData
    properties
VolumeData
VariableName
VolType
    end

    methods
        function data=ImportFromWorkspaceEventData(V,varName,volType)
            data.VolumeData=V;
            data.VariableName=varName;
            data.VolType=volType;
        end
    end
end