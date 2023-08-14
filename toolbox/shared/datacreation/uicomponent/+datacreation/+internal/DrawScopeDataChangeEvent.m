classdef(ConstructOnLoad,Hidden)DrawScopeDataChangeEvent<event.EventData






    properties
NewState
    end


    methods


        function data=DrawScopeDataChangeEvent(newState)
            data.NewState=newState;
        end

    end
end
