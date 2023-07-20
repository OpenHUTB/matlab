classdef(ConstructOnLoad)ElementSelectedEventData<event.EventData



    properties
Index
Element
    end

    methods
        function data=ElementSelectedEventData(index,elem)
            data.Index=index;
            if nargin==2
                data.Element=elem;
            end
        end
    end
end
