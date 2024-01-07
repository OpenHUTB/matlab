classdef(ConstructOnLoad)ModelChangedEventData<event.EventData

    properties
Name
SerdesDesign
Index
    end


    methods
        function data=ModelChangedEventData(name,serdesDesign,index)
            data.Name=name;
            data.SerdesDesign=serdesDesign;
            if nargin==3
                data.Index=index;
            end
        end
    end
end
