


classdef MatlabFunctionColonChildrenNumConstraint<slci.compatibility.Constraint

    properties(Access=private)

        fSupportedChildrenNum=3;
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Colon Operators cannot have more than 3 operands.';
        end


        function aObj=MatlabFunctionColonChildrenNumConstraint
            aObj.setEnum('MatlabFunctionColonChildrenNum');
            aObj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstColon'));
            numChildren=numel(owner.getChildren());

            if numChildren>aObj.fSupportedChildrenNum
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end

    end
end