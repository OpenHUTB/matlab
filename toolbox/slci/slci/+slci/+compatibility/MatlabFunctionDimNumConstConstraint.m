





classdef MatlabFunctionDimNumConstConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Dimension in built-in function must be literal const integer';
        end


        function obj=MatlabFunctionDimNumConstConstraint
            obj.setEnum('MatlabFunctionDimNumConst');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(aObj.isSupportedAstWithDim(owner));

            if owner.hasDimOpnd()

                supported=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(...
                owner.getDimOpnd());
                if~supported

                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum()...
                    );
                end
            end
        end

    end

    methods(Access=private)

        function out=isSupportedAstWithDim(~,ast)
            out=isa(ast,'slci.ast.SFAstProd')...
            ||isa(ast,'slci.ast.SFAstMean')...
            ||isa(ast,'slci.ast.SFAstDotProduct')...
            ||isa(ast,'slci.ast.SFAstCross')...
            ||isa(ast,'slci.ast.SFAstSum')...
            ;
        end
    end

end