



classdef SimulinkFunctionCallerPlacementConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out=['Simulink Function can only be called by '...
            ,'caller blocks defined in same model'];
        end


        function obj=SimulinkFunctionCallerPlacementConstraint()
            obj.setEnum('SimulinkFunctionCallerPlacementConstraint');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            SLFcnBlk=aObj.getOwner;
            assert(isa(SLFcnBlk,'slci.simulink.SimulinkFunctionBlock'));
            mdl=aObj.ParentModel;
            fcns=mdl.getSimulinkFunctionInfo(SLFcnBlk.getHandle);
            assert(numel(fcns)==1,...
            'Multiple Simulink Function produced from Simulink Function block');
            callers=fcns{1}.getCallers;
            for i=1:numel(callers)
                callerObj=get_param(callers{i},'Object');
                if isa(callerObj,'Simulink.ModelReference')
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum(),...
                    aObj.ParentModel().getName());
                    return;
                end
            end
        end
    end
end