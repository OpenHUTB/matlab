



classdef SFAstUnsupported<slci.ast.SFAst

    properties(Access=protected)

        fType='';
    end

    methods

        function aObj=SFAstUnsupported(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);

            try
                aObj.fType=aAstObj.Left.String;
            catch ME
                aObj.fType='Unknown operation';
            end
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
        end

        function out=IsUnsupportedAst(aObj)%#ok
            out=true;
        end


        function out=getType(aObj)
            out=aObj.fType;
        end
    end

    methods(Access=protected)

        function populateChildrenFromMtreeNode(~,~)


        end

    end


end
