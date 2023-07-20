






classdef SFAstEnd<slci.ast.SFAst

    methods

        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));
            aObj.fDataType='double';
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim,...
            message('Slci:slci:ReComputeDataDim',class(aObj)));
            aObj.setDataDim([1,1]);
        end


        function aObj=SFAstEnd(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)%#ok
            assert(isa(inputObj,'mtree')&&...
            any(strcmpi(inputObj.kind,{'CALL','LP'})));





            assert(isempty(inputObj.Right));
        end

    end

end
