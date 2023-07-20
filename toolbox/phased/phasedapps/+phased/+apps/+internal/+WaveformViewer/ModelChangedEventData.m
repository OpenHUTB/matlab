classdef(ConstructOnLoad)ModelChangedEventData<event.EventData



    properties
Name
Elem
Index
Process
    end

    methods
        function data=ModelChangedEventData(name,elem,process,index)
            data.Name=name;
            data.Elem=elem;
            data.Process=process;
            if nargin==4
                data.Index=index;
            end
        end
    end
end
