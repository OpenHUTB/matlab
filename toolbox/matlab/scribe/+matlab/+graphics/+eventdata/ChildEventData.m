classdef ChildEventData<event.EventData

    properties
        ParentNode;
        ChildNode;
    end

    methods(Hidden=true)
        function hObj=ChildEventData(parent,child)
            hObj.ParentNode=parent;
            hObj.ChildNode=child;
        end
    end
end