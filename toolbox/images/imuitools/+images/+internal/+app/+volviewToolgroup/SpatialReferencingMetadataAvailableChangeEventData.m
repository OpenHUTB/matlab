

classdef(ConstructOnLoad)SpatialReferencingMetadataAvailableChangeEventData<event.EventData
    properties
MetadataAvailable
    end

    methods
        function data=SpatialReferencingMetadataAvailableChangeEventData(TF)
            data.MetadataAvailable=TF;
        end
    end
end