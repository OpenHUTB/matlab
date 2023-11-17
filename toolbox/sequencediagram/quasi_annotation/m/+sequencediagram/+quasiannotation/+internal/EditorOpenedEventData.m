classdef EditorOpenedEventData<event.EventData

    properties
        ModelName;
        SequenceDiagramName;
    end

    methods
        function obj=EditorOpenedEventData(modelName,sequenceDiagramName)
            obj.ModelName=modelName;
            obj.SequenceDiagramName=sequenceDiagramName;
        end
    end
end

