




classdef MatlabFunctionCoderConstConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(~)
            out=['coder.const must contain expression which could be'...
            ,'evaluated to constant value'];
        end


        function obj=MatlabFunctionCoderConstConstraint
            obj.setEnum('MatlabFunctionCoderConst');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(isa(owner,'slci.ast.SFAstCoderConst'));

            if~owner.isConst
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end
end
