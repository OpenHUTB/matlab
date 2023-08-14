


classdef SublabelSetUpdateEvent<event.EventData
    properties
SublabelName
OldSublabelName
LabelName
    end

    methods
        function this=SublabelSetUpdateEvent(labelName,sublabelName)
            this.SublabelName=sublabelName;
            this.LabelName=labelName;
        end
    end
end