



classdef ERTCustomization<Simulink.SoftwareTarget.TargetSpecificTriggerConfigurationBase

    properties(Constant=true)
        TriggerTypes={Simulink.SoftwareTarget.PosixSignalHandler.getTypeName(),...
        Simulink.SoftwareTarget.WindowsEventHandler.getTypeName()};
    end

    methods

        function ret=getAperiodicTriggerTypes(~)
            ret=Simulink.SoftwareTarget.ERTCustomization.TriggerTypes;
        end


        function ret=getDefaultAperiodicTriggerType(~)
            ret=Simulink.SoftwareTarget.PosixSignalHandler.getTypeName();
        end



        function checkSimulationConstraints(obj)
            Simulink.SoftwareTarget.PosixSignalHandler.checkGenericSimulationConstraints(obj);
            Simulink.SoftwareTarget.WindowsEventHandler.checkGenericSimulationConstraints(obj);
        end



        function checkCodeGenerationConstraints(obj)
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidCombinationOfTaskGroups(obj);
            Simulink.SoftwareTarget.PosixSignalHandler.checkGenericCodeGenerationConstraints(obj);
            Simulink.SoftwareTarget.WindowsEventHandler.checkGenericCodeGenerationConstraints(obj);
            Simulink.SoftwareTarget.TargetObjectUtils.checkIncompatibleAperiodicTrigger(obj);
        end



        function targetObj=createAperiodicTrigger(~,triggerType)
            switch(triggerType)
            case Simulink.SoftwareTarget.PosixSignalHandler.getTypeName(),...
                targetObj=Simulink.SoftwareTarget.PosixSignalHandler();
            case Simulink.SoftwareTarget.WindowsEventHandler.getTypeName(),...
                targetObj=Simulink.SoftwareTarget.WindowsEventHandler();
            otherwise
                targetObj=[];
            end
        end
    end
end
