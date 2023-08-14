



classdef SFAstMatlabFunctionDef<slci.ast.SFAst

    properties
        fName='';
        fNumInputs=0;
        fNumOutputs=0;
        fGlobalSymbols={};

        fInline=slci.compatibility.CoderInlineEnum.Unknown;

        fFid=int32(-1);

        fIsSubFunction=false;
        fPersistentArgs={};

        fIsRecursiveFunc=false;

        fManualReview=false;


        fDroppedOutputs={};


        fDroppedInputs={};
    end

    methods


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end


        function aObj=SFAstMatlabFunctionDef(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            if isa(aAstObj,'mtree')
                assert(strcmpi(aAstObj.Fname.kind,'ID'),...
                'Invalid function node');
                aObj.fName=aAstObj.Fname.string;

                aObj.populateGlobalSymbolsFromMtreeNode(aAstObj);

                aObj.populatePersistentSymbolsFromMtreeNode(aAstObj);

                aObj.setIsSubFunction(aAstObj);
            else
                assert(false,['Invalid Ast node',class(aAstObj)]);
            end

        end


        function name=getName(aObj)
            name=aObj.fName;
        end


        function inputArgs=getInputs(aObj)
            assert(numel(aObj.fChildren)>=aObj.fNumInputs,...
            'Invalid MATLAB Function Ast');

            inputArgs=cell(1,aObj.fNumInputs);
            for k=1:aObj.fNumInputs
                inputArgs{1,k}=aObj.fChildren{1,k};
            end
        end


        function outputArgs=getOutputs(aObj)

            assert(numel(aObj.fChildren)>=...
            aObj.fNumInputs+aObj.fNumOutputs,...
            'Invalid MATLAB Function Ast');

            outputArgs=cell(1,aObj.fNumOutputs);

            p=1;
            for k=aObj.fNumInputs+1:aObj.fNumInputs+aObj.fNumOutputs
                outputArgs{1,p}=aObj.fChildren{1,k};
                p=p+1;
            end
        end


        function out=getNumOutputs(aObj)
            out=aObj.fNumOutputs;
        end


        function globalArgs=getGlobalSymbols(aObj)
            globalArgs=aObj.fGlobalSymbols;
        end


        function body=getBody(aObj)
            numArgs=aObj.fNumInputs+aObj.fNumOutputs;

            numBodyStmts=numel(aObj.fChildren)-numArgs;
            body=cell(1,numBodyStmts);
            p=1;
            for k=numArgs+1:numel(aObj.fChildren)
                body{1,p}=aObj.fChildren{1,k};
                p=p+1;
            end
        end


        function setInline(aObj,flag)
            assert(isa(flag,'slci.compatibility.CoderInlineEnum'));
            aObj.fInline=flag;
        end


        function flag=getInline(aObj)
            flag=aObj.fInline;
        end


        function setFunctionID(aObj,fid)
            aObj.fFid=int32(fid);
        end


        function fid=getFunctionID(aObj)
            fid=aObj.fFid;
        end


        function flag=IsSubFunction(aObj)
            flag=aObj.fIsSubFunction;
        end


        function asts=getPersistentArgs(aObj)
            asts=aObj.fPersistentArgs;
        end


        function setIsRecursiveFunc(aObj,flag)
            aObj.fIsRecursiveFunc=flag;
        end


        function out=getIsRecursiveFunc(aObj)
            out=aObj.fIsRecursiveFunc;
        end


        function setManualReview(aObj,flag)
            aObj.fManualReview=flag;
        end


        function flag=getManualReview(aObj)
            flag=aObj.fManualReview;
        end


        function setDroppedOutputs(aObj,droppedOutputs)
            aObj.fDroppedOutputs=droppedOutputs;
        end


        function setDroppedInputs(aObj,droppedInputs)
            aObj.fDroppedInputs=droppedInputs;
        end


        function droppedOutputs=getDroppedOutputs(obj)
            droppedOutputs=obj.fDroppedOutputs;
        end


        function droppedInputs=getDroppedInputs(obj)
            droppedInputs=obj.fDroppedInputs;
        end
    end

    methods(Access=protected)

        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree')&&...
            strcmpi(inputObj.kind,'FUNCTION'));

            inputArgs=aObj.getInputsFromMtreeNode(inputObj);
            aObj.fNumInputs=numel(inputArgs);

            outputArgs=aObj.getOutputsFromMtreeNode(inputObj);
            aObj.fNumOutputs=numel(outputArgs);

            bodyStmts=aObj.getBodyFromMtreeNode(inputObj);
            aObj.fChildren=[inputArgs,outputArgs,bodyStmts];
        end

    end

    methods(Access=private)


        function bodyStmts=getBodyFromMtreeNode(aObj,aAstObj)
            bodyStmts={};
            if~isempty(aAstObj.Body)
                children=slci.mlutil.getListNodes(aAstObj.Body);
                bodyStmts=cell(1,numel(children));
                for k=1:numel(children)
                    child=children{k};
                    [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(child,aObj);
                    if isAstNeeded
                        assert(~isempty(cObj));
                        bodyStmts{k}=cObj;
                    end
                end
                bodyStmts(cellfun(@isempty,bodyStmts))=[];
            end
        end


        function inputs=getInputsFromMtreeNode(aObj,aAstObj)
            inputs={};
            if~isempty(aAstObj.Ins)
                inArgs=list(aAstObj.Ins);
                ind=inArgs.indices;
                inputs=cell(1,numel(ind));
                for k=1:numel(ind)
                    node=select(inArgs,ind(k));
                    if strcmp(node.kind,'ID')&&...
                        strcmp(node.string,'varargin')
                        astObj=slci.ast.SFAstVarargin(...
                        node,aObj);
                    else
                        [isAstNeeded,astObj]=slci.matlab.astTranslator.createAst(...
                        node,aObj);
                        assert(isAstNeeded&&~isempty(astObj));
                    end
                    inputs{k}=astObj;
                end
            end
        end


        function outputs=getOutputsFromMtreeNode(aObj,aAstObj)
            outputs={};
            if~isempty(aAstObj.Outs)
                outArgs=list(aAstObj.Outs);
                ind=outArgs.indices;
                outputs=cell(1,numel(ind));
                for k=1:numel(ind)
                    node=select(outArgs,ind(k));
                    if strcmp(node.kind,'ID')&&...
                        strcmp(node.string,'varargout')
                        astObj=slci.ast.SFAstVarargout(...
                        node,aObj);
                    else
                        [isAstNeeded,astObj]=slci.matlab.astTranslator.createAst(...
                        node,aObj);
                        assert(isAstNeeded&&~isempty(astObj));
                    end
                    outputs{k}=astObj;
                end
            end
        end


        function populateGlobalSymbolsFromMtreeNode(aObj,aAstObj)
            assert(isa(aAstObj,'mtree'));
            globalDecls=mtfind(List(aAstObj.Body),'Kind','GLOBAL');
            if~isempty(globalDecls)
                indices=globalDecls.indices;
                numGlobals=numel(indices);
                for i=1:numGlobals
                    index=indices(i);
                    globalDecl=globalDecls.select(index);
                    if~isempty(globalDecl.Arg)
                        symbolNodes=slci.mlutil.getListNodes(...
                        globalDecl.Arg);
                        symbolNames=cellfun(@string,symbolNodes,...
                        'UniformOutput',false);
                        aObj.fGlobalSymbols=[aObj.fGlobalSymbols;...
                        symbolNames'];
                    end
                end
            end
        end


        function populatePersistentSymbolsFromMtreeNode(aObj,aAstObj)
            assert(isa(aAstObj,'mtree'));
            persistentDecls=mtfind(List(aAstObj.Body),'Kind','PERSISTENT');
            if~isempty(persistentDecls)
                indices=persistentDecls.indices;
                numPersistents=numel(indices);
                for i=1:numPersistents
                    index=indices(i);
                    globalPersistent=persistentDecls.select(index);
                    if~isempty(globalPersistent.Arg)
                        symbolNodes=slci.mlutil.getListNodes(...
                        globalPersistent.Arg);


                        for j=1:numel(symbolNodes)
                            [isAstNeeded,astObj]=...
                            slci.matlab.astTranslator.createAst(...
                            symbolNodes{j},aObj);
                            assert(isAstNeeded);
                            assert(isa(astObj,...
                            'slci.ast.SFAstIdentifier'));
                            aObj.fPersistentArgs{end+1}=astObj;
                        end
                    end
                end
            end
        end


        function setIsSubFunction(aObj,mNode)
            assert(strcmpi(mNode.kind,'FUNCTION'));
            rootNode=aObj.getRootFunctionNode(mNode);
            assert(strcmpi(rootNode.kind,'FUNCTION'));
            if mNode~=rootNode
                aObj.fIsSubFunction=true;
            end

        end


        function rootNode=getRootFunctionNode(~,mNode)
            assert(strcmpi(mNode.kind,'FUNCTION'));
            rootNode=mNode.root;
            while~strcmpi(rootNode.kind,'FUNCTION')
                rootNode=rootNode.Next;
            end
        end

    end

    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)


            if isa(aObj.getRootAstOwner.ParentChart,'slci.stateflow.Chart')...
                &&strcmpi(aObj.getRootAstOwner.ParentChart.getActionLanguage,'MATLAB')
                return;
            end
            newConstraints={...
            slci.compatibility.MatlabFunctionInlineDirectiveConstraint,...
            slci.compatibility.MLFuncDefNonInlinedGlobalVarConstraint,...
            slci.compatibility.MatlabFunctionRecursiveFunctionConstraint,...
            slci.compatibility.MatlabFunctionInnerFunctionConstraint,...
            };

            aObj.setConstraints(newConstraints);
        end

    end

end
