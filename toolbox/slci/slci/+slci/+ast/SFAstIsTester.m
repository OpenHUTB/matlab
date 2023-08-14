







classdef SFAstIsTester<slci.ast.SFAst

    properties

        fFuncName='';
    end

    methods

        function aObj=SFAstIsTester(aAstObj,aFuncName,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstIsTester').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);

            aObj.fFuncName=aFuncName;
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType,...
            message('Slci:slci:ReComputeDataType',class(aObj)));

            aObj.setDataType('boolean');
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim,...
            message('Slci:slci:ReComputeDataDim',class(aObj)));

            aObj.setDataDim([1,1]);
        end


        function out=getFuncName(aObj)
            out=aObj.fFuncName;
        end

    end

    methods(Access=protected)








        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree')&&...
            any(strcmpi(inputObj.kind,{'CALL','LP'})));


            if~isempty(inputObj.Right)
                mtreeNodes=slci.mlutil.getListNodes(inputObj.Right);
                aObj.fChildren=cell(1,numel(mtreeNodes));
                for k=1:numel(mtreeNodes)
                    [isAstNeeded,astObj]=slci.matlab.astTranslator.createAst(...
                    mtreeNodes{k},aObj);
                    assert(isAstNeeded&&~isempty(astObj));
                    aObj.fChildren{1,k}=astObj;
                end
            end
        end

    end

end