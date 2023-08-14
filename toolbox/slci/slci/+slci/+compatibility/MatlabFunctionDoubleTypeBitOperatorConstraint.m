





classdef MatlabFunctionDoubleTypeBitOperatorConstraint<slci.compatibility.Constraint
    properties(Access=protected)
        fSupportedTypes={};
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Double type Matlab bit operators must specify ASSUMPEDTYPE';
        end


        function obj=MatlabFunctionDoubleTypeBitOperatorConstraint
            obj.setEnum('MatlabFunctionDoubleTypeBitOperator');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            assert(aObj.isBitOpAst(owner));
            if strcmpi(owner.getDataType(),'double')
                assumpedType=owner.getTypeName();
                if isempty(assumpedType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum());
                end
            end
        end
    end

    methods(Access=private)

        function out=isBitOpAst(~,ast)
            out=isa(ast,'slci.ast.SFAstBitAnd')...
            ||isa(ast,'slci.ast.SFAstBitOr')...
            ||isa(ast,'slci.ast.SFAstBitXor')...
            ||isa(ast,'slci.ast.SFAstBitCmp')...
            ||isa(ast,'slci.ast.SFAstBitShift')...
            ||isa(ast,'slci.ast.SFAstBitGet')...
            ||isa(ast,'slci.ast.SFAstBitSet');
        end
    end

end