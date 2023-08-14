




classdef slrealtimeMDSCustomization<Simulink.SoftwareTarget.TargetSpecificTriggerConfigurationBase






    properties(Constant=true)
        TriggerTypes={slrealtimeHardwareInterrupt.getTypeName()};
    end

    methods


        function ret=getAperiodicTriggerTypes(~)
            ret=slrealtimeMDSCustomization.TriggerTypes;
        end


        function ret=getDefaultAperiodicTriggerType(~)
            ret=slrealtimeHardwareInterrupt.getTypeName();
        end



        function checkSimulationConstraints(obj)
            slrealtimeHardwareInterrupt.checkGenericSimulationConstraints(obj);
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidTaskMapping(obj);
        end



        function checkCodeGenerationConstraints(obj)
            slrealtimeHardwareInterrupt.checkGenericCodeGenerationConstraints(obj);
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidTaskMapping(obj);
        end




        function targetObj=createAperiodicTrigger(~,~)




            targetObj=[];

        end
    end
end


