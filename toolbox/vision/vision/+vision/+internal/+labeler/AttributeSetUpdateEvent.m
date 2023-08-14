


classdef AttributeSetUpdateEvent<event.EventData
    properties
AttributeName
OldAttributeName
LabelName
SublabelName
    end

    methods
        function this=AttributeSetUpdateEvent(labelName,sublabelName,attributeName)
            this.AttributeName=attributeName;
            this.LabelName=labelName;
            this.SublabelName=sublabelName;
        end
    end
end