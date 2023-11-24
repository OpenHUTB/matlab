classdef SequenceDiagramManager<handle

    properties
SequenceDiagramName
        Annotations=sequencediagram.quasiannotation.internal.BaseAnnotation.empty();
    end

    methods
        function obj=SequenceDiagramManager(sequenceDiagramName)
            obj.SequenceDiagramName=sequenceDiagramName;
        end
    end

end

