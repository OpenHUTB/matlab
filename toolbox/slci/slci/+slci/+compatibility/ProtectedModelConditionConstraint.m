
classdef ProtectedModelConditionConstraint<slci.compatibility.Constraint

    methods

        function obj=ProtectedModelConditionConstraint()
            obj.setEnum('ProtectedModelCondition');
            obj.setFatal(true);
            obj.setCompileNeeded(0);
        end

        function out=getDescription(aObj)%#ok
            out='The model reference is in protected mode.';
        end

        function out=check(aObj)
            out=[];

            protectedMode=aObj.ParentBlock().getParam('ProtectedModel');
            if(strcmpi(protectedMode,'on'))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ProtectedModelCondition',...
                aObj.ParentBlock().getName());
            end

        end
    end
end