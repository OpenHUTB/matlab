


classdef StateflowFirstIndexConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The First Index of a Stateflow data should be set to empty or 0.';
        end

        function obj=StateflowFirstIndexConstraint
            obj.setEnum('StateflowFirstIndex');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            uddObj=aObj.ParentData().getUDDObject();

            firstIndex=uddObj.Props.Array.FirstIndex;
            if~(isempty(firstIndex)...
                ||(str2double(firstIndex)==0))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowFirstIndex',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end
