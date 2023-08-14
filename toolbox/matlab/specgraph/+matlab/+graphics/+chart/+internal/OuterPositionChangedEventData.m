classdef OuterPositionChangedEventData<event.EventData
    properties(Transient,NonCopyable)
        SourceMethod string="";
        PositionConstraint string="";
    end
end