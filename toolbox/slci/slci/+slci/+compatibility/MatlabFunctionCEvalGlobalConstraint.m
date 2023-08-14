




classdef MatlabFunctionCEvalGlobalConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(~)
            out='coder.ceval must not specify global option';
        end


        function obj=MatlabFunctionCEvalGlobalConstraint
            obj.setEnum('MatlabFunctionCEvalGlobal');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstCEval'));

            if owner.hasGlobalOption
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end
end