



classdef SimulinkFunctionVariantConditionConstraint<slci.compatibility.Constraint
    methods
        function out=getDescription(aObj)%#ok
            out=['SLCI does not support Simulink Function'...
            ,'with Enable Variant Condition on'];
        end


        function obj=SimulinkFunctionVariantConditionConstraint()
            obj.setEnum('SimulinkFunctionVariantCondition')
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock'))
            SLBlkObj=get_param(sub.getHandle,'Object');
            assert(strcmp(SLBlkObj.IsSimulinkFunction,'on'),...
            'Block is not a Simulink Function')
            prop=slci.internal.getSimulinkFunctionTriggerPortProperty(SLBlkObj);
            if prop.isVaraintOn
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),...
                aObj.ParentModel().getName());
            end
        end

    end
end