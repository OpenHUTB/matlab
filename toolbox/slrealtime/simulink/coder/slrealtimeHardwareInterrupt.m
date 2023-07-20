




classdef slrealtimeHardwareInterrupt<Simulink.SoftwareTarget.TargetSpecificTriggerBase










    methods(Static=true)



        function typeName=getTypeName()
            typeName=[];
        end





        function checkGenericSimulationConstraints(~)
        end



        function checkGenericCodeGenerationConstraints(targetSpecificConfig)
            AEHs=targetSpecificConfig.ParentTaskConfiguration.TaskGroups;












            return;













        end













    end

    methods


































        function checkSimulationConstraints(~,~)
        end



        function checkCodeGenerationConstraints(~,~)
        end
    end
end


