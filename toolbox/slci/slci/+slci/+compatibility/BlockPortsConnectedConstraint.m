


classdef BlockPortsConnectedConstraint<slci.compatibility.Constraint

    methods
        function obj=BlockPortsConnectedConstraint()
            obj.setEnum('UnconnectedObjects');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)
            out=['The inports and outports of the blocks of '...
            ,aObj.ParentModel().getName(),' must be connected'];
        end

        function out=check(aObj)
            out=[];

            mdlHandle=aObj.ParentModel().getHandle();
            xlateTagPrefix='ModelAdvisor:engine:';
            [bResult,ResultDescription]=...
            ModelAdvisor.Common.modelAdvisorCheck_UnconnectedObjects(mdlHandle,xlateTagPrefix);
            if~bResult
                failure=slci.compatibility.Incompatibility(...
                aObj,...
                'UnconnectedObjects');
                failure.setObjectsInvolved(ResultDescription{1}.ListObj);
                out=[out,failure];
            end
        end

    end
end
