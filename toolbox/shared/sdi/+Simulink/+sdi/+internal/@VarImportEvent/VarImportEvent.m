classdef(ConstructOnLoad)VarImportEvent<event.EventData




    properties
        Total;
        Current;
    end

    methods
        function obj=VarImportEvent(total,current)
            obj.Total=total;
            obj.Current=current;
        end
    end
end
