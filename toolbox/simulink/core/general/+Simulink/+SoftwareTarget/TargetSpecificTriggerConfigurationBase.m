classdef TargetSpecificTriggerConfigurationBase<handle






    properties(SetObservable=true)
        ParentTaskConfiguration;
    end

    methods

        function ret=getAperiodicTriggerTypes(~)
            ret={};
        end


        function ret=getDefaultAperiodicTriggerType(~)
            ret='';
        end


        function targetObj=createAperiodicTrigger(~,~)
            targetObj=[];
        end


        function ret=getPeriodicTriggerTypes(~)
            ret={};
        end


        function ret=getDefaultPeriodicTriggerType(~)
            ret='';
        end


        function targetObj=createPeriodicTrigger(~,~)
            targetObj=[];
        end



        function checkSimulationConstraints(~)

        end



        function checkCodeGenerationConstraints(obj)
            Simulink.SoftwareTarget.TargetObjectUtils.checkInvalidAccess(obj);
        end
    end


end
