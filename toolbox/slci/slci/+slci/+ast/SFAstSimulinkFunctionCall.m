






classdef SFAstSimulinkFunctionCall<slci.ast.SFAstFunction
    properties(Access=private)
        fSLFcnBlockHandle;
    end

    methods

        function aObj=SFAstSimulinkFunctionCall(aAstObj,aParent,fcnHdl)
            aObj=aObj@slci.ast.SFAstFunction(aAstObj,aParent);
            aObj.fSLFcnBlockHandle=fcnHdl;
        end



        function ComputeDataType(aObj)
            if~aObj.fHasBeenResolvedToSLFcn
                aObj.resolveSLFcnCall;
            end
            assert(~aObj.fComputedDataType);
            retTypes=aObj.fSLFcnInfo.getReturnTypes;
            if numel(retTypes)==1
                aObj.fDataType=retTypes{1};
            else

                aObj.fDataType='void';
            end
        end



        function type=getOutputDataTypeAtIndex(aObj,idx)
            if~aObj.fHasBeenResolvedToSLFcn
                aObj.resolveSLFcnCall;
            end
            type=aObj.fSLFcnInfo.getReturnTypeAt(idx);

        end

    end
    methods(Access=protected)

        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree'));
            assert(any(strcmp(inputObj.kind,{'CALL','SUBSCR'})));
            argNode=inputObj.Right;
            if~isempty(argNode)
                for k=1:count(argNode.List)
                    [isAstNeeded,arg]=slci.matlab.astTranslator.createAst(...
                    argNode,aObj);
                    assert(isAstNeeded&&~isempty(arg));
                    aObj.fChildren{1,k}=arg;
                    argNode=argNode.Next;
                end
            end
        end



        function resolveSLFcnCall(aObj)
            assert(~aObj.fHasBeenResolvedToSLFcn)
            mdl=aObj.ParentModel;
            fcns=mdl.getSimulinkFunctionInfo(aObj.fSLFcnBlockHandle);
            assert(numel(fcns)==1,...
            'Multiple Simulink Function called by AST node');
            aObj.fSLFcnInfo=fcns{1};
            aObj.fHasBeenResolvedToSLFcn=true;
            aObj.fIsSimulinkFunction=true;
        end
    end
end