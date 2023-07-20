



classdef SFAstRoot<slci.ast.SFAst

    methods


        function aObj=SFAstRoot(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();
            for i=1:numel(children)
                aObj.fDataType=children{i}.getDataType();
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
        end

    end

    methods(Access=protected)


        function out=IsExecutable(aObj)%#ok
            out=false;
        end


        function addConstraints(aObj)%#ok<MANU>

        end

    end

end


