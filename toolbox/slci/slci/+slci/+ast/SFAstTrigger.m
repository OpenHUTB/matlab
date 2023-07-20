



classdef SFAstTrigger<slci.ast.SFAst

    methods


        function aObj=SFAstTrigger(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);

        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);

        end

    end

    methods(Access=protected)

        function out=IsEventTrigger(aObj)%#ok
            out=true;
        end

    end

end
