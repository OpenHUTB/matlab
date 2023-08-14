classdef(Hidden)DataProperties<handle






    properties
        WorkspaceVarName char='select variable'
        VariableName char='select variable'
        IsTabular(1,1)logical
        MappedChannel matlab.visualize.task.internal.model.VisualChannelModel
    end

    methods

        function deserializeDataParameters(obj,dataStruct,channelData)
            obj.WorkspaceVarName=dataStruct.WorkspaceVarName;
            obj.VariableName=dataStruct.VariableName;
            obj.IsTabular=dataStruct.IsTabular;

            if isempty(dataStruct.MappedChannel)||isempty(channelData)
                obj.MappedChannel=matlab.visualize.task.internal.model.VisualChannelModel.empty();
            else
                obj.MappedChannel=channelData;
                obj.MappedChannel.deserializeVisualChannels(dataStruct.MappedChannel);
            end
        end
    end
end