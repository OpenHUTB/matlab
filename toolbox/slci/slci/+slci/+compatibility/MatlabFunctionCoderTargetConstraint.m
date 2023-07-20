




classdef MatlabFunctionCoderTargetConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(~)
            out='coder.target cannot have empty target';
        end


        function obj=MatlabFunctionCoderTargetConstraint
            obj.setEnum('MatlabFunctionCoderTarget');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstCoderTarget'));

            if isempty(owner.getTarget)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end
end