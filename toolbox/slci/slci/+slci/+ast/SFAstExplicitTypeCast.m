


classdef SFAstExplicitTypeCast<slci.ast.SFAst

    methods

        function aObj=SFAstExplicitTypeCast(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            scan=textscan(aAstObj.sourceSnippet,'%s','Delimiter','(');
            aObj.fDataType=scan{1}{1};
            aObj.fComputedDataType=true;
        end


        function ComputeDataDim(aObj)
            children=aObj.getChildren();

            if~isempty(children)
                aObj.fDataDim=aObj.ResolveDataDim();
            end
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

end
