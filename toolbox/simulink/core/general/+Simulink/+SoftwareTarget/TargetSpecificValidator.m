




classdef TargetSpecificValidator
    methods(Static=true)


        function CheckSimulationConstraints(targetConfiguration)
            targetConfiguration.checkSimulationConstraints();
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidCombinationOfTaskGroups(targetConfiguration);
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidMappings(targetConfiguration);
            numTaskGroups=length(targetConfiguration.ParentTaskConfiguration.TaskGroups);
            for ii=1:numTaskGroups
                taskGroup=targetConfiguration.ParentTaskConfiguration.TaskGroups(ii);

                if isa(taskGroup,'Simulink.SoftwareTarget.AperiodicTrigger')...
                    &&~isempty(taskGroup.TargetObject)
                    taskGroup.TargetObject.checkSimulationConstraints(targetConfiguration);
                end
            end
        end



        function CheckCodeGenerationConstraints(targetConfiguration)
            targetConfiguration.checkCodeGenerationConstraints();
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidMappings(targetConfiguration);
            numTaskGroups=length(targetConfiguration.ParentTaskConfiguration.TaskGroups);
            for ii=1:numTaskGroups
                taskGroup=targetConfiguration.ParentTaskConfiguration.TaskGroups(ii);

                if isa(taskGroup,'Simulink.SoftwareTarget.AperiodicTrigger')...
                    &&~isempty(taskGroup.TargetObject)
                    taskGroup.TargetObject.checkCodeGenerationConstraints(targetConfiguration);
                end
            end
        end
    end
end
