




classdef MatlabFunctionCEvalLayoutConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(~)
            out='coder.ceval must not specify layout option';
        end


        function obj=MatlabFunctionCEvalLayoutConstraint
            obj.setEnum('MatlabFunctionCEvalLayout');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstCEval'));

            specifyLayout=~isequal(owner.getLayout,...
            slci.compatibility.CoderCEvalLayoutEnum.Unknown);

            if specifyLayout
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end
end