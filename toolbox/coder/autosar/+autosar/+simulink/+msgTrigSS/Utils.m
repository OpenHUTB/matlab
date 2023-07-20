classdef Utils<handle






    methods(Static,Access=public)
        function msgTriggeredSSBlks=findOnMessageTriggeredSSBlks(hModel)



            ssBlocks=autosar.simulink.msgTrigSS.Utils.findSSBlks(hModel);

            msgTriggeredSSBlks=ssBlocks(...
            arrayfun(@(x)autosar.simulink.msgTrigSS.Utils.isMessageTriggeredSS(x),...
            ssBlocks));
        end

        function msgTriggeredSampleTimeSSBlks=findMessageTriggeredSubsystems(hModel)



            ssBlocks=autosar.simulink.msgTrigSS.Utils.findSSBlks(hModel);

            msgTriggeredSampleTimeSSBlks=ssBlocks(...
            arrayfun(@(x)autosar.simulink.msgTrigSS.Utils.isMessageTriggeredSS(x),...
            ssBlocks));
        end

        function isMessageTriggeredSS=isMessageTriggeredSS(sys)
            isMessageTriggeredSS=false;
            if strcmp(get_param(sys,'BlockType'),'SubSystem')
                ssType=Simulink.SubsystemType(sys);
                isMessageTriggeredSS=ssType.isMessageTriggeredSampleTime()||...
                ssType.isMessageTriggeredFunction();
            end
        end
    end

    methods(Static,Access=private)
        function SSBlks=findSSBlks(hModel)
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                SSBlks=find_system(hModel,'MatchFilter',@Simulink.match.activeVariants,...
                'Type','block','BlockType','SubSystem');
            else
                SSBlks=find_system(hModel,'Type','block','BlockType','SubSystem');
            end
        end
    end
end
