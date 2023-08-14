classdef(ConstructOnLoad)UpdateNameEventData<event.EventData



    properties
Index
Name
    end

    methods
        function data=UpdateNameEventData(index,name)
            data.Index=index;
            data.Name=name;
        end
    end
end
