


classdef StateflowDSMConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Data store access from Stateflow charts is not supported';
        end

        function obj=StateflowDSMConstraint
            obj.setEnum('StateflowDSM');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if strcmp(aObj.ParentData().getScope,'Data Store Memory')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDSM',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

