
classdef MultiCaseConditionConstraint<slci.compatibility.Constraint

    methods

        function obj=MultiCaseConditionConstraint()
            obj.setEnum('MultiCaseCondition');
            obj.setFatal(false);
            obj.setCompileNeeded(false);
        end

        function out=getDescription(aObj)%#ok
            out='The condition in the switch case block should not have a range of values.';
        end

        function out=check(aObj)
            out=[];
            conditionsArr=slci.internal.parseSwitchCaseConditions(aObj.ParentBlock().getSID());



            if isempty(conditionsArr)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MultiCaseCondition',...
                aObj.ParentBlock().getName());
            end
        end
    end
end
