classdef InitResetTermFcnBlock<handle




    methods(Static)
        function blocks=findIRTBlocks(model)
            blocks=[autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(model),...
            autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks(model),...
            autosar.utils.InitResetTermFcnBlock.findResetFunctionBlocks(model)];
        end

        function blocks=findInitFunctionBlocks(model)
            blocks=autosar.utils.InitResetTermFcnBlock.findBlocksWithEvent(model,'Initialize');
        end

        function blocks=findTermFunctionBlocks(model)
            blocks=autosar.utils.InitResetTermFcnBlock.findBlocksWithEvent(model,'Terminate');
        end

        function blocks=findResetFunctionBlocks(model)
            blocks=autosar.utils.InitResetTermFcnBlock.findBlocksWithEvent(model,'Reset');
        end

        function blocks=findReinitializeFunctionBlocks(model)
            blocks=autosar.utils.InitResetTermFcnBlock.findBlocksWithEvent(model,'Reinitialize');
        end

        function blocks=findResetFunctionBlocksWithName(model,resetFcnName)
            blocks=autosar.utils.InitResetTermFcnBlock.findBlocksWithEvent(model,'Reset',resetFcnName);
        end
    end

    methods(Static,Access=private)
        function blocks=findBlocksWithEvent(system,eventType,eventName)
            blocks={};
            matchEventName=(nargin>2);
            eventSystems=find_system(system,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.activeVariants,...
            'LookUnderMasks','all','BlockType','SubSystem',...
            'SystemType','EventFunction');
            for sysIdx=1:length(eventSystems)

                eventSystem=eventSystems{sysIdx};


                eventListener=find_system(eventSystem,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','EventListener');
                if(strcmp(get_param(eventListener,'EventType'),eventType))
                    if matchEventName
                        if strcmp(get_param(eventListener,'EventName'),eventName)
                            blocks{end+1}=eventSystem;%#ok<AGROW>
                        end
                    else
                        blocks{end+1}=eventSystem;%#ok<AGROW>
                    end
                end
            end
        end
    end
end


