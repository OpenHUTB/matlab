


classdef SFAstTypeObject<slci.ast.SFAst

    methods

        function aObj=SFAstTypeObject(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            scan=textscan(aAstObj.sourceSnippet,'%s','Delimiter','(');
            children=aObj.getChildren();

            if isempty(children)
                aObj.fDataType=scan{1}{1};
            end
        end

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();

            if~isempty(children)
                aObj.fDataType=children{1}.getDataType();
            end
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();

            if~isempty(children)
                aObj.fDataDim=children{1}.getDataDim();
            end
        end

    end

    methods(Access=protected)


        function out=IsExecutable(aObj)%#ok
            out=false;
        end

    end

end
