classdef(ConstructOnLoad)ModelChangedEventData<event.EventData
    properties
Name
Budget
Index
    end

    methods
        function data=ModelChangedEventData(name,budget,index)
            data.Name=name;
            data.Budget=budget;
            if nargin==3
                data.Index=index;
            end
        end
    end
end
