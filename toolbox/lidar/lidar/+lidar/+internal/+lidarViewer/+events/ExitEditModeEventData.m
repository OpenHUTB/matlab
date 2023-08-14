classdef(ConstructOnLoad)ExitEditModeEventData<event.EventData





    properties
        ToSave(1,1)logical
    end

    methods

        function data=ExitEditModeEventData(toSave)
            data.ToSave=toSave;
        end
    end
end