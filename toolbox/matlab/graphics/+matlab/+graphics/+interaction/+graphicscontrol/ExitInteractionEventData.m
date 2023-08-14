classdef ExitInteractionEventData<matlab.graphics.interaction.graphicscontrol.EnterExitEventData




    properties
        ExitedObjectType string
    end

    methods
        function data=ExitInteractionEventData(exitedObjectType)
            data@matlab.graphics.interaction.graphicscontrol.EnterExitEventData('Exit');
            data.ExitedObjectType=exitedObjectType;
        end
    end
end