







classdef SFAstOrOr<slci.ast.SFAst

    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end


        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end
    end

    methods

        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));
            aObj.fDataType='boolean';
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim,...
            message('Slci:slci:ReComputeDataDim',class(aObj)));

            aObj.fDataDim=[1,1];
        end


        function aObj=SFAstOrOr(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstOrOr').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
