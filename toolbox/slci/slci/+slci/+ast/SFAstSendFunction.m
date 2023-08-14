






classdef SFAstSendFunction<slci.ast.SFAst


    methods

        function aObj=SFAstSendFunction(aAstObj,aParent)
            aObj@slci.ast.SFAst(aAstObj,aParent);
            astOwner=aObj.getRootAstOwner();

            if strcmpi(aObj.ParentChart.getActionLanguage,'MATLAB')...
                &&isa(aAstObj,'mtree')


            elseif(aAstObj.numInputs==2)

                children=aAstObj.children;
                aChild=children{2};
                if isa(aChild,'Stateflow.Ast.Identifier')
                    destId=aChild.id;
                    if isa(astOwner,'slci.stateflow.Transition')
                        aObj.ParentChart.mapTransToSendFnDest(astOwner.getSfId,destId);
                    elseif isa(astOwner,'slci.stateflow.SFState')
                        aObj.ParentState.mapInputStatesToSendFuncMap(astOwner.getName,aChild.sourceSnippet);
                    end
                end
            end
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end
    end

end
