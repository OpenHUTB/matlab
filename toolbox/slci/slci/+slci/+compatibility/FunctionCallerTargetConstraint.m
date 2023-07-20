




classdef FunctionCallerTargetConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out='Function Caller block can only call Simulink Function';
        end


        function obj=FunctionCallerTargetConstraint()
            obj.setEnum('FunctionCallerTarget')
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            blk=aObj.getOwner;
            assert(isa(blk,'slci.simulink.FunctionCallerBlock'));
            funcHdl=blk.getFunctionHandle;

            isSupported=~isempty(funcHdl)&&...
            strcmpi(slci.internal.getSubsystemType(...
            get_param(funcHdl,'Object')),'simulinkfunction');
            if~isSupported
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),...
                aObj.ParentModel().getName());
            end

        end
    end
end
