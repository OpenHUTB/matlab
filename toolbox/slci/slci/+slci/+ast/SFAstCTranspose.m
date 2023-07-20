






classdef SFAstCTranspose<slci.ast.SFAst

    methods(Access=protected)

        function out=supportsEnumOperation(aObj)%#ok
            out=false;
        end
    end

    methods

        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.fDataType=aObj.ResolveDataType();
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim,...
            message('Slci:slci:ReComputeDataDim',class(aObj)));

            childDim=aObj.ResolveDataDim();

            if childDim~=-1
                assert(numel(childDim)==2||childDim==1);
                if numel(childDim)==2
                    aObj.fDataDim=[childDim(2),childDim(1)];
                else
                    aObj.fDataDim=[1,childDim(1)];
                end
            end
        end


        function aObj=SFAstCTranspose(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstCTranspose').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
