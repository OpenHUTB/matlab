classdef(ConstructOnLoad,Hidden)DrawScopeSelectionChangeEvent<event.EventData






    properties
NewState
    end


    methods


        function data=DrawScopeSelectionChangeEvent(newState)
            data.NewState=newState;
        end

    end
end
