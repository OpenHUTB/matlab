



classdef SFAstColonAssignment<slci.ast.SFAst

    methods

        function ComputeDataType(aObj)
            children=aObj.getChildren();

            aObj.fDataType=children{1}.getDataType();
        end

        function ComputeDataDim(aObj)
            children=aObj.getChildren();

            aObj.fDataDim=children{1}.getDataDim();
        end

        function aObj=SFAstColonAssignment(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

end
