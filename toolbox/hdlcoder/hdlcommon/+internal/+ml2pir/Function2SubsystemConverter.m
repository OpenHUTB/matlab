



classdef Function2SubsystemConverter<coder.internal.MTreeVisitor&internal.mtree.ControlFlowManager
    properties(Access='protected')
FcnInfoRegistry
ExprMap
FcnTypeInfo
GraphBuilder
CurrScope
BlockNames
PersistentVars
PersistentVarsInitialValues
EndValue
        UserComment='';
        IsUserCommentTopLvl=false;
        CallerMapKey='';






FcnMap

ConversionSettings
    end

    properties(Hidden)
Debug
PrintMessages
    end
    methods
        function this=Function2SubsystemConverter(fcnInfoRegistry,exprMap,fcnInfo,builder,conversionSettings)
            if nargin<5
                conversionSettings=internal.ml2pir.Function2SubsystemConverter.getConversionSettings();
            end

            this.FcnInfoRegistry=fcnInfoRegistry;
            this.ExprMap=exprMap;
            this.FcnTypeInfo=fcnInfo;
            this.GraphBuilder=builder;
            this.CurrScope=internal.ml2pir.scope.ScopeTail;
            this.BlockNames=containers.Map();
            this.PersistentVars=containers.Map();
            this.PersistentVarsInitialValues=containers.Map();
            this.EndValue=[];
            this.FcnMap=containers.Map();

            this.ConversionSettings=conversionSettings;


            this.Debug=true;
            this.PrintMessages=false;
        end

        function subsys=run(this,graphName)
            try
                this.GraphBuilder.createGraph(graphName);
                subsys=this.convertFunction();
                this.GraphBuilder.endSubGraph();

                numIns=numel(this.FcnTypeInfo.inputVarNames);
                inTypes=repmat(internal.mtree.type.UnknownType,1,numIns);
                ins=this.FcnTypeInfo.tree.Ins;
                for i=1:numIns
                    this.assert(~isempty(ins),'cannot get type information of input variable');

                    inTypes(i)=this.getType(ins);
                    ins.Next;
                end

                numOuts=numel(this.FcnTypeInfo.outputVarNames);
                outTypes=repmat(internal.mtree.type.UnknownType,1,numOuts);
                outs=this.FcnTypeInfo.tree.Outs;
                for j=1:numOuts
                    this.assert(~isempty(outs),'cannot get type information of output variable');

                    outTypes(j)=this.getType(outs);
                    outs.Next;
                end


                this.GraphBuilder.createIO(subsys,this.FcnTypeInfo.inputVarNames,inTypes,...
                this.FcnTypeInfo.outputVarNames,outTypes);

                this.GraphBuilder.finalize();
            catch ex


                internal.mtree.utils.errorWithContext(ex,...
                'Dataflow conversion error: ',...
                fullfile('+internal','+ml2pir'))
            end
        end

        function pNodes=getPersistentNodes(this)
            pNodeCell=this.PersistentVars.values;



            pNodeDelaysCell=pNodeCell(cellfun(@(x)isa(x,'hdlcoder.integerdelay_comp'),pNodeCell));
            pNodes=cell2mat(pNodeDelaysCell);
        end
    end

    methods(Access='protected')

        function subsys=convertFunction(this)
            this.beginScope();
            fcnNode=this.FcnTypeInfo.tree;
            this.visit(fcnNode,[]);
            this.endScope();

            subsys=this.GraphBuilder.getCurrentSubGraphNode;
        end

        function scope=beginScope(this)
            scope=internal.ml2pir.scope.Scope(this.CurrScope,this.GraphBuilder);
            this.CurrScope=scope;
        end

        function endScope(this)
            this.CurrScope=this.CurrScope.Parent;
        end


        function setNode(this,name,node,nodeType)
            this.CurrScope.setNode(name,node,nodeType);
        end

        function[node,type]=getNode(this,name)
            [node,tp]=this.CurrScope.getNode(name);

            if nargout>1
                type=tp;
            end
        end

        function finalDescription=getNodeDescription(this,node,kind,isaConstant)



            if nargin<4

                isaConstant=false;
            end

            if nargin<3
                kind='';
            end

            finalDescription=struct(...
            'comments','',...
            'file','',...
            'line',num2str(node.lineno),...
            'col',num2str(node.charno));

            comments='';
            if this.GraphBuilder.generateUserComments





                comments=this.getUserComment(isaConstant);
            end
            if this.GraphBuilder.generateSourceCodeComments



                description=strtrim(node.tree2str(0,1));
                switch kind
                case ''


                case 'SUBSCR'


                    description=[description,' = ...'];
                case 'CALL'
                    fcnName=strtrim(node.Left.tree2str(0,1));
                    if strcmp(fcnName,'reinterpretcast')
                        description=[description,' : '];
                    end
                case 'CASE'
                    description=['case ',description];
                case 'OTHERWISE'
                    description='otherwise';
                case 'IFHEAD'
                    description=['if ',description];
                case 'ELSEIF'
                    description=['elseif ',description];
                case 'ELSE'
                    description='else';
                end
                if~isempty(description)
                    if~isempty(comments)
                        comments=[comments,newline];
                    end
                    comments=[comments,description];
                end
            end
            if this.GraphBuilder.generateTraceability

                description=this.GraphBuilder.getNodeTraceability(node);
                if~isempty(description)
                    if~isempty(comments)
                        comments=[comments,newline];
                    end
                    comments=[comments,description];
                end
            end
            finalDescription.comments=comments;


            if isfile(this.FcnTypeInfo.scriptPath)
                finalDescription.file=this.FcnTypeInfo.scriptPath;
            end
            finalDescription.line=num2str(node.lineno);
            finalDescription.col=num2str(node.charno);
        end

        function key=getFcnMapKey(this,typeInfo,constantInputs)
            constInputStr=cell(1,numel(constantInputs)/2);

            for ii=1:2:numel(constantInputs)
                idxStr=constantInputs{ii};
                const=constantInputs{ii+1};

                this.assert(isa(const,'internal.mtree.Constant'),...
                'Function constant input is not of type internal.mtree.Constant')

                constInputStr{(ii+1)/2}=[idxStr,':',this.GraphBuilder.toString(const)];
            end

            key=[typeInfo.uniqueId,'_',strjoin(constInputStr,'_')];
        end

        function node=getNodeForInput(this,inpName,desc,nodeDescription)




            outType=desc.type;
            typeInfo=internal.mtree.NodeTypeInfo([],outType);

            if desc.isConst

                node=internal.mtree.Constant(nodeDescription,desc.constVal,inpName);
            elseif desc.isTunableConst

                node=this.GraphBuilder.createTunableConstantNode(...
                nodeDescription,typeInfo,inpName);
            elseif desc.isListDesc




                vdlNodes=cell(desc.getDimensions);


                for ii=1:desc.getLength
                    varDesc=desc.getVarDesc(ii);
                    argName=[inpName,'_',num2str(ii)];

                    vdlNodes{ii}=this.getNodeForInput(argName,varDesc,'');
                end
                node=vdlNodes;
            else

                node=this.GraphBuilder.addInput(inpName,typeInfo);
            end

        end
    end

    methods
        function out=visitFUNCTION(this,fcnNode,in)
            out=[];


            ins=fcnNode.Ins;
            while~isempty(ins)
                inpName=string(ins);
                [~,~,desc]=this.evalExpression(ins);


                inpNode=this.getNodeForInput(inpName,desc,this.getNodeDescription(ins));


                this.setNode(inpName,inpNode,desc.type);

                ins=ins.Next;
            end

            this.visitNodeList(fcnNode.Body,in);


            outs=fcnNode.Outs;
            while~isempty(outs)
                outName=string(outs);

                outSrcNode=this.getNode(outName);

                inType=this.getType(outs);
                if inType.isUnknown


                    outs=outs.Next;
                    continue;
                end
                typeInfo=internal.mtree.NodeTypeInfo(inType,[]);
                outNode=this.GraphBuilder.addOutput(outName,typeInfo);

                this.GraphBuilder.connect(outSrcNode,outNode);

                outs=outs.Next;
            end


            pVars=this.PersistentVars.keys();
            for ii=1:numel(pVars)
                pDelay=this.PersistentVars(pVars{ii});
                if~isempty(pDelay)


                    valueOnExit=this.getNode(pVars{ii});

                    if this.PersistentVarsInitialValues.isKey(pVars{ii})
                        initialValue=this.PersistentVarsInitialValues(pVars{ii});

                        this.assert(isa(initialValue,'internal.mtree.Constant'),'initialValue must be a internal.mtree.Constant.')
                        this.GraphBuilder.setInitialValue(pDelay,initialValue.Value);
                    end

                    this.GraphBuilder.connect(valueOnExit,pDelay);
                end
            end
        end

        function out=visitPERSISTENT(this,node,~)
            out=[];
            pVar=node.Arg;

            while~isempty(pVar)
                name=string(pVar);

                type=this.getType(pVar);
                if type.isSystemObject




                    pVarBlock=[];
                elseif type.isUnknown


                    pVarBlock=[];
                else

                    nodeTypeInfo=internal.mtree.NodeTypeInfo(type,type);
                    pVarBlock=this.GraphBuilder.createUnitDelayNode(this.getNodeDescription(node),nodeTypeInfo);
                end
                this.PersistentVars(name)=pVarBlock;
                this.setNode(name,pVarBlock,type);

                pVar=pVar.Next;
            end
        end

        function graphNode=visitSUBSCR(this,node,in)
            lhsNode=node.Left;
            lhsType=this.getType(lhsNode);
            if lhsType.isFunctionHandle||internal.mtree.isFunctionCallNode(node,this.FcnTypeInfo)



                graphNode=visitCALL(this,node,in);
                return;
            end



            [graphNode,isPragma]=this.visitPragma(node,in);
            if isPragma
                return;
            end


            matrix=this.visit(lhsNode,in);

            [indexArray,nonConstIdxTypes,nonConstIdxNodes,isLinearIndexing]=...
            this.getIndexInfoFromSubscrNode(node,lhsType,in);

            if any(cellfun(@(x)~isempty(x)&&isa(x,'internal.mtree.Constant')&&isempty(x.Value),indexArray))



                graphNode=[];
                return;
            end


            [matrix,lhsType]=this.reshapeSubscriptedMatrix(node,matrix,lhsType,isLinearIndexing);

            selectedType=this.getType(node);
            origSelectedType=selectedType;

            [nonConstIdxNodes,indexArray,nonConstIdxTypes,selectedType]=this.reshapeSubscrIndexing(...
            nonConstIdxNodes,indexArray,nonConstIdxTypes,selectedType,isLinearIndexing);

            typeInfo=internal.mtree.NodeTypeInfo(...
            [lhsType,nonConstIdxTypes],selectedType);

            if isLinearIndexing&&isempty(indexArray{1})


                graphNode=this.GraphBuilder.createReshapeNode(...
                this.getNodeDescription(node),typeInfo);
                this.GraphBuilder.connect(matrix,{graphNode,1});
            else

                graphNode=this.GraphBuilder.createSubscrNode(...
                this.getNodeDescription(node),typeInfo,indexArray,this.isNodeConditional(node));
                this.GraphBuilder.connect(matrix,{graphNode,1});



                for ii=1:numel(nonConstIdxNodes)
                    portIdx=ii+1;
                    this.GraphBuilder.connect(nonConstIdxNodes{ii},{graphNode,portIdx});
                end



                graphNode=this.reshapeToType(graphNode,node,selectedType,origSelectedType);
            end
        end

        function graphNode=visitCELL(this,node,in)
            lhsNode=node.Left;


            matrix=this.visit(lhsNode,in);
            assert(iscell(matrix),'Visiting a cell array ID did not return a cell array of PIR nodes');


            numIndices=count(node.Right.List);
            idx=node.Right;
            idxConstVals=cell(1,numIndices);
            for ii=1:numIndices
                [idxIsConst,idxConstVal,~]=this.evalExpression(idx);
                assert(idxIsConst,'Non-constant indices to CELL nodes are not supported');
                idxConstVals{ii}=idxConstVal;
                idx=idx.Next;
            end

            graphNode=matrix(idxConstVals{:});
            if numel(graphNode)==1
                graphNode=graphNode{1};
            end
        end

        function[graphNode,isPragma]=visitPragma(this,node,in)
            graphNode=[];
            isPragma=false;

            if~internal.mtree.isPragma(node)
                return;
            end

            if strcmp(node.kind,'SUBSCR')
                subscrStr=node.Left.tree2str(0,1);
                hasArgs=~isempty(node.Right);
            else
                assert(strcmp(node.kind,'DOT'));
                subscrStr=node.tree2str(0,1);
                hasArgs=false;
            end

            switch subscrStr
            case{'coder.nullcopy','eml.nullcopy'}

                assert(hasArgs,'coder.nullcopy with no args');
                graphNode=this.visit(node.Right,in);
                isPragma=true;

            case 'coder.hdl.pipeline'
                assert(hasArgs,'coder.hdl.pipeline with no args');

                expr=this.visit(node.Right,in);


                if~isnull(node.Right.Next)
                    [isConst,d]=this.evalExpression(node.Right.Next);
                    this.assert(isConst,'Number of pipeline registers in ''coder.hdl.pipeline'', must be a constant');
                else
                    d=1;
                end

                type=this.getType(node.Right);
                nodeTypeInfo=internal.mtree.NodeTypeInfo(type,type);
                graphNode=this.GraphBuilder.createDelayNode(this.getNodeDescription(node),...
                nodeTypeInfo,'cyan',d);
                this.GraphBuilder.connect(expr,graphNode);

                isPragma=true;

            case 'coder.hdl.loopspec'
                assert(hasArgs,'coder.hdl.loopspec with no args');

                streamLoop=false;
                if~isnull(node.Right)
                    [isConst,streamStr]=this.evalExpression(node.Right);
                    streamLoop=strcmp(streamStr,'stream');
                    assert(isConst);
                end

                streamingFactor=[];
                if~isnull(node.Right.Next)
                    [isConst,streamingFactor]=this.evalExpression(node.Right.Next);
                    assert(isConst);
                end

                this.setLoopStreamingIfNextNodeIsFor(node,streamLoop,streamingFactor);

                graphNode=[];
                isPragma=true;

            case{'coder.inline','eml.inline'}
                assert(hasArgs,'coder.inline with no args');
                [isConst,inlineOptStr]=this.evalExpression(node.Right);
                assert(isConst);

                this.GraphBuilder.processInliningForCurrentFunction(inlineOptStr)

                graphNode=[];
                isPragma=true;

            case 'coder.internal.assert'

                assert(hasArgs,'coder.internal.assert with no args');

                graphNode=[];
                isPragma=true;
            case 'hdl.npufun'
                assert(hasArgs,'hdl.npufun with no args');



                useAggregate=false;
                npuInfo=internal.mtree.utils.npufun.Info(...
                node,this.FcnTypeInfo,this.FcnInfoRegistry,useAggregate);

                argNodes=node.Right.List;
                argNodeIdxs=indices(argNodes);


                numArgs=numel(npuInfo.KernelArgIdxs);


                nonConstInputs=cell(1,numArgs);
                constantInputs=cell(1,numArgs*2);
                nonConstIdx=1;
                constIdx=1;
                nonConstInputDescs=cell(1,numArgs);


                for ii=1:numArgs
                    argNode=argNodes.select(argNodeIdxs(npuInfo.KernelArgIdxs(ii)));
                    argGraphNode=this.visit(argNode,in);
                    if isa(argGraphNode,'internal.mtree.Constant')
                        constantInputs{constIdx}=int2str(ii);
                        constantInputs{constIdx+1}=argGraphNode;
                        constIdx=constIdx+2;


                        idxsToReduce=find(npuInfo.GraphStreamedIdxs>ii);
                        npuInfo.GraphStreamedIdxs(idxsToReduce)=npuInfo.GraphStreamedIdxs(idxsToReduce)-1;
                    else
                        nonConstInputs{nonConstIdx}=argGraphNode;
                        nonConstInputDescs{nonConstIdx}=internal.mtree.getVarDesc(argNode,this.FcnTypeInfo);
                        nonConstIdx=nonConstIdx+1;
                    end
                end

                constantInputs(constIdx:end)=[];
                nonConstInputs(nonConstIdx:end)=[];
                nonConstInputDescs(nonConstIdx:end)=[];

                graphNode=this.elaborateUserFunction(node,...
                npuInfo.CalleeFcnInfo,nonConstInputs,constantInputs,npuInfo,nonConstInputDescs);
                isPragma=true;
            case 'hdl.iteratorfun'
                assert(hasArgs,'hdl.iteratorfun with no args');
                graphNode=this.handleIteratorFun(node,in);
                isPragma=true;
            case{'hdl.treesum','hdl.treeprod'}
                arg=node.Right;
                left=this.visit(arg,in);

                dimension=-1;
                optArg=arg.Next;
                hasDimArg=false;
                if~isempty(optArg)
                    [isConst,optVal]=this.evalExpression(optArg);
                    this.assert(isConst,'Optional argument to hdl.treesum/hdl.treeprod does not evaluate to a constant.');
                    if isnumeric(optVal)


                        dimension=optVal;
                        hasDimArg=true;
                    elseif ischar(optVal)&&strcmpi(optVal,'all')

                        hasDimArg=true;
                    end
                end

                if~hasDimArg&&this.getType(arg).isMatrix

                    dimension=1;
                end



                x=node.Right;
                ii=1;
                inTypes=repmat(internal.mtree.type.UnknownType,1,count(x.List));
                while~isempty(x)
                    inTypes(ii)=this.getType(x);
                    x=x.Next;
                    ii=ii+1;
                end

                nodeTypeInfo=internal.mtree.NodeTypeInfo(inTypes,this.getType(node));
                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);

                if nodeTypeInfo.Ins.isScalar
                    graphNode=this.GraphBuilder.createNoopNode(...
                    this.getNodeDescription(node),nodeTypeInfo);
                elseif strcmp(subscrStr,'hdl.treesum')
                    graphNode=this.GraphBuilder.createTreeSumNode(...
                    this.getNodeDescription(node),nodeTypeInfo,dimension);
                else
                    graphNode=this.GraphBuilder.createTreeProdNode(...
                    this.getNodeDescription(node),nodeTypeInfo,dimension);
                end
                this.GraphBuilder.connect(left,graphNode);

                isPragma=true;

            case{'hdl.internal.tablelookupND'}

                tableDataNode=node.Right;
                [~,tableData]=this.evalExpression(tableDataNode);


                if isvector(tableData)
                    dims=1;
                else
                    dims=ndims(tableData);
                end

                bpData=cell(1,dims);
                tempNode=tableDataNode;
                for i=1:dims

                    tempNode=tempNode.Next;

                    [~,bpData{i}]=this.evalExpression(tempNode);
                end

                dataNodes=cell(1,dims);
                dataNodeType=internal.mtree.type.Double(dims,0);
                for i=1:dims

                    tempNode=tempNode.Next;
                    dataNodes{i}=tempNode;
                    dataNodeType(i)=this.getType(tempNode);
                end

                nodeTypeInfo=internal.mtree.NodeTypeInfo(dataNodeType,this.getType(node));


                tempNode=tempNode.Next;
                [~,interp]=this.evalExpression(tempNode);
                if(strcmp(interp,'linear'))
                    interpVal=1;
                else
                    interpVal=0;
                end


                tempNode=tempNode.Next;
                [~,extrap]=this.evalExpression(tempNode);



                graphNode=this.GraphBuilder.createTableLookupNDNode(...
                this.getNodeDescription(node),nodeTypeInfo,dimension=dims,...
                tableData=tableData,breakPointData=bpData,interpolation=interpVal,extrapolation=extrap);


                for i=1:dims
                    leftNode=this.visit(dataNodes{i},in);
                    this.GraphBuilder.connect(leftNode,{graphNode,i});
                end

                isPragma=true;

            otherwise

                if endsWith(subscrStr,'.unroll')


                    if hasArgs
                        graphNode=this.visit(node.Right,in);
                    else
                        graphNode=[];
                    end
                    isPragma=true;

                elseif startsWith(subscrStr,'coder.')||startsWith(subscrStr,'eml.')


                    graphNode=[];
                    isPragma=true;
                end
            end
        end

        function graphNode=visitLHSSUBSCR(this,node,in,rhsGraphNode,rhsNodeType)
            matrixType=this.getType(node.Left);

            if strcmp(node.Left.kind,'DOT')
                matrix=this.recurseIntoDotExpression(node.Left,in);
            else
                matrix=this.getNode(node.Left.string);
            end

            [indexArray,nonConstIdxTypes,nonConstIdxNodes,isLinearIndexing]=...
            this.getIndexInfoFromSubscrNode(node,matrixType,in);





            if isLinearIndexing
                if isempty(indexArray{1})


                    isDTCIndexing=true;
                elseif isa(indexArray{1},'internal.mtree.Constant')


                    allElemsInOrderIdx=double(1:prod(matrixType.Dimensions));

                    isDTCIndexing=isequal(double(indexArray{1}.Value),allElemsInOrderIdx);
                else

                    isDTCIndexing=false;
                end

                if isDTCIndexing

                    graphNode=rhsGraphNode;
                    return
                end
            end



            origMatrixType=matrixType;
            [matrix,matrixType]=this.reshapeSubscriptedMatrix(...
            node,matrix,matrixType,isLinearIndexing);


            selectedType=this.getType(node);
            [nonConstIdxNodes,indexArray,nonConstIdxTypes,~]=this.reshapeSubscrIndexing(...
            nonConstIdxNodes,indexArray,nonConstIdxTypes,selectedType,isLinearIndexing);

            typeInfo=internal.mtree.NodeTypeInfo(...
            [matrixType,rhsNodeType,nonConstIdxTypes],matrixType);

            graphNode=this.GraphBuilder.createSubassignNode(...
            this.getNodeDescription(node,node.kind),typeInfo,indexArray,this.isNodeConditional(node));

            this.GraphBuilder.connect(matrix,{graphNode,1});
            this.GraphBuilder.connect(rhsGraphNode,{graphNode,2});



            portIdx=3;
            for i=1:numel(nonConstIdxNodes)
                this.GraphBuilder.connect(nonConstIdxNodes{i},{graphNode,portIdx});
                portIdx=portIdx+1;
            end



            graphNode=this.reshapeToType(graphNode,node.Left,matrixType,origMatrixType);


            if strcmp(node.Left.kind,'DOT')
                graphNode=this.visitLHSDOT(node.Left,graphNode,rhsNodeType,in);
            end
        end

        function out=visitEQUALS(this,assignNode,in)
            out=[];
            lhs=assignNode.Left;
            rhs=assignNode.Right;

            rhsGraphNode=this.visit(rhs,in);

            if strcmp(lhs.kind,'LB')
                lhs=lhs.Arg;
                lhsNodes=cell(1,count(lhs.List));
                idx=1;

                while~isempty(lhs)
                    lhsNodes{idx}=lhs;
                    lhs=lhs.Next;
                    idx=idx+1;
                end
            else
                lhsNodes={lhs};
            end





            rhsReturnsMultiOut=iscell(rhsGraphNode)&&~isnumeric(rhsGraphNode{2});
            if numel(lhsNodes)==1&&~rhsReturnsMultiOut



                rhsGraphNode={rhsGraphNode};
            end

            for ii=1:numel(lhsNodes)
                lhs=lhsNodes{ii};
                this.visitSingleLhsNode(lhs,ii,rhs,rhsGraphNode{ii},in);
            end
        end

        function visitSingleLhsNode(this,lhs,lhsNum,rhs,rhsGraphNode,in)
            if strcmp(lhs.kind,'NOT')

                return
            end

            leftmostNode=lhs;
            while~strcmp(leftmostNode.kind,'ID')
                this.assert(ismember(leftmostNode.kind,{'SUBSCR','CELL','DOT','DOTLP'}),...
                ['unexpected LHS kind found: ',leftmostNode.kind]);
                leftmostNode=leftmostNode.Left;
            end

            lhsName=leftmostNode.string;
            lhsType=this.getType(leftmostNode);

            [isConst,leftmostVarVal]=this.evalExpression(leftmostNode);

            if isConst

                constGraphNode=this.createConstant(leftmostNode,leftmostVarVal);
                this.setNode(lhsName,constGraphNode,lhsType);
            else






                rhsType=this.getType(rhs,lhsNum).copy;
                if prod(rhsType.Dimensions)~=1


                    rhsType.setDimensions(this.getType(lhs).Dimensions);
                end


                if lhsType.isStructType()||lhsType.isSystemObject
                    lhsType=this.getType(lhs);
                end

                [rhsType,rhsGraphNode,lhsNum]=this.resolveTypesForAssignment(rhsType,lhsType,rhsGraphNode,leftmostNode,lhsNum);

                if lhsNum>1&&~isa(rhsGraphNode,'internal.mtree.Constant')...
                    &&~(iscell(rhsGraphNode)&&numel(rhsGraphNode)==2&&isnumeric(rhsGraphNode{2}))




                    rhsGraphNode={rhsGraphNode,lhsNum};
                end

                switch lhs.kind
                case 'SUBSCR'
                    leftLeftType=this.getType(lhs.Left);
                    lhsNode=this.visitLHSSUBSCR(lhs,in,rhsGraphNode,rhsType);
                    this.setNode(lhsName,lhsNode,leftLeftType);
                case{'DOT','DOTLP'}
                    this.visitLHSDOT(lhs,rhsGraphNode,rhsType,in);
                otherwise
                    this.setNode(lhsName,rhsGraphNode,lhsType);
                end
            end
        end

        function graphNode=visit(this,node,in)




            if strcmp(node.tree2str(0,1),this.breakAtNode)





                keyboard;
            end
            [isConst,constVal]=this.evalExpression(node);

            if~iscell(isConst)
                isConst={isConst};
                constVal={constVal};
            end


            graphNode=cell(1,numel(isConst));


            if all(cell2mat(isConst))
                for ii=1:numel(graphNode)
                    graphNode{ii}=this.createConstant(node,constVal{ii});
                end


            else
                visitedNIC=this.visit@coder.internal.MTreeVisitor(node,in);



                if iscell(visitedNIC)
                    graphNode=visitedNIC;
                    return;


                else
                    for ii=1:numel(graphNode)
                        if isConst{ii}
                            graphNode{ii}=this.createConstant(node,constVal{ii});
                        else
                            graphNode{ii}=visitedNIC;
                        end
                    end
                end
            end


            if numel(graphNode)==1
                graphNode=graphNode{1};
            end
        end

        function graphNode=visitUNEXPR(this,node,in)
            op=this.visit(node.Arg,in);
            description=this.getNodeDescription(node);
            nodeTypeInfo=internal.mtree.NodeTypeInfo(...
            this.getType(node.Arg),this.getType(node));

            switch node.kind
            case 'UPLUS'
                if nodeTypeInfo.Ins==nodeTypeInfo.Outs

                    graphNode=op;
                else


                    graphNode=this.GraphBuilder.createDTCNode(description,nodeTypeInfo);
                    this.GraphBuilder.connect(op,graphNode);
                end
            case 'UMINUS'
                graphNode=this.GraphBuilder.createUminusNode(description,nodeTypeInfo);
                this.GraphBuilder.connect(op,graphNode);
            case 'NOT'



                if this.getType(node.Arg).isLogical
                    graphNode=this.GraphBuilder.createBitwiseOpNode(description,nodeTypeInfo,'bitcomp');
                else
                    graphNode=this.GraphBuilder.createCompareToConstantNode(description,nodeTypeInfo,'EQ',0);
                end
                this.GraphBuilder.connect(op,graphNode);
            case 'DOTTRANS'
                graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'transpose');
                this.GraphBuilder.connect(op,graphNode);
            case 'TRANS'
                if nodeTypeInfo.Ins.isComplex
                    graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'hermitian');
                else



                    graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'transpose');
                end
                this.GraphBuilder.connect(op,graphNode);
            end
        end

        function graphNode=visitDOTBINEXPR(this,expr,in)
            graphNode=this.visitBINEXPR(expr,in);
        end

        function graphNode=visitBINEXPR(this,expr,in)

            leftNode=expr.Left;
            rightNode=expr.Right;
            [leftType,rightType,op1,op2,lhsIsConst,rhsIsConst]=this.handleBinExprTypeDiff(in,leftNode,rightNode);

            outType=this.getType(expr);
            nodeTypeInfo=internal.mtree.NodeTypeInfo([leftType,rightType],outType);

            operation=expr.kind;
            description=this.getNodeDescription(expr);
            useOp1Node=true;
            useOp2Node=true;
            switch operation
            case 'PLUS'
                graphNode=this.GraphBuilder.createAddNode(description,nodeTypeInfo);

            case 'MINUS'
                graphNode=this.GraphBuilder.createSubNode(description,nodeTypeInfo);

            case 'MUL'
                useDotMul=false;
                if leftType.isScalar||rightType.isScalar




                    useDotMul=true;
                end
                [graphNode,useOp1Node,useOp2Node]=...
                this.handleCreateMulOrDotMulNode(description,...
                nodeTypeInfo,op1,op2,lhsIsConst,rhsIsConst,useDotMul);
            case 'DIV'

                if rightType.isScalar


                    if isa(op1,'internal.mtree.Constant')&&op1.Value==1&&...
                        rightType.isFloat
                        useOp1Node=false;

                        nodeTypeInfo.Ins=nodeTypeInfo.Ins(2);
                        graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'reciprocal');
                    else
                        graphNode=this.GraphBuilder.createDotDivNode(description,nodeTypeInfo);
                    end
                else
                    error('need to implement DIV node with matrices')
                end
            case{'EXP','DOTEXP'}
                if isa(op1,'internal.mtree.Constant')&&...
                    (isscalar(op1.Value)||all(leftType.Dimensions==rightType.Dimensions))&&...
                    all(op1.Value==10,'all')
                    useOp1Node=false;

                    nodeTypeInfo.Ins=nodeTypeInfo.Ins(2);
                    graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'10^u');
                elseif isa(op2,'internal.mtree.Constant')&&...
                    (isscalar(op2.Value)||all(leftType.Dimensions==rightType.Dimensions))&&...
                    all(op2.Value==2,'all')
                    useOp2Node=false;

                    nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                    graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'square');
                else
                    graphNode=this.GraphBuilder.createMathNode(description,nodeTypeInfo,'pow');
                end
            case 'DOTMUL'
                useDotMul=true;
                [graphNode,useOp1Node,useOp2Node]=...
                this.handleCreateMulOrDotMulNode(description,...
                nodeTypeInfo,op1,op2,lhsIsConst,rhsIsConst,useDotMul);
            case 'DOTDIV'
                graphNode=this.GraphBuilder.createDotDivNode(description,nodeTypeInfo);
            otherwise
                error('unknown binary operator')
            end

            port=1;
            if useOp1Node
                if isa(op1,'internal.mtree.Constant')
                    op1=this.GraphBuilder.instantiateConstant(op1);
                end
                this.GraphBuilder.connect(op1,{graphNode,1});
                port=2;
            end

            if useOp2Node
                if isa(op2,'internal.mtree.Constant')
                    op2=this.GraphBuilder.instantiateConstant(op2);
                end
                this.GraphBuilder.connect(op2,{graphNode,port});
            end
        end

        function graphNode=visitDOTLP(this,node,in)





            outType=this.getType(node);





            graphNode=this.recurseIntoDotExpression(node,in);


            this.setNode(node.tree2str,graphNode,outType);
        end

        function graphNode=visitDOT(this,node,in)



            [graphNode,isPragma]=this.visitPragma(node,in);
            if isPragma
                return;
            end


            if internal.mtree.isFunctionCallNode(node,this.FcnTypeInfo)
                graphNode=this.visitCALL(node,in);
                return;
            end


            outType=this.getType(node);





            graphNode=this.recurseIntoDotExpression(node,in);


            this.setNode(node.tree2str,graphNode,outType);

        end

        function graphNode=createNewBusNode(this,node,busType)




            fieldNames=busType.getFieldNames;
            fieldTypes=busType.getFieldTypes;
            nFields=numel(fieldNames);

            graphNodes=cell(1,nFields);
            for i=1:nFields
                exVal=fieldTypes(i).getExampleValue();
                graphNodes{i}=this.createConstant(node,exVal,fieldNames{i});




            end

            nodeTypeInfo=internal.mtree.NodeTypeInfo(fieldTypes,busType);
            description=this.getNodeDescription(node);


            graphNode=this.GraphBuilder.createBusCreatorNode(description,nodeTypeInfo,node.string);

            for i=1:nFields
                this.GraphBuilder.connect(graphNodes{i},{graphNode,i});
            end


            this.setNode(node.string,graphNode,busType);
        end

        function graphNode=returnBusNode(this,node,modify)




            leftOfDotType=this.getType(node.Left);
            rightOfDotType=this.getType(node);


            if modify
                inTypes=[leftOfDotType,rightOfDotType];
                outType=leftOfDotType;
            else
                inTypes=leftOfDotType;
                outType=rightOfDotType;
            end



            nodeTypeInfo=internal.mtree.NodeTypeInfo(inTypes,outType);


            description=this.getNodeDescription(node);

            if~strcmp(node.Right.kind,'ID')
                dotPosition=strfind(node.tree2str,'.');
                busElementName=extractAfter(node.tree2str,dotPosition(end));
            else
                if strcmp(node.kind,'DOTLP')

                    [~,val]=this.evalExpression(node.Right);
                    busElementName=val;
                else
                    busElementName=node.Right.string;
                end
            end


            if modify
                graphNode=this.GraphBuilder.createBusAssignmentNode(description,nodeTypeInfo,busElementName);
            else
                graphNode=this.GraphBuilder.createBusSelectorNode(description,nodeTypeInfo,busElementName);
            end
        end

        function graphNode=recurseIntoDotExpression(this,node,in)


            switch node.kind
            case 'ID'
                busName=node.string;


                existingBus=this.getNode(busName);
                if isempty(existingBus)

                    busType=this.getType(node);
                    graphNode=this.createNewBusNode(node,busType);
                    this.setNode(busName,graphNode,busType);
                else

                    graphNode=existingBus;
                end

            case{'SUBSCR','CELL'}
                graphNode=this.visit(node,in);

            case{'DOT','DOTLP'}

                graphNode1=this.recurseIntoDotExpression(node.Left,in);


                graphNode2=this.returnBusNode(node,false);

                this.GraphBuilder.connect(graphNode1,graphNode2);
                graphNode=graphNode2;

            otherwise
                error(['Unexpected node kind: ',node.kind]);
            end
        end

        function graphNode=visitLHSDOT(this,lhsNode,rhsGraphNode,rhsType,in)






            switch lhsNode.kind
            case 'ID'

                busType=this.getType(lhsNode);
                this.setNode(lhsNode.string,rhsGraphNode,busType);
                graphNode=rhsGraphNode;
            case 'SUBSCR'
                graphNode=this.visitLHSSUBSCR(lhsNode,in,rhsGraphNode,rhsType);
            case{'DOT','DOTLP'}
                lhsType=this.getType(lhsNode.Left);
                if isSystemObject(lhsType)





                    graphNode=[];
                else
                    graphNode1=this.recurseIntoDotExpression(lhsNode.Left,in);
                    graphNode2=this.returnBusNode(lhsNode,true);
                    this.GraphBuilder.connect(graphNode1,{graphNode2,1});
                    this.GraphBuilder.connect(rhsGraphNode,{graphNode2,2});
                    graphNode=this.visitLHSDOT(lhsNode.Left,graphNode2,rhsType,in);
                end
            otherwise
                error(['Unexpected LHS node kind: ',lhsNode.kind]);
            end

        end



        function[graphNode,useOp1Node,useOp2Node]=...
            handleCreateMulOrDotMulNode(this,description,nodeTypeInfo,...
            cLeft,cRight,lhsIsConst,rhsIsConst,useDotMul)

            useOp1Node=true;
            useOp2Node=true;


            if lhsIsConst&&~rhsIsConst

                nodeTypeInfo.Ins(1)=[];


                multKTimesU=true;
                graphNode=this.GraphBuilder.createGainNode(description,...
                nodeTypeInfo,cLeft,useDotMul,multKTimesU);

                useOp1Node=false;
            elseif~lhsIsConst&&rhsIsConst
                nodeTypeInfo.Ins(2)=[];
                multKTimesU=false;
                graphNode=this.GraphBuilder.createGainNode(description,...
                nodeTypeInfo,cRight,useDotMul,multKTimesU);

                useOp2Node=false;
            elseif useDotMul
                graphNode=this.GraphBuilder.createDotMulNode(description,nodeTypeInfo);
            else
                graphNode=this.GraphBuilder.createMulNode(description,nodeTypeInfo);
            end
        end

        function graphNode=handleFunctionalFormBinExpr(this,node,op1,op2,operator,typeInfo)
            if isa(op1,'internal.mtree.Constant')

                temp=op1;
                op1=op2;
                op2=temp;

                temp=typeInfo.Ins(1);
                typeInfo.Ins(1)=typeInfo.Ins(2);
                typeInfo.Ins(2)=temp;

                switch operator
                case 'LT'
                    operator='GT';
                case 'GT'
                    operator='LT';
                case 'LE'
                    operator='GE';
                case 'GE'
                    operator='LE';
                end
            end

            if isa(op2,'internal.mtree.Constant')&&...
                all(reshape(...
                typeInfo.Ins(1).castValueToType(op2.Value)==op2.Value,...
                numel(op2.Value),1))



                typeInfo.Ins=typeInfo.Ins(1);
                graphNode=this.GraphBuilder.createCompareToConstantNode(...
                this.getNodeDescription(node),typeInfo,operator,typeInfo.Ins(1).castValueToType(op2.Value));
                this.GraphBuilder.connect(op1,graphNode);
            else
                graphNode=this.GraphBuilder.createRelOpNode(this.getNodeDescription(node),typeInfo,operator);
                this.GraphBuilder.connect(op1,{graphNode,1});
                this.GraphBuilder.connect(op2,{graphNode,2});
            end
        end

        function graphNode=visitRELBINEXPR(this,expr,in)

            leftNode=expr.Left;
            rightNode=expr.Right;
            [leftType,rightType,op1,op2]=this.handleBinExprTypeDiff(in,leftNode,rightNode);

            typeInfo=internal.mtree.NodeTypeInfo(...
            [leftType,rightType],this.getType(expr));
            operator=expr.kind;
            graphNode=this.handleFunctionalFormBinExpr(expr,op1,op2,operator,typeInfo);
        end

        function graphNode=visitLOGBINEXPR(this,expr,in)

            leftNode=expr.Left;
            rightNode=expr.Right;
            [leftType,rightType,op1,op2]=this.handleBinExprTypeDiff(in,leftNode,rightNode);

            description=this.getNodeDescription(expr);
            typeInfo=internal.mtree.NodeTypeInfo(...
            [leftType,rightType],this.getType(expr));

            switch expr.kind
            case{'ANDAND','OROR'}
                graphNode=this.GraphBuilder.createLogicOpNode(description,...
                typeInfo,expr.kind);
            case{'AND','OR'}

                if typeInfo.Outs.isLogical
                    graphNode=this.GraphBuilder.createLogicOpNode(description,...
                    typeInfo,[expr.kind,expr.kind]);
                else
                    graphNode=this.GraphBuilder.createBitwiseOpNode(description,...
                    typeInfo,['bit',lower(expr.kind)]);
                end

            case 'NE'
                if typeInfo.Outs.isLogical
                    graphNode=this.GraphBuilder.createLogicOpNode(description,...
                    typeInfo,'NOT');
                else
                    graphNode=this.GraphBuilder.createBitwiseOpNode(description,...
                    typeInfo,'bitcomp');
                end
            end
            this.GraphBuilder.connect(op1,{graphNode,1});
            this.GraphBuilder.connect(op2,{graphNode,2});
        end

        function graphNode=visitID(this,id,~)
            graphNode=this.getNode(string(id));
        end

        function graphNode=visitLITERAL(this,node,~)
            graphNode=this.createConstant(node,string(node));
        end

        function out=visitFOR(this,forNode,in)
            [streamLoop,factor]=this.getLoopStreaming;

            if streamLoop&&strcmp(hdlfeature('EnableForIterator'),'on')
                out=this.handleForStreamed(forNode,factor,in);
            else
                out=this.handleForUnrolled(forNode,in);
            end
        end

        function out=handleForUnrolled(this,forNode,in)
            idx=string(forNode.Index);
            [~,vector]=this.evalExpression(forNode.Vector);


            this.addIterationDimension();

            for ii=1:numel(vector)

                this.incrementIteration();

                idxNode=this.createConstant(forNode.Index,vector(ii),idx);
                idxType=internal.mtree.Type.fromValue(vector(ii));
                this.setNode(idx,idxNode,idxType);

                this.visitNodeList(forNode.Body,in);
            end


            this.removeIterationDimension();

            out=[];
        end

        function out=handleForStreamed(this,forNode,factor,in)
            forNodeDesc=this.getNodeDescription(forNode);
            idxName=string(forNode.Index);
            idxDesc=this.getNodeDescription(forNode.Index);
            [~,idxVals]=this.evalExpression(forNode.Vector);

            loc=[this.FcnTypeInfo.scriptPath,' : ',num2str(forNode.lineno)];

            streamInfo=internal.ml2pir.utils.LoopStreamInfo(...
            idxName,idxDesc,idxVals,factor,loc);

            parentSubGraphNode=this.GraphBuilder.getCurrentSubGraphNode;


            newSubGraphNode=this.GraphBuilder.beginSubGraph(...
            ['for_',idxName],forNodeDesc,streamInfo);

            iterNode=streamInfo.iterNode;


            iterScope=internal.ml2pir.scope.IteratedScope(...
            this.CurrScope,this.GraphBuilder,...
            parentSubGraphNode,newSubGraphNode,...
            iterNode,streamInfo);
            this.CurrScope=iterScope;

            iterTypeIsIdxType=streamInfo.iterType==streamInfo.idxType;

            if streamInfo.loopIsStartStepStop&&iterTypeIsIdxType

                idxNode=iterNode;
            elseif streamInfo.loopIsStartStepStop


                dtcTypeInfo=internal.mtree.NodeTypeInfo(streamInfo.iterType,streamInfo.idxType);
                idxNode=this.GraphBuilder.createDTCNode('',dtcTypeInfo);
                this.GraphBuilder.connect(iterNode,idxNode);
            else


                idxNode=internal.ml2pir.utils.switchOnIterations(...
                this.GraphBuilder,iterScope,...
                streamInfo.idxNodes{1},streamInfo.idxType);
            end

            this.setNode(idxName,idxNode,streamInfo.idxType);




            this.addIterationDimension;
            this.incrementIteration;


            this.visitNodeList(forNode.Body,in);



            for i=2:streamInfo.numLoopBodies

                if streamInfo.loopIsStartStepStop


                    typeInfo=internal.mtree.NodeTypeInfo(...
                    [streamInfo.idxType,streamInfo.idxType],...
                    streamInfo.idxType);
                    newIdxNode=this.GraphBuilder.createAddNode('',typeInfo);

                    this.GraphBuilder.connect(idxNode,{newIdxNode,1});
                    this.GraphBuilder.connect(streamInfo.counterBias,{newIdxNode,2});

                    idxNode=newIdxNode;
                else


                    idxNode=internal.ml2pir.utils.switchOnIterations(...
                    this.GraphBuilder,iterScope,...
                    streamInfo.idxNodes{i},streamInfo.idxType);
                end

                this.setNode(idxName,idxNode,streamInfo.idxType);

                this.visitNodeList(forNode.Body,in);
            end



            iterScope.finalizeAndPropagateToParent;


            this.endScope();
            this.GraphBuilder.endSubGraph();
            this.removeIterationDimension;


            this.setNode(idxName,streamInfo.idxNodes{end}{end},streamInfo.idxType);

            out=[];
        end

        function out=handleIteratorFun(this,node,in)



            iteratorInfo=internal.mtree.utils.iteratorfun.Info(...
            node,this.FcnTypeInfo,this.FcnInfoRegistry);



            outName=node.Parent.Left.string;
            nodeName=['#',outName];


            loopInitialValueMtreeNode=node.Right.Next.Next;
            loopInitialValueNode=this.visit(loopInitialValueMtreeNode);


            outType=this.getType(loopInitialValueMtreeNode);
            this.setNode(nodeName,loopInitialValueNode,outType);

            loc=[this.FcnTypeInfo.scriptPath,' : ',num2str(node.lineno)];
            nodeDesc=this.getNodeDescription(node);
            streamInputType=this.getType(node.Right.Next);
            assert(~streamInputType.isScalar,...
            'First input to hdl.iteratorFun must not be scalar.');
            loopUpperBound=prod(streamInputType.Dimensions);
            streamInfo=internal.ml2pir.utils.LoopStreamInfo(...
            'idx',nodeDesc,1:loopUpperBound,[],loc);

            parentSubGraphNode=this.GraphBuilder.getCurrentSubGraphNode;
            newIterGraphNode=this.GraphBuilder.beginSubGraph(...
            'iteratorFun',nodeDesc,streamInfo);


            tag=newIterGraphNode.ReferenceNetwork.getForIterDataTag;
            tag.setIteratorFun(true);

            iteratedScope=internal.ml2pir.scope.IteratedScope(...
            this.CurrScope,this.GraphBuilder,...
            parentSubGraphNode,newIterGraphNode,...
            streamInfo.iterNode,streamInfo);
            this.CurrScope=iteratedScope;

            argNodes=node.Right.List;
            argNodeIdxs=indices(argNodes);
            numArgs=numel(argNodeIdxs);







            nonConstInputs=cell(1,numArgs-1);
            nonConstInputDescs=cell(1,numArgs-1);


            for ii=2:numArgs
                argNode=argNodes.select(argNodeIdxs(ii));
                if ii==3


                    argGraphNode=this.getNode(nodeName);
                else
                    argGraphNode=this.visit(argNode,in);
                end
                nonConstInputs{ii-1}=argGraphNode;
                nonConstInputDescs{ii-1}=internal.mtree.getVarDesc(argNode,this.FcnTypeInfo);


                if isConst(nonConstInputDescs{ii-1})
                    nonConstInputDescs{ii-1}.constType='NOT_A_CONST';
                end
            end


            idxInput=3;
            [iterNode,iterType]=iteratedScope.getIterNode();
            iterDesc=internal.mtree.analysis.VariableDescriptor('NOT_A_CONST',iterType);
            nonConstInputs=[nonConstInputs(1:idxInput-1),{iterNode},nonConstInputs(idxInput:end)];
            nonConstInputDescs=[nonConstInputDescs(1:idxInput-1),{iterDesc},nonConstInputDescs(idxInput:end)];
            constantInputs={};

            kernelNIC=this.elaborateUserFunction(node,iteratorInfo.CalleeFcnInfo,...
            nonConstInputs,constantInputs,iteratorInfo,nonConstInputDescs);

            this.setNode(nodeName,{kernelNIC,1},outType);
            iteratedScope.finalizeAndPropagateToParent;
            this.endScope;
            this.GraphBuilder.endSubGraph();
            out=this.getNode(nodeName);
        end


        function b=correctedConstantBitIndex(~,b)


            if isa(b,'internal.mtree.Constant')
                b.Value=double(b);
            elseif isnumeric(b)
                b=double(b);
            end
        end

        function[nodeList,nodeDescs]=visitExpandedNodeList(this,node,in)






            numNodes=count(node.List);
            temp=node;
            while~isempty(temp)
                [isMultiOut,multiOutLen]=this.isMultiOutNode(temp);
                if isMultiOut&&multiOutLen>1
                    numNodes=numNodes+multiOutLen-1;
                end
                temp=temp.Next;
            end


            nodeList=cell(1,numNodes);
            nodeDescs=cell(1,numNodes);


            nodeIdx=1;
            while~isempty(node)
                visitedNode=this.visit(node,in);
                assert(~isempty(visitedNode));
                visitedNodeDesc=internal.mtree.getVarDesc(node,this.FcnTypeInfo);

                [isMultiOut,multiOutLen]=this.isMultiOutNode(node);
                if isMultiOut
                    assert(multiOutLen==numel(visitedNode),...
                    'Visit returned invalid number of elements for multi-output node');
                    for ii=1:multiOutLen

                        nodeList{nodeIdx}=visitedNode{ii};
                        nodeDescs{nodeIdx}=visitedNodeDesc.getVarDesc(ii);
                        nodeIdx=nodeIdx+1;
                    end
                else
                    nodeList{nodeIdx}=visitedNode;
                    nodeDescs{nodeIdx}=visitedNodeDesc;
                    nodeIdx=nodeIdx+1;
                end
                node=node.Next;
            end

        end

        function graphNode=visitCALL(this,node,in)
            isUserFunction=...
            ~isempty(this.FcnTypeInfo.getCalledFcnInfoWithAttributes(node,this.getCompleteIteration,this.CallerMapKey));

            if isUserFunction
                graphNode=this.handleUserFunctionCall(node,in);
                return;
            end



            x=node.Right;
            ii=1;
            inTypes=repmat(internal.mtree.type.UnknownType,1,count(x.List));
            while~isempty(x)
                inTypes(ii)=this.getType(x);
                x=x.Next;
                ii=ii+1;
            end

            nodeTypeInfo=internal.mtree.NodeTypeInfo(inTypes,this.getType(node));







            fcnName=strtrim(node.Left.tree2str(0,1));
            switch fcnName



            case{'abs'}
                x=node.Right;
                src=this.visit(x,in);
                graphNode=this.GraphBuilder.createAbsNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(src,graphNode);

            case{'sqrt'}
                x=node.Right;
                src=this.visit(x,in);
                graphNode=this.GraphBuilder.createSqrtNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(src,graphNode);
            case{'min','max'}
                x1=node.Right;
                x1Type=this.getType(x1);
                src1=this.visit(x1,in);
                x2=x1.Next;

                if~isempty(x2)


                    [x1Type,src1]=this.resolveTypesForAssignment(x1Type,nodeTypeInfo.Outs,src1,node,1);
                    x2Type=this.getType(x2);
                    src2=this.visit(x2,in);
                    [x2Type,src2]=this.resolveTypesForAssignment(x2Type,nodeTypeInfo.Outs,src2,node,1);
                    nodeTypeInfo=internal.mtree.NodeTypeInfo([x1Type,x2Type],nodeTypeInfo.Outs);
                else
                    src2=[];
                end

                this.assert(isempty(x2.Next),'only 1- or 2-input min/max supported')

                graphNode=this.GraphBuilder.createMinMaxNode(this.getNodeDescription(node),nodeTypeInfo,fcnName);

                this.GraphBuilder.connect(src1,graphNode);
                if~isempty(src2)
                    this.GraphBuilder.connect(src2,{graphNode,2});
                end

            case{'cordicsin','cordiccos','cordicsincos'}
                x=node.Right;
                src=this.visit(x,in);
                if isempty(x.Next)

                    numIters=-1;
                else
                    [isConst,numIters]=this.evalExpression(x.Next);
                    this.assert(isConst,'number of iterations should always be constant');
                    nodeTypeInfo.Ins(2)=[];
                end
                graphNode=this.GraphBuilder.createCordicTrigNode(this.getNodeDescription(node),nodeTypeInfo,fcnName,numIters);
                this.GraphBuilder.connect(src,graphNode);

            case{'sin','cos','tan','asin','acos','atan','atan2',...
                'sinh','cosh','tanh','asinh','acosh','atanh'}
                if numel(nodeTypeInfo.Ins)==2
                    [nodeTypeInfo,op1,op2]=this.handleFunctionalBinExprTypeDiff(node,in);
                else

                    op1=this.visit(node.Right,in);
                    op2=[];
                end
                graphNode=this.GraphBuilder.createTrigNode(this.getNodeDescription(node),nodeTypeInfo,fcnName);
                this.GraphBuilder.connect(op1,{graphNode,1});
                if~isempty(op2)
                    this.GraphBuilder.connect(op2,{graphNode,2});
                end

            case{'exp','log','log10','power','conj','hypot',...
                'rem','mod','transpose','ctranspose'}


                arg=node.Right;
                switch fcnName
                case 'power'
                    [arg1Const,arg1Val,arg1Desc]=this.evalExpression(arg);
                    arg1Type=arg1Desc.type;
                    [arg2Const,arg2Val,arg2Desc]=this.evalExpression(arg.Next);
                    arg2Type=arg2Desc.type;
                    if arg1Const&&...
                        (isscalar(arg1Val)||all(arg1Type.Dimensions==arg2Type.Dimensions))&&...
                        all(arg1Val==10,'all')
                        nodeTypeInfo.Ins=nodeTypeInfo.Ins(2);
                        mathFcn='10^u';
                        arg=arg.Next;
                    elseif arg2Const&&...
                        (isscalar(arg2Val)||all(arg1Type.Dimensions==arg2Type.Dimensions))&&...
                        all(arg2Val==2,'all')
                        nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                        mathFcn='square';
                    else
                        mathFcn='pow';
                    end
                case 'ctranspose'
                    if nodeTypeInfo.Ins.isComplex
                        mathFcn='hermitian';
                    else



                        mathFcn='transpose';
                    end
                otherwise
                    mathFcn=fcnName;
                end

                if numel(nodeTypeInfo.Ins)==2
                    [nodeTypeInfo,op1,op2]=this.handleFunctionalBinExprTypeDiff(node,in);
                else

                    op1=this.visit(arg,in);
                    op2=[];
                end
                graphNode=this.GraphBuilder.createMathNode(this.getNodeDescription(node),nodeTypeInfo,mathFcn);
                this.GraphBuilder.connect(op1,{graphNode,1});
                if~isempty(op2)
                    this.GraphBuilder.connect(op2,{graphNode,2});
                end

            case{'floor','ceil','fix','round','nearest'}
                x=node.Right;
                src=this.visit(x,in);


                this.assert(isempty(x.Next),'Found a second input to round function. This is not supported.');

                graphNode=this.GraphBuilder.createRoundingNode(this.getNodeDescription(node),nodeTypeInfo,fcnName);
                this.GraphBuilder.connect(src,graphNode);

            case{'bitget'}
                x=node.Right;
                b=x.Next;
                [isBitSelConst,b]=this.evalExpression(b);
                if~isBitSelConst

                    b=1:nodeTypeInfo.Ins(1).getWordLength;
                end
                b=b-1;
                b=this.correctedConstantBitIndex(b);



                origNodeType=nodeTypeInfo.Outs.copy;
                if~origNodeType.isFi
                    outType=internal.mtree.type.Fi(...
                    numerictype(0,1,0),hdlfimath,...
                    origNodeType.Dimensions,origNodeType.Complex);
                    nodeTypeInfo.Outs=outType;
                end




                sliceNodeTypeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1),nodeTypeInfo.Outs.copy);



                if~isBitSelConst
                    sliceNodeTypeInfo.Outs.setDimensions([1,numel(b)]);
                end

                src=this.visit(x,in);
                graphNode=this.GraphBuilder.createBitsliceNode(this.getNodeDescription(node),sliceNodeTypeInfo,b,b);
                this.GraphBuilder.connect(src,graphNode);



                if~isBitSelConst

                    typeInfo=internal.mtree.NodeTypeInfo(...
                    [sliceNodeTypeInfo.Outs,nodeTypeInfo.Ins(2)],...
                    nodeTypeInfo.Outs);

                    switchNode=this.GraphBuilder.createSubscrNode(...
                    this.getNodeDescription(node),typeInfo,{typeInfo.Ins(2)},this.isNodeConditional(node));

                    src2=this.visit(x.Next,in);
                    this.GraphBuilder.connect(graphNode,{switchNode,1});
                    this.GraphBuilder.connect(src2,{switchNode,2});

                    graphNode=switchNode;
                end


                if~origNodeType.isFi

                    typeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Outs,origNodeType);

                    dtcNode=this.GraphBuilder.createDTCNode(this.getNodeDescription(node),typeInfo);
                    this.GraphBuilder.connect(graphNode,dtcNode);

                    graphNode=dtcNode;
                end

            case{'bitset'}
                x=node.Right;
                bNode=x.Next;
                vNode=bNode.Next;
                [~,b]=this.evalExpression(bNode);

                b=this.correctedConstantBitIndex(b);

                src=this.visit(x,in);
                if isempty(b)





                    error('bitset with non-constant bit to set is not supported')
                else


                    bitSetNodeType=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1),nodeTypeInfo.Outs);

                    if isempty(vNode)
                        graphNode=this.GraphBuilder.createBitsetNode(this.getNodeDescription(node),bitSetNodeType,b,1);
                        this.GraphBuilder.connect(src,graphNode);
                    else
                        [isValueConst,v]=this.evalExpression(vNode);
                        if isValueConst

                            bitsetVal=v~=0;
                            graphNode=this.GraphBuilder.createBitsetNode(this.getNodeDescription(node),bitSetNodeType,b,bitsetVal);
                            this.GraphBuilder.connect(src,graphNode);
                        else



                            bitsetVal=this.visit(vNode,in);
                            switchNodeType=internal.mtree.NodeTypeInfo([nodeTypeInfo.Outs,nodeTypeInfo.Ins(3),nodeTypeInfo.Outs],nodeTypeInfo.Outs);

                            bitSetHighNode=this.GraphBuilder.createBitsetNode(this.getNodeDescription(node),bitSetNodeType,b,1);
                            bitSetLowNode=this.GraphBuilder.createBitsetNode(this.getNodeDescription(node),bitSetNodeType,b,0);
                            graphNode=this.GraphBuilder.createSwitchNode(this.getNodeDescription(node),switchNodeType,'u2 ~= 0');

                            this.GraphBuilder.connect(src,bitSetHighNode);
                            this.GraphBuilder.connect(src,bitSetLowNode);
                            this.GraphBuilder.connect(bitSetHighNode,{graphNode,1});
                            this.GraphBuilder.connect(bitsetVal,{graphNode,2});
                            this.GraphBuilder.connect(bitSetLowNode,{graphNode,3});
                        end
                    end
                end

            case{'getmsb','getlsb'}
                this.assert(nodeTypeInfo.Ins.isFi,...
                'getmsb and getlsb are only defined for FI types');

                x=node.Right;

                if strcmp(fcnName,'getmsb')

                    b=nodeTypeInfo.Ins.Numerictype.WordLength;
                else
                    b=1;
                end

                b=b-1;
                b=this.correctedConstantBitIndex(b);

                src=this.visit(x,in);
                graphNode=this.GraphBuilder.createBitsliceNode(this.getNodeDescription(node),nodeTypeInfo,b,b);
                this.GraphBuilder.connect(src,graphNode);

            case{'bitsliceget'}
                x=node.Right;
                iLeft=x.Next;
                iRight=iLeft.Next;


                if~isempty(iLeft)
                    [~,iLeft]=this.evalExpression(iLeft);
                else


                    iLeft=nodeTypeInfo.Ins.Numerictype.WordLength;
                end

                if~isempty(iRight)

                    [~,iRight]=this.evalExpression(iRight);
                else


                    iRight=1;
                end

                iLeft=iLeft-1;
                iRight=iRight-1;

                iLeft=this.correctedConstantBitIndex(iLeft);
                iRight=this.correctedConstantBitIndex(iRight);




                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);

                src=this.visit(x,in);
                graphNode=this.GraphBuilder.createBitsliceNode(this.getNodeDescription(node),nodeTypeInfo,iLeft,iRight);
                this.GraphBuilder.connect(src,graphNode);

            case{'bitconcat'}
                arg=node.Right;
                inType1=this.getType(arg);
                this.assert(inType1.isFi&&nodeTypeInfo.Outs.isFi,...
                'bitconcat is only supported for fixed-point values');

                outFimath=nodeTypeInfo.Outs.Fimath;

                graphNode=this.visit(arg,in);
                arg=arg.Next;

                if isempty(arg)&&inType1.isVector

                    outType=nodeTypeInfo.Outs;
                    typeInfo=internal.mtree.NodeTypeInfo(inType1,outType);
                    concatNode=this.GraphBuilder.createBitconcatNode(this.getNodeDescription(node),typeInfo);
                    this.GraphBuilder.connect(graphNode,concatNode);
                    graphNode=concatNode;
                else

                    while~isempty(arg)



                        bitsLow=this.visit(arg,in);



                        inType2=this.getType(arg);
                        this.assert(inType2.isFi,...
                        'bitconcat is only supported for fixed-point values');

                        if isempty(arg.Next)



                            outType=nodeTypeInfo.Outs;
                        else



                            inWL1=inType1.Numerictype.WordLength;
                            inWL2=inType2.Numerictype.WordLength;
                            outNumerictype=numerictype(0,inWL1+inWL2,0);

                            outType=internal.mtree.type.Fi(...
                            outNumerictype,outFimath,...
                            inType1.Dimensions,false);
                        end
                        typeInfo=internal.mtree.NodeTypeInfo([inType1,inType2],outType);

                        concatNode=this.GraphBuilder.createBitconcatNode(this.getNodeDescription(node),typeInfo);
                        this.GraphBuilder.connect(graphNode,concatNode);
                        this.GraphBuilder.connect(bitsLow,{concatNode,2});
                        graphNode=concatNode;
                        arg=arg.Next;



                        inType1=outType;
                    end
                end

            case{'bitsll','bitsrl','bitsra','bitshift'}



                x=node.Right;
                shift=x.Next;
                [isConst,shift]=this.evalExpression(shift);
                if isConst
                    src=this.visit(x,in);


                    if strcmp(fcnName,'bitshift')
                        if shift<0


                            fcnName='bitsra';
                            shift=abs(shift);
                        else
                            fcnName='bitsll';
                        end
                    end



                    nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                    graphNode=this.GraphBuilder.createBitshiftNode(this.getNodeDescription(node),nodeTypeInfo,fcnName,shift);
                    this.GraphBuilder.connect(src,graphNode);
                else
                    if strcmp(fcnName,'bitshift')
                        shiftType=nodeTypeInfo.Ins(2);
                        isShiftSigned=(shiftType.isFi||shiftType.isInt)&&shiftType.isSigned;
                        if isShiftSigned
                            mode='Bidi';
                        else





                            mode='Left';
                        end
                        graphNode=this.GraphBuilder.createVarArithShiftNode(this.getNodeDescription(node),nodeTypeInfo,mode);
                    elseif strcmp(fcnName,'bitsll')
                        graphNode=this.GraphBuilder.createVarArithShiftNode(this.getNodeDescription(node),nodeTypeInfo,'Left');
                    elseif strcmp(fcnName,'bitsra')
                        graphNode=this.GraphBuilder.createVarArithShiftNode(this.getNodeDescription(node),nodeTypeInfo,'Right');
                    else
                        outType=nodeTypeInfo.Outs(1);
                        isOutputUnsigned=(outType.isFi||outType.isInt)&&~outType.isSigned;

                        if isOutputUnsigned
                            graphNode=this.GraphBuilder.createVarArithShiftNode(this.getNodeDescription(node),nodeTypeInfo,'Right');
                        else
                            graphNode=this.GraphBuilder.createMatlabFunctionNode(this.getNodeDescription(node),nodeTypeInfo,'bitsrl',true);
                        end
                    end

                    src=this.visit(x,in);
                    shift=this.visit(x.Next,in);

                    this.GraphBuilder.connect(src,graphNode);
                    this.GraphBuilder.connect(shift,{graphNode,2});
                end

            case{'bitand','bitor','bitxor'}
                arg=node.Right;

                leftNode=arg;
                rightNode=arg.Next;
                [leftType,rightType,op1,op2]=this.handleBinExprTypeDiff(in,leftNode,rightNode);
                outTypeOrig=nodeTypeInfo.Outs;
                outTypeIsDouble=outTypeOrig.isDouble;

                if outTypeIsDouble


                    assumedTypeStr='uint64';
                    assumedTypeArg=arg.Next.Next;
                    if~isempty(assumedTypeArg)
                        [~,assumedTypeStr]=this.evalExpression(assumedTypeArg);
                    end
                    outType=internal.mtree.Type.makeType(assumedTypeStr,outTypeOrig.Dimensions,outTypeOrig.isComplex);
                else
                    outType=outTypeOrig;
                end

                if leftType.isDouble



                    dtc=this.GraphBuilder.createDTCNode(this.getNodeDescription(leftNode),...
                    internal.mtree.NodeTypeInfo(leftType,outType));
                    leftType=outType.copy;
                    this.GraphBuilder.connect(op1,dtc);
                    op1=dtc;
                end

                if rightType.isDouble



                    dtc=this.GraphBuilder.createDTCNode(this.getNodeDescription(rightNode),...
                    internal.mtree.NodeTypeInfo(rightType,outType));
                    rightType=outType.copy;
                    this.GraphBuilder.connect(op2,dtc);
                    op2=dtc;
                end


                typeInfo=internal.mtree.NodeTypeInfo(...
                [leftType,rightType],outType);

                graphNode=this.GraphBuilder.createBitwiseOpNode(...
                this.getNodeDescription(node),typeInfo,fcnName);
                this.GraphBuilder.connect(op1,graphNode);
                this.GraphBuilder.connect(op2,{graphNode,2});

                if outTypeIsDouble


                    dtc=this.GraphBuilder.createDTCNode(this.getNodeDescription(node),...
                    internal.mtree.NodeTypeInfo(outType,outTypeOrig));
                    this.GraphBuilder.connect(graphNode,dtc);
                    graphNode=dtc;
                end
            case{'bitandreduce','bitorreduce','bitxorreduce'}
                arg=node.Right;
                inType1=this.getType(arg);
                input=this.visit(arg,in);

                if~isempty(arg.Next)

                    [~,iLeft]=this.evalExpression(arg.Next);
                else

                    iLeft=[];
                end
                if~isempty(arg.Next.Next)

                    [~,iRight]=this.evalExpression(arg.Next.Next);
                elseif~isempty(iLeft)


                    iRight=1;
                end

                if~isempty(iLeft)

                    sliceOutNumerictype=numerictype(0,iLeft-iRight+1,0);
                    sliceOutType=internal.mtree.type.Fi(...
                    sliceOutNumerictype,nodeTypeInfo.Outs.Fimath,...
                    inType1.Dimensions,false);
                    sliceNodeTypeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1),sliceOutType);

                    graphNode=this.GraphBuilder.createBitsliceNode(this.getNodeDescription(node),sliceNodeTypeInfo,iLeft-1,iRight-1);
                    this.GraphBuilder.connect(input,graphNode);


                    input=graphNode;
                    nodeTypeInfo.Ins=sliceOutType;
                end


                graphNode=this.GraphBuilder.createBitReduceNode(...
                this.getNodeDescription(node),nodeTypeInfo,fcnName);
                this.GraphBuilder.connect(input,graphNode);

            case{'bitrol','bitror'}
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);


                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createBitRotNode(...
                this.getNodeDescription(node),nodeTypeInfo,fcnName,right);
                this.GraphBuilder.connect(left,graphNode);

            case 'bitcmp'



                this.assert(numel(nodeTypeInfo.Ins)==1,'Assumedtype is not supported for bitcmp');



                this.assert(nodeTypeInfo.Ins.isFi||nodeTypeInfo.Ins.isInt,...
                'bitcmp is only supported for int or double input types');

                left=this.visit(node.Right,in);
                graphNode=this.GraphBuilder.createBitwiseOpNode(this.getNodeDescription(node),nodeTypeInfo,'bitcomp');
                this.GraphBuilder.connect(left,graphNode);

            case{'fi','sfi','ufi','cast',...
                'int8','uint8','int16','uint16',...
                'int32','uint32','int64','uint64',...
                'logical',...
                'half','single','double'}

                arg=node.Right;
                src=this.visit(arg,in);

                outType=nodeTypeInfo.Outs(1);
                inType=nodeTypeInfo.Ins(1);

                redundant=false;
                if~isa(src,'internal.mtree.Constant')
                    argType=this.getType(arg);
                    if argType==outType

                        graphNode=src;
                        redundant=true;
                    end
                end

                if outType.isUnknown




                    if strcmp(fcnName,'cast')
                        [isConst,val]=this.evalExpression(node.Right.Next);
                        if isConst&&strcmp(val,'like')


                            outType=this.getType(node.Right.Next.Next);
                        else


                            [~,outTypeName]=this.evalExpression(node.Right.Next);
                            outType=internal.mtree.Type.makeType(...
                            outTypeName,inType.Dimensions,inType.isComplex);
                        end
                    elseif ismember(fcnName,{'fi','sfi','ufi'})



                        fiArg=arg.Next;
                        fiArgVals=cell(1,count(fiArg.List)+1);
                        fiArgVals{1}=0;
                        valsIdx=2;

                        while~isempty(fiArg)
                            [~,fiArgVals{valsIdx}]=this.evalExpression(fiArg);
                            fiArg=fiArg.Next;
                            valsIdx=valsIdx+1;
                        end


                        f=feval(fcnName,fiArgVals{:});
                        nt=numerictype(f);
                        fm=fimath(f);

                        outType=internal.mtree.type.Fi(...
                        nt,fm,inType.Dimensions,inType.isComplex);
                    else


                        outType=internal.mtree.Type.makeType(...
                        fcnName,inType.Dimensions,inType.isComplex);
                    end
                end
                this.assert(~outType.isUnknown,'type information missing');

                if~redundant
                    if isa(src,'internal.mtree.Constant')
                        src=this.GraphBuilder.instantiateConstant(src);
                    end




                    typeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1),outType);
                    graphNode=this.GraphBuilder.createDTCNode(this.getNodeDescription(node),typeInfo);
                    this.GraphBuilder.connect(src,graphNode);
                end

            case 'reinterpretcast'
                arg=node.Right;
                src=this.visit(arg,in);




                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createReinterpretNode(...
                this.getNodeDescription(node,node.kind),nodeTypeInfo);
                this.GraphBuilder.connect(src,graphNode);

            case 'reshape'
                matNode=node.Right;
                mat=this.visit(matNode,in);



                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createReshapeNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(mat,graphNode);

            case 'setfimath'
                arg=node.Right;
                graphNode=this.visit(arg,in);

            case{'storedInteger','int'}
                arg=node.Right;
                src=this.visit(arg,in);
                argType=this.getType(arg);

                if argType.isFi
                    if argType.Numerictype.FractionLength==0
                        switch argType.Numerictype.WordLength
                        case{8,16,32,64}


                            graphNode=src;
                            return;
                        end
                    end
                end
                graphNode=this.GraphBuilder.createReinterpretNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(src,graphNode);

            case 'and'
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);

                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'ANDAND');
                this.GraphBuilder.connect(left,graphNode);
                this.GraphBuilder.connect(right,{graphNode,2});

            case 'or'
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);

                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'OROR');
                this.GraphBuilder.connect(left,graphNode);
                this.GraphBuilder.connect(right,{graphNode,2});

            case 'xor'
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);

                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'XOR');
                this.GraphBuilder.connect(left,graphNode);
                this.GraphBuilder.connect(right,{graphNode,2});

            case 'plus'
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);

                graphNode=this.GraphBuilder.createAddNode(...
                this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(left,graphNode);
                this.GraphBuilder.connect(right,{graphNode,2});

            case 'minus'
                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);

                graphNode=this.GraphBuilder.createSubNode(...
                this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(left,graphNode);
                this.GraphBuilder.connect(right,{graphNode,2});

            case{'times','mtimes'}


                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);
                useDotMul=isequal(fcnName,'times');


                leftIsConst=isa(left,'internal.mtree.Constant');
                rightIsConst=isa(right,'internal.mtree.Constant');
                [graphNode,useOp1Node,useOp2Node]=...
                this.handleCreateMulOrDotMulNode(this.getNodeDescription(node),...
                nodeTypeInfo,left,right,leftIsConst,rightIsConst,useDotMul);

                if(useOp1Node)
                    this.GraphBuilder.connect(left,graphNode);
                end
                if(useOp2Node)
                    this.GraphBuilder.connect(right,{graphNode,2});
                end

            case{'ge','le','gt','lt','eq','ne'}
                op1=this.visit(node.Right,in);
                op2=this.visit(node.Right.Next,in);
                operator=upper(fcnName);
                graphNode=this.handleFunctionalFormBinExpr(node,...
                op1,op2,operator,nodeTypeInfo);
            case 'all'

                arg=node.Right;
                left=this.visit(arg,in);


                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'ANDAND');
                this.GraphBuilder.connect(left,graphNode);

            case 'any'

                arg=node.Right;
                left=this.visit(arg,in);


                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'OROR');
                this.GraphBuilder.connect(left,graphNode);

            case 'not'

                arg=node.Right;
                left=this.visit(arg,in);


                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);
                graphNode=this.GraphBuilder.createLogicOpNode(...
                this.getNodeDescription(node),nodeTypeInfo,'NOT');
                this.GraphBuilder.connect(left,graphNode);

            case 'complex'


                arg=node.Right;
                left=this.visit(arg,in);
                right=this.visit(arg.Next,in);
                mode='real and imag';
                constVal=0;
                if(isa(left,'internal.mtree.Constant'))


                    nodeTypeInfo.Ins(1)=[];
                    mode='imag';
                    constVal=left;
                elseif(isa(right,'internal.mtree.Constant'))
                    nodeTypeInfo.Ins(2)=[];
                    mode='real';
                    constVal=right;
                end


                graphNode=this.GraphBuilder.createRealImagToComplexNode(...
                this.getNodeDescription(node),nodeTypeInfo,mode,constVal);


                port=1;
                if(~isa(left,'internal.mtree.Constant'))
                    this.GraphBuilder.connect(left,graphNode);
                    port=2;
                end
                if(~isa(right,'internal.mtree.Constant'))
                    this.GraphBuilder.connect(right,{graphNode,port});
                end

            case{'real','imag'}
                arg=node.Right;
                left=this.visit(arg,in);

                graphNode=this.GraphBuilder.createComplexToRealImagNode(...
                this.getNodeDescription(node),nodeTypeInfo,fcnName);
                this.GraphBuilder.connect(left,graphNode);

            case{'sum','prod'}
                arg=node.Right;
                left=this.visit(arg,in);

                dimension=-1;
                optArg=arg.Next;
                hasDimArg=false;
                if~isempty(optArg)
                    [isConst,optVal]=this.evalExpression(optArg);
                    this.assert(isConst,'Optional argument to sum/prod does not evaluate to a constant.');
                    if isnumeric(optVal)


                        dimension=optVal;
                        hasDimArg=true;
                    elseif ischar(optVal)&&strcmpi(optVal,'all')

                        hasDimArg=true;
                    end
                end

                if~hasDimArg&&this.getType(arg).isMatrix

                    dimension=1;
                end

                nodeTypeInfo.Ins=nodeTypeInfo.Ins(1);

                if nodeTypeInfo.Ins.isScalar
                    graphNode=this.GraphBuilder.createNoopNode(...
                    this.getNodeDescription(node),nodeTypeInfo);
                elseif strcmp(fcnName,'sum')
                    graphNode=this.GraphBuilder.createSumNode(...
                    this.getNodeDescription(node),nodeTypeInfo,dimension);
                else
                    graphNode=this.GraphBuilder.createProdNode(...
                    this.getNodeDescription(node),nodeTypeInfo,dimension);
                end
                this.GraphBuilder.connect(left,graphNode);

            case 'uplus'
                arg=node.Right;
                left=this.visit(arg,in);
                if nodeTypeInfo.Ins==nodeTypeInfo.Outs

                    graphNode=left;
                else


                    graphNode=this.GraphBuilder.createDTCNode(this.getNodeDescription(node),nodeTypeInfo);
                    this.GraphBuilder.connect(left,graphNode);
                end

            case 'uminus'
                arg=node.Right;
                left=this.visit(arg,in);
                graphNode=this.GraphBuilder.createUminusNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(left,graphNode);

            case 'isequal'
                dim=nodeTypeInfo.Ins(1).Dimensions;
                N=size(nodeTypeInfo.Ins,2);
                for i=2:N
                    if~isequal(nodeTypeInfo.Ins(i).Dimensions,dim)

                        graphNode=this.createConstant(node,false);
                        return
                    end
                end

                if N<=2

                    op1=this.visit(node.Right,in);
                    op2=this.visit(node.Right.Next,in);

                    tempType=nodeTypeInfo.Outs.copy;
                    tempType.setDimensions(nodeTypeInfo.Ins(1).Dimensions);
                    eqTypeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1:2),tempType);
                    intermediateNode=this.GraphBuilder.createRelOpNode(this.getNodeDescription(node),eqTypeInfo,'EQ');
                    this.GraphBuilder.connect(op1,{intermediateNode,1});
                    this.GraphBuilder.connect(op2,{intermediateNode,2});

                    andTypeInfo=internal.mtree.NodeTypeInfo(eqTypeInfo.Outs,nodeTypeInfo.Outs);
                else

                    if dim(1)>=dim(2)

                        concatDimension='2';
                        concatOutType=nodeTypeInfo.Outs.copy;
                        concatOutType.setDimensions([dim(1)*(N-1),dim(2)]);
                    else

                        concatDimension='1';
                        concatOutType=nodeTypeInfo.Outs.copy;
                        concatOutType.setDimensions([dim(1),dim(2)*(N-1)]);
                    end
                    concatInType=nodeTypeInfo.Outs.copy;
                    concatInType.setDimensions(dim);
                    concatTypeInfo=internal.mtree.NodeTypeInfo(repmat(concatInType,1,N-1),concatOutType);
                    concatNode=this.GraphBuilder.createArrayConcatNode(this.getNodeDescription(node),concatTypeInfo,concatDimension);

                    tempType=nodeTypeInfo.Outs.copy;
                    tempType.setDimensions(nodeTypeInfo.Ins(1).Dimensions);
                    eqTypeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Ins(1:2),tempType);

                    op1=this.visit(node.Right,in);
                    idx=0;
                    curr=node.Right;
                    while(~curr.Next.isempty)


                        idx=idx+1;
                        curr=curr.Next;
                        currOp=this.visit(curr,in);

                        eqGraphNode=this.GraphBuilder.createRelOpNode(this.getNodeDescription(node),eqTypeInfo,'EQ');
                        this.GraphBuilder.connect(op1,{eqGraphNode,1});
                        this.GraphBuilder.connect(currOp,{eqGraphNode,2});

                        this.GraphBuilder.connect(eqGraphNode,{concatNode,idx});
                    end
                    andTypeInfo=internal.mtree.NodeTypeInfo(concatTypeInfo.Outs,nodeTypeInfo.Outs);
                    intermediateNode=concatNode;
                end

                if(N<=2)&&isequal(dim,[1,1])


                    graphNode=intermediateNode;
                else


                    graphNode=this.GraphBuilder.createLogicOpNode(...
                    this.getNodeDescription(node),andTypeInfo,'ANDAND');

                    this.GraphBuilder.connect(intermediateNode,graphNode);
                end



            case{'tic','toc','fprintf','sprintf','help',...
                'validateattributes'}






                graphNode=this.createConstant(node,uint8(0));
            case{'disp','assert','error'}



                graphNode=[];
            case{'step'}
                arg=node.Right;
                type=this.getType(arg);
                if type.isSystemObject


                    sysobjVar=arg.string;
                    SystemObject=this.visit(arg,in);
                    assert(isa(SystemObject,'internal.mtree.Constant'),...
                    'System object declaration must be constant and cannot be called by a step function multiple times');
                    SystemObject=SystemObject.Value;

                    arg=arg.Next;
                    nodeTypeInfo.Ins=nodeTypeInfo.Ins(2:end);

                    idx=1;
                    numInputs=count(arg.List);
                    inputs=cell(1,numInputs);
                    while~isempty(arg)
                        inputs{idx}=this.visit(arg,in);
                        arg=arg.Next;
                        idx=idx+1;
                    end

                    if type.IsPIRBased
                        graphNode=this.GraphBuilder.createPIRSystemObjectNode(this.getNodeDescription(node),nodeTypeInfo,SystemObject);
                    else

                        error('user-authored system objects not supported');
                    end

                    for ii=1:numel(inputs)
                        this.GraphBuilder.connect(inputs{ii},{graphNode,ii});
                    end



                    this.setNode(sysobjVar,graphNode,type);
                else

                    graphNode=this.GraphBuilder.createMatlabFunctionNode(this.getNodeDescription(node),nodeTypeInfo,fcnName,true);
                end
            case 'sign'
                arg=node.Right;
                left=this.visit(arg,in);
                graphNode=this.GraphBuilder.createSignNode(this.getNodeDescription(node),nodeTypeInfo);
                this.GraphBuilder.connect(left,graphNode);
            case 'struct'
                graphNode=this.createBusForStructCall(node,in);
            case{'horzcat','vertcat','cat'}
                arg=node.Right;
                if strcmp(fcnName,'horzcat')
                    dim=2;
                elseif strcmp(fcnName,'vertcat')
                    dim=1;
                else



                    [~,dim]=this.evalExpression(arg);
                    nodeTypeInfo.Ins=nodeTypeInfo.Ins(2:end);
                    arg=arg.Next;
                end



                numIn=numel(nodeTypeInfo.Ins);
                outType=nodeTypeInfo.Outs;
                argNodes=cell(1,numIn);
                for ii=1:numIn
                    inType=nodeTypeInfo.Ins(ii);
                    argNode=this.visit(arg,in);
                    [inType,argNodes{ii}]=...
                    this.resolveTypesForAssignment(inType,outType,argNode,arg,1);
                    nodeTypeInfo.Ins(ii)=inType;
                    arg=arg.Next;
                end

                graphNode=this.GraphBuilder.createArrayConcatNode(this.getNodeDescription(node),nodeTypeInfo,dim);

                for ii=1:numIn
                    this.GraphBuilder.connect(argNodes{ii},{graphNode,ii});
                end
            case{'isinf','isnan','isfinite'}
                arg=node.Right;
                argNode=this.visit(arg,in);

                graphNode=this.GraphBuilder.createFloatRelOpNode(this.getNodeDescription(node),nodeTypeInfo,fcnName);
                this.GraphBuilder.connect(argNode,graphNode);
            otherwise
                graphNode=this.GraphBuilder.createMatlabFunctionNode(this.getNodeDescription(node),nodeTypeInfo,fcnName,true);
            end
        end

        function graphNode=handleUserFunctionCall(this,callerNode,in)

            arg=callerNode.Right;


            if strcmp(callerNode.kind,'DOT')

                argList={};
                argDescs={};
            else
                [argList,argDescs]=this.visitExpandedNodeList(arg,in);
            end


            nonConstInputs=cell(1,numel(argList));
            constantInputs=cell(1,numel(nonConstInputs)*2);
            nonConstIdx=1;
            constIdx=1;
            nonConstInputDescs=cell(1,numel(argDescs));


            for ii=1:numel(argList)

                argNode=argList{ii};

                if isa(argNode,'internal.mtree.Constant')
                    constantInputs{constIdx}=int2str(ii);
                    constantInputs{constIdx+1}=argNode;
                    constIdx=constIdx+2;
                else
                    nonConstInputs{nonConstIdx}=argNode;
                    nonConstInputDescs{nonConstIdx}=argDescs{ii};
                    nonConstIdx=nonConstIdx+1;
                end
            end

            constantInputs(constIdx:end)=[];
            nonConstInputs(nonConstIdx:end)=[];
            nonConstInputDescs(nonConstIdx:end)=[];

            calleeFcnInfo=this.FcnTypeInfo.getCalledFcnInfo(callerNode);

            graphNode=this.elaborateUserFunction(callerNode,...
            calleeFcnInfo,nonConstInputs,constantInputs,[],nonConstInputDescs);
        end

        function graphNode=elaborateUserFunction(this,callerNode,...
            calleeFcnInfo,nonConstInputs,constInputs,subGraphInfo,nonConstInputDescs)

            if this.getType(callerNode,1).isVoid


                graphNode=[];
                return;
            end








            calleeMapKey=calleeFcnInfo.setupCurrentTreeAttributes(this.FcnTypeInfo,...
            callerNode,this.getCompleteIteration,this.CallerMapKey);


            fcnMapKey=this.getFcnMapKey(calleeFcnInfo,constInputs);

            fcnName=calleeFcnInfo.functionName;
            nodeDesc=this.getNodeDescription(callerNode);

            if this.FcnMap.isKey(fcnMapKey)
                prevGraphNode=this.FcnMap(fcnMapKey);

                graphNode=this.GraphBuilder.copySubGraph(fcnName,...
                prevGraphNode,nodeDesc,subGraphInfo);
            else
                graphNode=this.GraphBuilder.beginSubGraph(fcnName,nodeDesc,subGraphInfo);



                traceOverride=false;
                if this.GraphBuilder.generateTraceability&&...
                    isempty(this.GraphBuilder.getNodeTraceabilityOverride)&&...
                    isempty(regexp(calleeFcnInfo.scriptPath,'^#\S*','match'))






                    this.GraphBuilder.setNodeTraceabilityOverride(this.GraphBuilder.getNodeTraceability(callerNode));
                    traceOverride=true;
                end


                if strcmp(calleeFcnInfo.functionName,'stepImpl')&&isSystemObject(this.getType(callerNode.Right))
                    fcn2Subsys=internal.ml2pir.SystemObject2SubsystemConverter(this.FcnInfoRegistry,...
                    this.ExprMap,calleeFcnInfo,this.GraphBuilder,this.ConversionSettings,...
                    callerNode,this.FcnTypeInfo,this.CallerMapKey);
                else
                    fcn2Subsys=internal.ml2pir.Function2SubsystemConverter(this.FcnInfoRegistry,...
                    this.ExprMap,calleeFcnInfo,this.GraphBuilder,this.ConversionSettings);
                end


                fcn2Subsys.FcnMap=this.FcnMap;



                this.setCalleeControlFlowInfo(fcn2Subsys);



                fcn2Subsys.CallerMapKey=calleeMapKey;


                fcn2Subsys.convertFunction();

                if traceOverride

                    this.GraphBuilder.setNodeTraceabilityOverride('');
                end

                this.GraphBuilder.endSubGraph;



                this.FcnMap=fcn2Subsys.FcnMap;


                this.FcnMap(fcnMapKey)=graphNode;
            end


            this.recursivelyConnectNonConstInputs(nonConstInputs,nonConstInputDescs,graphNode);

        end

        function recursivelyConnectNonConstInputs(this,inputs,inputDescs,graphNode)




            idx=1;

            function connectRecursively(in,inDesc)

                if inDesc.isConst
                    return
                end

                assert(isa(inDesc,'internal.mtree.analysis.VariableDescriptor'),...
                'Input variable descriptor is an invalid type');

                if inDesc.isListDesc




                    assert(iscell(in)&&(numel(in)~=2||~isnumeric(in{2})),...
                    'Invalid cell array of nodes for non-constant input argument');
                    assert(numel(in)==inDesc.getLength,...
                    'Number of nodes in cell array does not match number of descriptors');



                    for jj=1:numel(in)
                        connectRecursively(in{jj},inDesc.getVarDesc(jj))
                    end

                else

                    this.GraphBuilder.connect(in,{graphNode,idx});
                    idx=idx+1;
                end
            end

            assert(numel(inputs)==numel(inputDescs),'Each input must have an associated descriptor');

            for ii=1:numel(inputs)
                connectRecursively(inputs{ii},inputDescs{ii});
            end
        end

        function graphNode=createBusForStructCall(this,node,in)
            busType=this.getType(node);
            assert(busType.isStructType);

            fieldNames=busType.getFieldNames;
            nFields=length(fieldNames);

            graphNodes=cell(1,nFields);
            fieldNodeTypes=cell(1,nFields);

            fieldNodeName=node.Right;


            while~isempty(fieldNodeName)
                fName=fieldNodeName.tree2str;
                fName(fName=='''')='';
                idx=find(strcmp(fieldNames,fName));
                fieldNode=fieldNodeName.Next;
                fieldNodeTypes{idx}=this.getType(fieldNode);
                graphNodes{idx}=this.visit(fieldNode,in);
                fieldNodeName=fieldNode.Next;
            end

            nodeTypeInfo=internal.mtree.NodeTypeInfo([fieldNodeTypes{:}],busType);
            description=this.getNodeDescription(node);


            graphNode=this.GraphBuilder.createBusCreatorNode(description,nodeTypeInfo,node.tree2str);

            for i=1:nFields
                this.GraphBuilder.connect(graphNodes{i},{graphNode,i});
            end


            this.setNode(node.tree2str,graphNode,busType);
        end

        function out=visitSWITCH(this,node,in)
            caseNode=node.Body;


            numCases=count(caseNode.List);


            caseBlockDescriptions=cell(1,numCases);
            caseBlockControls=cell(1,numCases);
            caseBlockScopes=cell(1,numCases);

            caseVar=node.Left;
            hasAlwaysExecutedCase=false;




            idx=1;
            while~isempty(caseNode)&&~hasAlwaysExecutedCase
                if strcmp(caseNode.kind,'CASE')
                    [isCaseConst,caseLogicalVal]=this.evalExpression(caseNode);

                    if isCaseConst


                        if caseLogicalVal





                            caseBlockDescriptions{idx}=this.getNodeDescription(caseNode.Left,caseNode.kind);
                            hasAlwaysExecutedCase=true;


                        else



                            caseNode=caseNode.Next;
                            continue;
                        end
                    else


                        thisCaseControl=this.getCaseControl(caseNode.Left,caseVar,in);
                        caseBlockDescriptions{idx}=this.getNodeDescription(caseNode.Left,caseNode.kind);
                        caseBlockControls{idx}=thisCaseControl;
                    end
                elseif strcmp(caseNode.kind,'OTHERWISE')

                    caseBlockDescriptions{idx}=this.getNodeDescription(caseNode,caseNode.kind);

                elseif strcmp(caseNode.kind,'COMMENT')



                    this.visit(caseNode,in);

                    caseNode=caseNode.Next;
                    continue;
                else
                    error(['Unexpected ''',caseNode.kind,''' node found in SWITCH node.']);
                end


                caseBlockScopes{idx}=this.beginScope;
                this.visitNodeList(caseNode.Body,in);
                this.endScope;

                caseNode=caseNode.Next;
                idx=idx+1;
            end


            caseBlockDescriptions(idx:end)=[];
            caseBlockControls(idx:end)=[];
            caseBlockScopes(idx:end)=[];

            numCases=numel(caseBlockDescriptions);


            boolType=internal.mtree.Type.makeType('logical',[1,1]);
            caseBlockControlsTypes=repmat(boolType,1,numCases);

            this.processConditionalBlocks(caseBlockDescriptions,...
            caseBlockControls,caseBlockControlsTypes,caseBlockScopes);

            out=[];
        end

        function controlNode=getCaseControl(this,caseConditions,caseVar,in)
            boolType=internal.mtree.Type.makeType('logical',[1,1]);
            orNodeTypeInfo=internal.mtree.NodeTypeInfo([boolType,boolType],boolType);

            if strcmp(caseConditions.kind,'LC')

                prevCond=[];
                isCaseAlwaysExecuted=false;
                hasCaseNeverExecuted=false;

                rowNode=caseConditions.Arg;
                while~isempty(rowNode)&&~isCaseAlwaysExecuted
                    caseVal=rowNode.Arg;
                    while~isempty(caseVal)&&~isCaseAlwaysExecuted

                        eqNode=this.getSingleCaseEqualsNode(caseVal,caseVar,in);

                        if~isa(eqNode,'internal.mtree.Constant')


                            if isempty(prevCond)
                                prevCond=eqNode;
                            else
                                orNode=this.GraphBuilder.createLogicOpNode(this.getNodeDescription(caseVal),...
                                orNodeTypeInfo,'||');
                                this.GraphBuilder.connect(prevCond,{orNode,1});
                                this.GraphBuilder.connect(eqNode,{orNode,2});

                                prevCond=orNode;
                            end
                        else

                            if eqNode.Value


                                prevCond=eqNode;
                                isCaseAlwaysExecuted=true;
                            else


                                hasCaseNeverExecuted=true;
                            end
                        end
                        caseVal=caseVal.Next;
                    end
                    rowNode=rowNode.Next;
                end

                if~isempty(prevCond)

                    controlNode=prevCond;
                elseif hasCaseNeverExecuted
                    assert(isa(eqNode,'internal.mtree.Constant')&&~eqNode.Value);



                    controlNode=eqNode;
                else


                    controlNode=[];
                end
            else

                controlNode=this.getSingleCaseEqualsNode(caseConditions,caseVar,in);
            end
        end

        function eqNode=getSingleCaseEqualsNode(this,caseVal,caseVar,in)

            boolType=internal.mtree.Type.makeType('logical',[1,1]);
            caseVarType=this.getType(caseVar);
            caseValType=this.getType(caseVal);

            caseValNode=this.visit(caseVal,in);
            caseVarNode=this.visit(caseVar,in);

            if~all(caseVarType.Dimensions==caseValType.Dimensions)


                eqNode=this.createConstant(caseVal,false);
            elseif isa(caseValNode,'internal.mtree.Constant')
                if isa(caseVarNode,'internal.mtree.Constant')



                    if caseVarType.isChar&&caseValType.isChar
                        constVal=strcmp(caseValNode.Value,caseVarNode.Value);
                    else
                        constVal=caseValNode.Value==caseVarNode.Value;
                    end
                    eqNode=this.createConstant(caseVal,constVal);
                else

                    eqNodeTypeInfo=internal.mtree.NodeTypeInfo(caseVarType,boolType);
                    eqNode=this.GraphBuilder.createCompareToConstantNode(this.getNodeDescription(caseVal),...
                    eqNodeTypeInfo,'==',caseValNode.Value);
                    this.GraphBuilder.connect(caseVarNode,eqNode);
                end
            else
                eqNodeTypeInfo=internal.mtree.NodeTypeInfo([caseVarType,caseValType],boolType);
                eqNode=this.GraphBuilder.createRelOpNode(this.getNodeDescription(caseVal),eqNodeTypeInfo,'==');
                this.GraphBuilder.connect(caseVarNode,{eqNode,1});
                this.GraphBuilder.connect(caseValNode,{eqNode,2});
            end
        end


        function out=visitLB(this,node,in)
            out=[];
            row=node.Arg;

            if row.iskind('ROW')
                rowNodes=cell(1,count(row.List));
                rowDescriptions=cell(1,count(row.List));
                rowIdx=1;

                description=this.getNodeDescription(node);

                colNodeOutType=this.getType(node);
                colNodeTypeInfo=internal.mtree.NodeTypeInfo([],colNodeOutType);

                rowNodeTypeInfos=internal.mtree.NodeTypeInfo.empty;

                while(~isempty(row))
                    elem=row.Arg;
                    numElems=count(elem.List);


                    rowInTypes=repmat(internal.mtree.type.UnknownType,1,numElems);


                    thisRowOutType=colNodeOutType.copy;
                    thisRowOutType.setDimensions(this.getType(row).Dimensions);

                    colNodeTypeInfo.Ins(end+1)=thisRowOutType;


                    currRow=cell(1,numElems);
                    elemIdx=1;


                    while~isempty(elem)
                        element=this.visit(elem,in);
                        if isempty(element)


                            rowInTypes(elemIdx)=[];
                            currRow(elemIdx)=[];
                            elem=elem.Next;
                            continue;
                        end
                        currRow{elemIdx}=element;


                        [rowInTypes(elemIdx),currRow{elemIdx}]=...
                        this.resolveTypesForAssignment(this.getType(elem),colNodeOutType,currRow{elemIdx},elem,1);
                        elem=elem.Next;
                        elemIdx=elemIdx+1;
                    end

                    if isempty(currRow)

                        rowNodes(rowIdx)=[];
                        rowDescriptions(rowIdx)=[];
                        row=row.Next;
                        continue;
                    end

                    rowNodes{rowIdx}=currRow;
                    rowDescriptions{rowIdx}=this.getNodeDescription(row);
                    rowNodeTypeInfos(rowIdx)=internal.mtree.NodeTypeInfo(...
                    rowInTypes,thisRowOutType);


                    row=row.Next;
                    rowIdx=rowIdx+1;
                end
                numRows=numel(rowNodes);
                numCols=numel(rowNodes{1});

                if numRows==1

                    concatDimension='2';
                    out=this.GraphBuilder.createArrayConcatNode(description,...
                    rowNodeTypeInfos(1),concatDimension);


                    for idx=1:numCols
                        this.GraphBuilder.connect(rowNodes{1}{idx},{out,idx});
                    end

                elseif numCols==1

                    concatDimension='1';
                    out=this.GraphBuilder.createArrayConcatNode(description,...
                    colNodeTypeInfo,concatDimension);


                    for idx=1:numRows
                        this.GraphBuilder.connect(rowNodes{idx}{1},{out,idx});
                    end
                else


                    concatBlocks=cell(1,numRows);

                    for idx=1:numRows

                        concatBlocks{idx}=this.GraphBuilder.createArrayConcatNode(rowDescriptions{idx},...
                        rowNodeTypeInfos(idx),'2');


                        for ydx=1:numCols
                            this.GraphBuilder.connect(rowNodes{idx}{ydx},{concatBlocks{idx},ydx});
                        end
                    end


                    out=this.GraphBuilder.createArrayConcatNode(description,...
                    colNodeTypeInfo,'1');



                    for idx=1:numRows
                        this.GraphBuilder.connect(concatBlocks{idx},{out,idx});
                    end
                end
            else
                lhsArgs=row;
                if~isempty(lhsArgs)
                    out=this.visitNodeList(lhsArgs,in);
                end
            end
        end

        function out=visitIF(this,node,in)

            out=[];



            numPersistentBlocks=0;
            numConditionBlocks=0;
            conditionNode=node.Arg;

            while~isempty(conditionNode)
                if ismember(conditionNode.kind,{'IFHEAD','ELSEIF'})&&...
                    internal.mtree.isPersistentInitCondition(...
                    this.PersistentVars,conditionNode.Left)
                    numPersistentBlocks=numPersistentBlocks+1;
                else
                    numConditionBlocks=numConditionBlocks+1;
                end
                conditionNode=conditionNode.Next;
            end

            this.assert(numPersistentBlocks==0||numConditionBlocks==0,...
            ['mixing of persistent initialization and control-flow '...
            ,'conditionals is not supported']);
            this.assert(numPersistentBlocks==0||numPersistentBlocks==1,...
            ['no more than one persistent initialization block is '...
            ,'supported per IF construct']);

            if numPersistentBlocks==1

                conditionNode=node.Arg;
                assert(strcmp(conditionNode.kind,'IFHEAD')&&...
                isempty(conditionNode.Next));
                this.processInitialConditionBlock(conditionNode.Body,in);
                return;
            end


            conditionBlockDescriptions=cell(1,numConditionBlocks);
            conditionBlockControls=cell(1,numConditionBlocks);
            conditionBlockControlTypes=repmat(internal.mtree.type.UnknownType,1,numConditionBlocks);
            conditionBlockScopes=cell(1,numConditionBlocks);




            conditionNode=node.Arg;
            idx=1;
            while~isempty(conditionNode)
                if ismember(conditionNode.kind,{'IFHEAD','ELSEIF'})
                    [isCondConst,conditionVal]=this.evalExpression(conditionNode.Left);
                    if isCondConst
                        if conditionVal
                            conditionBlockDescriptions{idx}=...
                            this.getNodeDescription(conditionNode.Left,conditionNode.kind);




                            conditionBlockScopes{idx}=this.beginScope;
                            this.visitNodeList(conditionNode.Body,in);
                            this.endScope;




                            idx=idx+1;
                            break
                        else





                            conditionNode=conditionNode.Next;
                            continue
                        end
                    else
                        conditionBlockDescriptions{idx}=...
                        this.getNodeDescription(conditionNode.Left,conditionNode.kind);
                        conditionBlockControls{idx}=this.visit(conditionNode.Left,in);
                        conditionBlockControlTypes(idx)=this.getType(conditionNode.Left);

                        conditionBlockScopes{idx}=this.beginScope;
                        this.visitNodeList(conditionNode.Body,in);
                        this.endScope;

                        idx=idx+1;
                    end
                else
                    conditionBlockDescriptions{idx}=...
                    this.getNodeDescription(conditionNode,conditionNode.kind);


                    conditionBlockScopes{idx}=this.beginScope;
                    this.visitNodeList(conditionNode.Body,in);
                    this.endScope;

                    idx=idx+1;
                end

                conditionNode=conditionNode.Next;
            end


            conditionBlockDescriptions(idx:end)=[];
            conditionBlockControls(idx:end)=[];
            conditionBlockControlTypes(idx:end)=[];
            conditionBlockScopes(idx:end)=[];

            this.processConditionalBlocks(conditionBlockDescriptions,...
            conditionBlockControls,conditionBlockControlTypes,conditionBlockScopes);
        end

        function processInitialConditionBlock(this,blockBody,in)


            initialConditionScope=this.beginScope;
            this.visitNodeList(blockBody,in);
            this.endScope;

            vars=initialConditionScope.getVariables();
            for i=1:numel(vars)
                var=vars{i};

                if this.PersistentVars.isKey(var)

                    [initialCondition,initialType]=initialConditionScope.getNode(var);

                    this.assert(isa(initialCondition,'internal.mtree.Constant'),...
                    sprintf('could not reduce the initial value of %s to a constant',var));

                    persistentVarNode=this.PersistentVars(var);
                    if isempty(persistentVarNode)



                        persistentVarNode=initialCondition;




                    end
                    this.PersistentVarsInitialValues(var)=initialCondition;
                    this.setNode(var,persistentVarNode,initialType);
                else




                    this.assert(isempty(this.getNode(var)),...
                    sprintf('non-local non-persistent variable %s modified during initial condition block',var));
                end
            end
        end

        function processConditionalBlocks(this,blockDescriptions,blockControls,blockControlsTypes,blockScopes)

            if isempty(blockDescriptions)
                return
            end









            varsInAnyConditional={};
            varsInAllConditionals=blockScopes{1}.getVariables;
            for i=1:numel(blockScopes)
                varsInAnyConditional=union(varsInAnyConditional,blockScopes{i}.getVariables);
                varsInAllConditionals=intersect(varsInAllConditionals,blockScopes{i}.getVariables);
            end




            j=0;
            varsToProcess=cell(1,numel(varsInAnyConditional));

            for i=1:numel(varsInAnyConditional)
                var=varsInAnyConditional{i};

                initialVarNode=this.getNode(var);

                if~isempty(initialVarNode)
                    j=j+1;
                    varsToProcess{j}=var;
                end
            end
            varsToProcess(j+1:end)=[];



            singlePossibleBranch=numel(blockControls)==1&&isempty(blockControls{1});











            initialScope=this.beginScope;
            this.endScope;

            if~isempty(blockControls{end})
                conditionalScopes=blockScopes;
                elseScope=initialScope;
            else
                varsToProcess=union(varsToProcess,varsInAllConditionals);
                conditionalScopes=blockScopes(1:end-1);
                elseScope=blockScopes{end};
            end

            for i=1:numel(varsToProcess)
                var=varsToProcess{i};

                if~singlePossibleBranch





                    [ifFalseVarNode,varType]=elseScope.getNode(var);

                    for j=numel(conditionalScopes):-1:1


                        assert(~isempty(blockControls{j}));

                        currScope=conditionalScopes{j};
                        ifTrueVarNode=currScope.getNode(var);



                        controlType=blockControlsTypes(j);
                        typeInfo=internal.mtree.NodeTypeInfo([varType,controlType,varType],varType);

                        switchNode=this.GraphBuilder.createSwitchNode(...
                        blockDescriptions{j},typeInfo,'u2 ~= 0');
                        this.GraphBuilder.connect(ifTrueVarNode,{switchNode,1});
                        this.GraphBuilder.connect(blockControls{j},{switchNode,2});
                        this.GraphBuilder.connect(ifFalseVarNode,{switchNode,3});



                        ifFalseVarNode=switchNode;
                    end


                    this.setNode(var,ifFalseVarNode,varType);

                else


                    assert(isempty(conditionalScopes));
                    [varNode,varType]=elseScope.getNode(var);
                    this.setNode(var,varNode,varType);
                end
            end
        end

        function output=visitCOMMENT(this,node,~)
            commentStr=node.tree2str;


            isFunctionComment=false;
            if(strcmp(node.Parent.kind,'FUNCTION'))
                isFunctionComment=true;
            end
            this.constructUserComment(commentStr,isFunctionComment);
            output=[];
        end

        function constructUserComment(this,newComment,isFunctionComment)
            if~this.GraphBuilder.generateUserComments


                return
            end


            if isempty(this.UserComment)
                this.IsUserCommentTopLvl=isFunctionComment;
            end


            if~isempty(newComment)

                newComment=newComment(2:end);
                prevComment=this.UserComment;
                this.UserComment=[prevComment,newComment,newline];
            end
        end

        function comment=getUserComment(this,isaConst)
            if nargin<2
                isaConst=false;
            end
            comment='';
            if this.IsUserCommentTopLvl


                this.GraphBuilder.setUserCommentForFunction(this.UserComment);
                this.UserComment='';

                this.IsUserCommentTopLvl=false;
            elseif~isaConst


                comment=this.UserComment;
                this.UserComment='';
            end
        end

        function[isMultiOut,multiOutLength]=isMultiOutNode(this,node)


            desc=internal.mtree.getVarDesc(node,this.FcnTypeInfo);
            isMultiOut=desc.isNodeDesc;
            if isMultiOut
                multiOutLength=desc.getLength;
            else
                multiOutLength=[];
            end

        end

    end

    methods(Access='protected')
        function type=getType(this,node,idx)

            if nargin<3
                idx=1;
            end


            [~,~,descriptor]=this.evalExpression(node);

            if isa(descriptor,'internal.mtree.analysis.VariableDescriptor')

                assert(idx==1,'there is only one output to this node');

                type=descriptor.type;
            elseif nargin>=3

                type=descriptor{idx}.type;
            else

                numTypes=numel(descriptor);

                type(1,numTypes)=descriptor{numTypes}.type;
                for ii=1:numTypes-1

                    type(ii)=descriptor{ii}.type;
                end
            end
        end

        function[isConst_return,value_return,desc_return]=evalExpression(this,node)


            isConst_return=cell(0,0);
            value_return=cell(0,0);
            desc_return=cell(0,0);

            desc=internal.mtree.getVarDesc(node,this.FcnTypeInfo);

            if desc.isNodeDesc

                varLength=desc.getLength;
                assert(varLength>1,'NodeDescriptor object only contains a single VariableDescriptor');
            elseif desc.isListDesc

                isConst_return=false;
                value_return=[];
                desc_return=desc;
                return;
            else

                varLength=1;
            end

            for idx=1:varLength
                if varLength>1

                    varDesc=desc.getVarDesc(idx);
                else

                    varDesc=desc;
                end

                if varDesc.isLoopDesc


                    iter=this.getLocalIteration;
                    assert(~isempty(iter)&&iter(end)~=0,'unrolled variable found without loop info');

                    varDesc=varDesc.getVarDesc(iter);
                    assert(~isempty(varDesc),...
                    'variable description not found for the specified loop iteration');
                end

                if varDesc.isConst
                    isConst=true;
                    value=varDesc.constVal;
                else
                    isConst=false;
                    value=[];
                end

                if isConst
                    type=varDesc.type;
                    if type.isSystemObject



                        assert(strcmp(class(value),type.ClassName)||...
                        (isa(value,'comm.ViterbiDecoder')&&strcmp(type.ClassName,'commcodegen.ViterbiDecoder')),...
                        'System object inferred type and evaluated type are not equal.');
                    elseif type.isFunctionHandle
                        assert(strcmp(func2str(value),func2str(type.getExampleValue)),...
                        'Function Handle inferred function and evaluated function are not the same.');
                    else


                        if isstruct(value)&&isempty(fields(value))
                            value=type.getExampleValue;
                        end
                        value=type.castValueToType(value);
                    end
                end


                if varLength==1



                    isConst_return=isConst;
                    value_return=value;
                    desc_return=varDesc;
                else

                    isConst_return{idx}=isConst;
                    value_return{idx}=value;
                    desc_return{idx}=varDesc;
                end
            end
        end

        function val=isNodeConditional(this,node)

            [~,~,descriptor]=this.evalExpression(node);

            if iscell(descriptor)


                descriptor=descriptor{1};
            end

            val=descriptor.isConditionallyExecuted;
        end

        function const=createConstant(this,node,val,name)
            if nargin<4
                name=strtrim(node.tree2str(0,1));
            end
            description=this.getNodeDescription(node,'',true);
            const=internal.mtree.Constant(description,val,name);
        end

        function assert(this,varargin)
            builtin('assert',varargin{:});
            if this.Debug


            end
        end

        function printMessage(this,varargin)
            if this.PrintMessages
                disp(varargin{:});
            end
        end

        function[rhsType,rhsGraphNode,lhsNum]=resolveTypesForAssignment(this,rhsType,lhsType,rhsGraphNode,lhsNode,lhsNum)



            if~lhsType.isTypeEqual(rhsType)

                newRhsType=lhsType.copy;
                newRhsType.setDimensions(rhsType.Dimensions);

                if isa(rhsGraphNode,'internal.mtree.Constant')

                    rhsGraphNode=internal.mtree.Constant(...
                    rhsGraphNode.Description,newRhsType.castValueToType(rhsGraphNode.Value),rhsGraphNode.Name);
                else

                    dtcNodeTypeInfo=internal.mtree.NodeTypeInfo(rhsType,newRhsType);
                    dtcNode=this.GraphBuilder.createDTCNode(this.getNodeDescription(lhsNode),dtcNodeTypeInfo);

                    if~iscell(rhsGraphNode)


                        rhsGraphNode={rhsGraphNode,lhsNum};
                    end

                    this.GraphBuilder.connect(rhsGraphNode,dtcNode);

                    rhsGraphNode=dtcNode;



                    lhsNum=1;
                end
                rhsType=newRhsType;
            end
        end

        function[nodeTypeInfo,op1,op2]=handleFunctionalBinExprTypeDiff(this,node,in)
            arg1=node.Right;
            arg2=arg1.Next;
            arg3=arg2.Next;
            assert(~isempty(arg1)&&~isempty(arg2)&&isempty(arg3),...
            'unexpected number of input arguments to functional binary expression');
            [arg1Type,arg2Type,op1,op2]=this.handleBinExprTypeDiff(in,arg1,arg2);
            nodeTypeInfo=internal.mtree.NodeTypeInfo([arg1Type,arg2Type],this.getType(node));
        end

        function[leftType,rightType,op1,op2,lhsIsConst,rhsIsConst]=handleBinExprTypeDiff(this,in,leftNode,rightNode)






            [lhsIsConst,cLeft,lhsDesc]=this.evalExpression(leftNode);
            [rhsIsConst,cRight,rhsDesc]=this.evalExpression(rightNode);
            leftType=lhsDesc.type;
            rightType=rhsDesc.type;
            parentNode=leftNode.Parent;

            typeValidation=@(constType,nonConstType)...
            ((~constType.isFi&&nonConstType.isFi)||...
            (~constType.isSingle&&nonConstType.isSingle)||...
            (constType.isDouble&&(~nonConstType.isDouble&&~nonConstType.isLogical)));

            if lhsIsConst&&~rhsIsConst&&typeValidation(leftType,rightType)

                [cLeft,leftType]=internal.ml2pir.utils.castConstant(...
                cLeft,leftType,rightType,parentNode,true);

                op1=this.createConstant(leftNode,cLeft);
                op2=this.visit(rightNode,in);
            elseif~lhsIsConst&&rhsIsConst&&typeValidation(rightType,leftType)
                op1=this.visit(leftNode,in);

                [cRight,rightType]=internal.ml2pir.utils.castConstant(...
                cRight,rightType,leftType,parentNode,false);
                op2=this.createConstant(rightNode,cRight);
            else
                op1=this.visit(leftNode,in);
                op2=this.visit(rightNode,in);
            end
        end

        function[indexArray,nonConstIdxTypes,nonConstIdxNodes,isLinearIndexing]=...
            getIndexInfoFromSubscrNode(this,subscrNode,matrixType,in)

















            index=subscrNode.Right;
            numIndices=count(index.List);


            indexArray=cell(1,numIndices);
            indexArrayIdx=1;
            nonConstIdxTypes=repmat(internal.mtree.type.UnknownType,1,numIndices);
            nonConstIdxNodes=cell(1,numIndices);
            nonConstIdx=1;

            isLinearIndexing=numIndices==1;

            while~isempty(index)
                if strcmp(index.kind,'COLON')&&isempty(index.Left)&&isempty(index.Right)



                    nonConstIdxTypes(nonConstIdx)=[];
                    nonConstIdxNodes(nonConstIdx)=[];
                else


                    oldEndValue=this.EndValue;
                    if isLinearIndexing
                        this.EndValue=prod(matrixType.Dimensions);
                    elseif indexArrayIdx>numel(matrixType.Dimensions)
                        this.EndValue=1;
                    else
                        this.EndValue=matrixType.Dimensions(indexArrayIdx);
                    end

                    [isConst,indexVal]=this.evalExpression(index);

                    if~isConst

                        nonConstIdxTypes(nonConstIdx)=this.getType(index);
                        nonConstIdxNodes{nonConstIdx}=this.visit(index,in);

                        indexArray{indexArrayIdx}=nonConstIdxTypes(nonConstIdx);
                        nonConstIdx=nonConstIdx+1;
                    else

                        indexArray{indexArrayIdx}=this.createConstant(index,indexVal);

                        nonConstIdxTypes(nonConstIdx)=[];
                        nonConstIdxNodes(nonConstIdx)=[];
                    end

                    this.EndValue=oldEndValue;
                end

                indexArrayIdx=indexArrayIdx+1;
                index=index.Next;
            end

            if isLinearIndexing&&matrixType.isScalar&&this.getType(subscrNode.Right).isRowVector



                indexArray=[{[]},indexArray];
                isLinearIndexing=false;
            end



            for ii=1:length(indexArray)
                if isa(indexArray{ii},'internal.mtree.Constant')...
                    &&isa(indexArray{ii}.Value,'double')...
                    &&~isempty(indexArray{ii}.Value)
                    indexArray{ii}=internal.mtree.Constant.CastDoubleToUnsingedInteger(indexArray{ii});
                end
            end
        end

        function[matrixNode,matrixType]=reshapeSubscriptedMatrix(...
            this,mtreeNode,matrixNode,matrixType,isLinearIndexing)
            if isLinearIndexing&&~(matrixType.is2DVector||matrixType.isScalar)


                reshapedMatrixType=matrixType.copy;
                reshapedMatrixType.setDimensions([1,prod(matrixType.Dimensions)]);
                reshapeTypeInfo=internal.mtree.NodeTypeInfo(matrixType,...
                reshapedMatrixType);

                reshapeNode=this.GraphBuilder.createReshapeNode(this.getNodeDescription(mtreeNode),...
                reshapeTypeInfo);
                this.GraphBuilder.connect(matrixNode,reshapeNode);
                matrixNode=reshapeNode;
                matrixType=reshapedMatrixType;
            end
        end

        function[nonConstIdxNodes,indexArray,nonConstIdxTypes,selectedType]=reshapeSubscrIndexing(...
            this,nonConstIdxNodes,indexArray,nonConstIdxTypes,selectedType,isLinearIndexing)
            if isLinearIndexing&&selectedType.isMatrix


                selectedTypeFlat=selectedType.copy;
                selectedTypeFlat.setDimensions([prod(selectedType.Dimensions),1]);

                selectedType=selectedTypeFlat;
            end


            nonConstIdx=1;
            for ii=1:numel(indexArray)
                if isempty(indexArray{ii})

                elseif isa(indexArray{ii},'internal.mtree.Constant')

                    indexArray{ii}.Value=indexArray{ii}.Value(:);
                elseif indexArray{ii}.isMatrix


                    idxType=indexArray{ii};
                    flatIdxType=idxType.copy;
                    flatIdxType.setDimensions([prod(flatIdxType.Dimensions),1]);
                    reshapeTypeInfo=internal.mtree.NodeTypeInfo(idxType,...
                    flatIdxType);
                    reshapeNode=this.GraphBuilder.createReshapeNode('(:)',...
                    reshapeTypeInfo);
                    this.GraphBuilder.connect(nonConstIdxNodes{nonConstIdx},reshapeNode);

                    nonConstIdxNodes{nonConstIdx}=reshapeNode;
                    nonConstIdxTypes(nonConstIdx)=flatIdxType;

                    nonConstIdx=nonConstIdx+1;
                end
            end
        end

        function graphNode=reshapeToType(...
            this,graphNode,node,outType,origOutType)
            if~isequal(outType,origOutType)

                reshapeBackTypeInfo=internal.mtree.NodeTypeInfo(...
                outType,origOutType);
                reshapeBackNode=this.GraphBuilder.createReshapeNode(...
                this.getNodeDescription(node),reshapeBackTypeInfo);

                this.GraphBuilder.connect(graphNode,{reshapeBackNode,1});
                graphNode=reshapeBackNode;
            end
        end

    end

    methods(Static)

        function s=getConversionSettings()
            persistent settings

            if isempty(settings)
                settings.SimGenMode=internal.ml2pir.simgen.SimGenMode.Default;
            end

            s=settings;
        end
        function s=breakAtNode(newStr)
            persistent pStr
            if isempty(pStr)
                pStr=' ';
            end
            if nargin==1
                pStr=newStr;
            end
            s=pStr;
        end

    end
end








