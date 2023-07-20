








classdef SFAstLC<slci.ast.SFAst
    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

    end

    methods

        function ComputeDataType(aObj)%#ok


        end


        function ComputeDataDim(aObj)%#ok


        end


        function aObj=SFAstLC(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstLC').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)%#ok

        end



        function addMatlabFunctionConstraints(aObj)
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end
