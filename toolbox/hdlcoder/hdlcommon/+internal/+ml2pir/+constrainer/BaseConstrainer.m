




classdef(Abstract)BaseConstrainer<internal.ml2pir.constrainer.BaseVisitor

    properties(Access=protected)
functionTypeInfo
functionInfoRegistry


persistentVars
    end

    properties(Abstract,Access=protected)


typeMsgID
    end

    methods(Abstract,Access=protected)
        isSupported=fcnSupported(this,fcnName);
        checkFunctionCall(this,node,calleeFcnInfo);
    end

    methods(Access=public)

        function this=BaseConstrainer(fcnTypeInfo,exprMap,fcnInfoRegistry)
            this=this@internal.ml2pir.constrainer.BaseVisitor(fcnTypeInfo.tree);
            this.functionTypeInfo=fcnTypeInfo;
            this.functionInfoRegistry=fcnInfoRegistry;

            this.persistentVars=containers.Map;



            if~isempty(exprMap)&&exprMap.isKey(this.functionTypeInfo.uniqueId)
                compiledExprInfo=exprMap(this.functionTypeInfo.uniqueId);
            else
                compiledExprInfo=coder.internal.lib.Map.empty;
            end
            constrainer=coder.internal.Float2FixedConstrainer(this.functionTypeInfo.tree,...
            this.functionTypeInfo,this.functionTypeInfo.scriptPath,false,false,[]);
            constrainer.setCompiledExprInfo(compiledExprInfo);
            constrainer.constrain();
        end

    end

    methods(Access=protected)


        function addMessage(this,node,msgType,msgID,varargin)

            for i=1:numel(varargin)
                if ischar(varargin{i})
                    varargin{i}=strtrim(varargin{i});
                end
            end

            msg=internal.mtree.Message(...
            this.functionTypeInfo,...
            node,...
            msgType,...
            msgID,...
            varargin{:});
            this.messages=[this.messages,msg];
        end



        function varDesc=getVarDesc(this,node,fcnTypeInfo)
            if nargin<3
                fcnTypeInfo=this.functionTypeInfo;
            end

            varDesc=internal.mtree.getVarDesc(node,fcnTypeInfo,'treeAttributesAggregate');
        end

        function isit=treatAsFunctionCall(this,node)
            switch node.kind
            case 'CALL'
                isit=true;

            case{'SUBSCR','DOT'}
                if strcmp(node.kind,'SUBSCR')
                    fcnIdNode=node.Left;
                else
                    fcnIdNode=node;
                end

                isit=(this.getType(fcnIdNode).isUnknown&&...
                this.fcnSupported(fcnIdNode.tree2str))||...
                internal.mtree.isFunctionCallNode(node,this.functionTypeInfo);

            otherwise
                isit=false;
            end
        end

        function type=getType(this,node,fcnTypeInfo)
            if nargin<3
                fcnTypeInfo=this.functionTypeInfo;
            end

            desc=this.getVarDesc(node,fcnTypeInfo);
            if isa(desc,'internal.mtree.analysis.NodeDescriptor')

                type=desc.getVarDesc(1).type;
            else
                type=desc.type;
            end
        end

        function val=isConst(this,node)
            val=this.getVarDesc(node).isConst;
        end

        function val=isNodeConditional(this,node)
            val=this.getVarDesc(node).isConditionallyExecuted;
        end

    end

    methods(Access=protected)



        function visit(this,node)
            if~isempty(node)



                passed=this.checkTypeConstAndNonConst(node);

                if passed
                    desc=this.getVarDesc(node);

                    if isa(desc,'internal.mtree.analysis.VariableDescriptor')&&...
                        desc.type.isSystemObject




                        sysObjInstance=desc.constVal;
                        if~isempty(sysObjInstance)

                            sysObjInstance=sysObjInstance{1};
                        end
                        this.checkSystemObject(node,sysObjInstance);
                    elseif~desc.isConst||(strcmp(node.kind,'CELL')&&desc.isNodeDesc)























                        this.checkTypeNonConst(node);

                        this.visit@internal.ml2pir.constrainer.BaseVisitor(node)
                    end
                end
            end
        end

        function visitSWITCH(this,node)
            this.preProcessSWITCH(node);
            this.visit(node.Left)



            conditionNode=node.Body;
            while~isempty(conditionNode)
                switch conditionNode.kind
                case 'CASE'
                    caseDesc=this.getVarDesc(conditionNode);
                    if~caseDesc.isConst

                        this.visit(conditionNode);
                    elseif caseDesc.constVal{1}



                        this.visit(conditionNode);
                        break;
                    else

                    end
                case 'OTHERWISE'

                    this.visit(conditionNode);
                otherwise

                    this.visit(conditionNode);
                end
                conditionNode=conditionNode.Next;
            end
        end




        function visitCASE(this,node)
            this.preProcessCASE(node)



            caseNode=node.Left;
            if strcmp(caseNode.kind,'LC')
                this.visitNodeList(caseNode.Arg);
            else
                this.visit(caseNode);
            end

            this.visitNodeList(node.Body)
        end

        function visitIF(this,node)
            this.preProcessIF(node);
            conditionNode=node.Arg;
            while~isempty(conditionNode)
                switch conditionNode.kind


                case{'IFHEAD','ELSEIF'}
                    conditionDesc=this.getVarDesc(conditionNode.Left);
                    if conditionDesc.isConst
                        if conditionDesc.constVal{1}



                            this.visit(conditionNode)
                            break;
                        else



                        end
                    else


                        this.visit(conditionNode);
                    end
                otherwise


                    this.visit(conditionNode);
                end
                conditionNode=conditionNode.Next;
            end
        end



        function visitFOR(this,node)
            this.preProcessFOR(node);
            this.visit(node.Index);
            this.visit(node.Vector);


            vectorDesc=this.getVarDesc(node.Vector);
            if~(vectorDesc.isConst&&isempty(vectorDesc.constVal{1}))
                this.visitNodeList(node.Body);
            end
        end
    end

    methods(Access=protected)



        function preProcessAND(this,node)%#ok<INUSD>

        end

        function preProcessANDAND(this,node)%#ok<INUSD>

        end

        function preProcessCALL(this,node)
            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(node);
            userWrittenFcn=~isempty(calleeFcnInfo);

            if userWrittenFcn




                numArgsProvided=count(node.Right.List);
                arg=node.Right;
                while~isempty(arg)

                    argDesc=this.getVarDesc(node.Right);
                    if argDesc.isNodeDesc
                        numArgsProvided=numArgsProvided+argDesc.getLength-1;
                    end
                    arg=arg.Next;
                end


                numArgsExpected=count(calleeFcnInfo.tree.Ins.List);



                arg=calleeFcnInfo.tree.Ins;
                if~isempty(arg)
                    while~isempty(arg.Next)
                        arg=arg.Next;
                    end

                    if strcmp(arg.tree2str,'varargin')
                        numArgsExpected=numArgsExpected-1;
                    end
                end

                if numArgsProvided<numArgsExpected
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:FewerThanExpectedArgs',...
                    calleeFcnInfo.functionName,...
                    num2str(numArgsExpected),...
                    node.tree2str,...
                    num2str(numArgsProvided));
                end



                if internal.mtree.isTranslatableInternalFunction(calleeFcnInfo.scriptPath)
                    this.checkFunctionCall(node,calleeFcnInfo);
                end












            elseif strcmp(node.Left.kind,'ID')||this.treatAsFunctionCall(node)





                this.checkFunctionCall(node);
            end
        end

        function preProcessCASE(this,node)%#ok<INUSD>

        end

        function preProcessCHARVECTOR(~,~)

        end

        function preProcessCOLON(this,node,~,~,~)
            if~this.isConst(node)
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:NonConstantColon',...
                node.tree2str);
            end
        end

        function preProcessDIV(this,node)

            this.checkIsScalar(node.Right,'hdlcommon:matlab2dataflow:NonScalarDivisor');
        end

        function preProcessDOTDIV(this,node)%#ok<INUSD>

        end

        function preProcessDOTEXP(this,node)%#ok<INUSD>

        end

        function preProcessDOTMUL(this,node)%#ok<INUSD>

        end

        function preProcessDOTTRANS(this,node)%#ok<INUSD>

        end

        function preProcessDOUBLE(~,~)

        end

        function preProcessELSEIF(this,node)%#ok<INUSD>

        end

        function preProcessEQ(this,node)%#ok<INUSD>

        end

        function preProcessEQUALS(~,~)

        end

        function preProcessNAMEVALUE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:NameValueSyntaxNotSupported',...
            node.trueparent.tree2str(0,1),...
            node.tree2str(0,1));
        end

        function preProcessEXP(this,node)

            this.checkIsScalar(node.Left,'hdlcommon:matlab2dataflow:NonScalarExpArg');
            this.checkIsScalar(node.Right,'hdlcommon:matlab2dataflow:NonScalarExpArg');
        end

        function preProcessEXPR(~,~)

        end

        function preProcessDOT(this,node)
            if this.treatAsFunctionCall(node)
                this.preProcessCALL(node);
            else

                lExprType=this.getType(node.Left);
                lExprString=node.Left.tree2str;
                propN=node.Right.tree2str;
                exprString=node.tree2str;
                this.checkFieldDotAccess(node,lExprType,exprString,lExprString,propN);
            end
        end

        function preProcessDOTLP(this,node)

            lExprType=this.getType(node.Left);
            if lExprType.isStructType
                this.preProcessDOT(node);
            else
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                this.defaultMsgID,...
                node.tree2str);
            end
        end

        function preProcessFIELD(~,~)

        end

        function preProcessFUNCTION(this,node)

            this.checkForRecursion();


            this.checkForNestedFunctions(node);


            this.checkForMultipleEntryPoints(node);


            inp=node.Ins;
            while~isempty(inp)
                if~strcmp(inp.kind,'ID')
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:IgnoredInputArg',...
                    node.Fname.string);
                    break;
                end

                inp=inp.Next;
            end



            if this.functionTypeInfo.isDesign&&~isempty(node.Ins)
                inputIndices=node.Ins.List.indices;
                lastInputIdx=inputIndices(end);
                lastInputNode=node.Ins.List.select(lastInputIdx);

                if strcmp(lastInputNode.kind,'ID')&&strcmp(lastInputNode.string,'varargin')
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:VararginTopLevelNotSupported',...
                    node.Fname.string);
                end
            end


            if~isempty(node.Outs)
                outputIndices=node.Outs.List.indices;
                lastOutputIdx=outputIndices(end);
                lastOutputNode=node.Outs.List.select(lastOutputIdx);

                if strcmp(lastOutputNode.kind,'ID')&&strcmp(lastOutputNode.string,'varargout')
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:VarargoutNotSupported',...
                    node.Fname.string);
                end
            end
        end

        function preProcessGE(this,node)%#ok<INUSD>

        end

        function preProcessGT(this,node)%#ok<INUSD>

        end

        function preProcessFOR(this,node)
            if~this.isConst(node.Vector)
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:ForLoopIterationsNotConstant',...
                node.Vector.Parent.tree2str);
            end
        end

        function preProcessIFHEAD(this,node)%#ok<INUSD>

        end

        function preProcessINT(~,~)

        end

        function preProcessID(~,~)

        end

        function preProcessIF(this,node)


























            numPersInitConditions=0;
            numNonPersInitConditions=0;

            conditionNode=node.Arg;
            while~isempty(conditionNode)
                if this.isPersistentInitCondition(conditionNode.Left)
                    numPersInitConditions=numPersInitConditions+1;



                    initStmt=conditionNode.Body;
                    while~isempty(initStmt)
                        if~ismember(initStmt.kind,{'BLKCOM','CELLMARK','COMMENT'})
                            this.checkPersistentInitStatement(initStmt);
                        end
                        initStmt=initStmt.Next;
                    end
                else
                    numNonPersInitConditions=numNonPersInitConditions+1;
                end

                conditionNode=conditionNode.Next;
            end



            numTotalConditions=numPersInitConditions+numNonPersInitConditions;
            if numPersInitConditions>0&&numTotalConditions>1
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:InitStatementNotAlone');
            end
        end

        function preProcessLB(this,node)%#ok<INUSD>

        end

        function preProcessMultipleAssign(this,node)%#ok<INUSD>

        end

        function preProcessIgnoredVar(this,node)%#ok<INUSD>

        end

        function preProcessLE(this,node)%#ok<INUSD>

        end

        function preProcessLT(this,node)%#ok<INUSD>

        end

        function preProcessMINUS(this,node)%#ok<INUSD>

        end

        function preProcessMUL(this,node)%#ok<INUSD>

        end

        function preProcessNE(this,node)%#ok<INUSD>

        end

        function preProcessNOT(this,node)%#ok<INUSD>

        end

        function preProcessOR(this,node)%#ok<INUSD>

        end

        function preProcessOROR(this,node)%#ok<INUSD>

        end

        function preProcessPARENS(~,~)

        end

        function preProcessPERSISTENT(this,node)


            varNode=node.Arg;
            while~isempty(varNode)
                persName=varNode.string;

                this.persistentVars(persName)=[];






                type=this.getType(varNode);
                if~(type.isNumeric||type.isLogical||...
                    type.isSystemObject||type.isUnknown)
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:PersistentUnsupportedType',...
                    persName,...
                    type.getMLName);
                end

                varNode=varNode.Next;
            end



            calledOnce=this.checkCalledOnce(this.functionTypeInfo);
            if~calledOnce
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:PersistentInSubFunctions',...
                node.tree2str);
            end
        end

        function preProcessPLUS(this,node)%#ok<INUSD>

        end

        function preProcessPRINT(~,~)

        end

        function preProcessSTRING(~,~)

        end

        function preProcessSUBSCR(this,node)
            if this.treatAsFunctionCall(node)

                if strcmp(node.Left.kind,'DOT')
                    leftNodeType=this.getType(node.Left.Left);

                    if isSystemObject(leftNodeType)&&strcmp(node.Left.Right.string,'step')
                        this.addMessage(node,...
                        internal.mtree.MessageType.Error,...
                        'hdlcommon:matlab2dataflow:UnsupportedDotNotation');
                    end
                end
                this.preProcessCALL(node);
            else

                idxNode=node.Right;

                while~isempty(idxNode)
                    idxType=this.getType(idxNode);

                    if idxType.isLogical
                        this.addMessage(node,...
                        internal.mtree.MessageType.Error,...
                        'hdlcommon:matlab2dataflow:LogicalIndexing',...
                        node.tree2str);
                        break;
                    end

                    idxNode=idxNode.Next;
                end
            end
        end

        function preProcessCELL(this,node)

            if internal.mtree.isSubsasgnNode(node)
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:CellArrayInvalidAssignment',...
                node.tree2str);
            end

            threwLogicalIndexingMsg=false;

            idxArg=node.Right;
            while~isempty(idxArg)
                idxType=this.getType(idxArg);


                if~this.isConst(idxArg)
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:CellArrayNonConstantIndex',...
                    node.tree2str,idxArg.tree2str);
                end


                if~idxType.isScalar
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:CellArrayNonScalarIndex',...
                    node.tree2str,idxArg.tree2str);
                end

                if idxType.isLogical&&~threwLogicalIndexingMsg
                    threwLogicalIndexingMsg=true;
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:LogicalIndexing',...
                    node.tree2str);
                end

                idxArg=idxArg.Next;
            end
        end

        function preProcessSWITCH(this,node)%#ok<INUSD>

        end

        function preProcessTRANS(this,node)%#ok<INUSD>

        end

        function preProcessUMINUS(this,node)%#ok<INUSD>

        end

        function preProcessUPLUS(this,node)%#ok<INUSD>

        end

        function preProcessANONID(~,~)



        end

        function preProcessANON(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:AnonymousFunctionNotSupported',...
            node.tree2str);
        end

    end

    methods(Access=protected)




        function checkSystemObject(~,~)

        end

    end

    methods(Access=private)




        function checkFieldDotAccess(this,node,lExprType,exprString,~,propName)
            supportedFiPropNames={'WordLength','FractionLength'};



            if lExprType.isFi()||(lExprType.isUnknown()&&ismember(propName,supportedFiPropNames))

            elseif strcmp(lExprType.getMLName,'struct')

            else
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                this.defaultMsgID,...
                exprString);
            end
        end


        function checkForRecursion(this)
            isEntryPoint=this.functionTypeInfo.isDesign;

            if isEntryPoint
                rCalls=this.functionTypeInfo.getRecursiveCalls();



                for cc=1:numel(rCalls)
                    rCall=rCalls(cc);
                    this.addMessage(rCall.Node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:RecursiveFunctionCall',...
                    rCall.Callee.functionName);
                end
            end
        end


        function checkForNestedFunctions(this,fcnNode)
            tmpN=string(fcnNode.Fname);
            nesteeFcnN=this.functionTypeInfo.functionName;



            if strcmp(nesteeFcnN,tmpN)
                fcnNodes=fcnNode.subtree.mtfind('Kind','FUNCTION');
                indices=fcnNodes.indices;
                if length(indices)==1

                    return;
                end

                for ii=2:2
                    idx=indices(ii);
                    fcnNode=fcnNodes.select(idx);
                    nestedFcnN=string(fcnNode.Fname);

                    this.addMessage(fcnNode,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:NestedFcnNotSupported',...
                    nestedFcnN,...
                    nesteeFcnN);
                end
            end
        end


        function checkForMultipleEntryPoints(this,fcnNode)
            if this.functionTypeInfo.isDesign
                allFcnInfos=this.functionInfoRegistry.getAllFunctionTypeInfos;

                numEntryPoints=0;
                for i=1:numel(allFcnInfos)
                    if allFcnInfos{i}.isDesign
                        numEntryPoints=numEntryPoints+1;



                        if numEntryPoints>1
                            break;
                        end
                    end
                end

                if numEntryPoints>1
                    this.addMessage(fcnNode,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:MultipleEntryPoints',...
                    string(fcnNode.Fname));
                end
            end
        end


        function res=checkCalledOnce(this,fcnTypeInfo)
            if fcnTypeInfo.isDesign

                res=true;
            elseif fcnTypeInfo.isASpecializedFunction


                res=false;
            else

                callsiteMtree=[];
                callingFcnTypeInfo=[];

                thisFcnId=fcnTypeInfo.uniqueId;
                infos=this.functionInfoRegistry.getAllFunctionTypeInfos;

                for i=1:numel(infos)
                    otherFcnTypeInfo=infos{i};

                    if strcmp(otherFcnTypeInfo.uniqueId,thisFcnId)


                        continue
                    end

                    fcnCallsites=otherFcnTypeInfo.callSites;

                    for j=1:numel(fcnCallsites)
                        site=fcnCallsites{j};
                        calledFcnId=site{2}.uniqueId;

                        if strcmp(calledFcnId,thisFcnId)

                            if isempty(callsiteMtree)

                                callsiteMtree=site{1};
                                callingFcnTypeInfo=otherFcnTypeInfo;
                            else


                                res=false;
                                return
                            end
                        end
                    end
                end

                if isempty(callsiteMtree)

                    res=true;
                else


                    disallowedCallsiteNodes={...
                    'IF',...
                    'SWITCH',...
                    'WHILE',...
                    'FOR',...
                    'PARFOR',...
                    'SPMD',...
                    'TRY'};
                    callsiteCtxt=trueparent(callsiteMtree);



                    while~isempty(callsiteCtxt)&&~strcmp(callsiteCtxt.kind,'FUNCTION')
                        if ismember(callsiteCtxt.kind,disallowedCallsiteNodes)
                            res=false;
                            return
                        end

                        callsiteCtxt=trueparent(callsiteCtxt);
                    end


                    res=this.checkCalledOnce(callingFcnTypeInfo);
                end
            end
        end

        function res=isPersistentInitCondition(this,node)



            if isempty(node)
                res=false;
                return
            end

            while strcmp(node.kind,'PARENS')
                node=node.Arg;
            end

            if strcmp(node.kind,'CALL')
                if strcmp(node.Left.kind,'ID')
                    fcnName=node.Left.string;
                else
                    fcnName='';
                end

                if strcmp(fcnName,'isempty')
                    arg=node.Right;
                    if isempty(arg.Next)&&this.isPersistentVar(arg)
                        res=true;
                        return
                    end
                end
            end

            res=false;
        end

        function checkPersistentInitStatement(this,stmt)
            isPersInitStmt=false;

            var=[];
            if ismember(stmt.kind,{'EXPR','PRINT'})
                eqStmt=stmt.Arg;

                if strcmp(eqStmt.kind,'EQUALS')
                    var=eqStmt.Left;

                    if this.isPersistentVar(var)
                        isPersInitStmt=true;

                        isPersInitConst=this.isConst(eqStmt.Right);
                    end

                end
            end

            if~isPersInitStmt


                this.addMessage(stmt,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:NonPersInitStmtInPersInitBlock',...
                stmt.tree2str);
            elseif~isPersInitConst
                this.addMessage(stmt,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:NonConstantPersInitVal',...
                eqStmt.Left.tree2str,...
                eqStmt.Right.tree2str);
            end

            if~isempty(var)&&strcmp(var.kind,'DOT')
                type=this.getType(var.Left);
                if type.isSystemObject




                    propName=var.Right.string;
                    if~internal.ml2pir.SystemObject2SubsystemConverter.isNontunableProp(...
                        type.ClassName,propName)
                        this.addMessage(stmt,...
                        internal.mtree.MessageType.Error,...
                        'hdlcommon:matlab2dataflow:TunablePropertySettingInPersistentInit',...
                        stmt.tree2str);
                    end
                end
            end
        end

        function res=isPersistentVar(this,node)
            if strcmp(node.kind,'ID')
                var=node.string;
                res=this.persistentVars.isKey(var);
            elseif strcmp(node.kind,'DOT')
                var=node.Left.string;
                res=this.persistentVars.isKey(var);
            else
                res=false;
            end
        end
    end

    methods(Access=protected)


        function passed=checkTypeConstAndNonConst(this,node)

            passed=true;




            info=this.functionTypeInfo.treeAttributes(node);

            if~isempty(info.CompiledMxLocInfo)
                mxInferredTypeInfo=...
                this.functionInfoRegistry.mxInfos{info.CompiledMxLocInfo.MxInfoID};
                typeInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(...
                mxInferredTypeInfo,this.functionInfoRegistry.mxArrays);

                if typeInfo.Enum
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    this.typeMsgID,...
                    'enum',...
                    node.tree2str(0,1));
                    passed=false;
                end
            end

            if~passed
                return;
            end

            nodeType=this.getType(node);

            if nodeType.isSizeDynamic

                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                'hdlcommon:matlab2dataflow:VariableSizeNotSupported',...
                node.tree2str);
                passed=false;
            end

            if nodeType.isFi
                if nodeType.isSlopeBias&&...
                    (mod(log2(nodeType.getSlope),1)~=0||...
                    nodeType.getBias~=0)

                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcoder:engine:SlopeBiasInvalidType',...
                    nodeType.Numerictype.tostring);
                    passed=false;
                elseif~nodeType.isFixed



                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:FiInvalidDataType');
                    passed=false;
                end

            elseif nodeType.isStructType

                if this.checkIsArrayStruct(nodeType)
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:ML2PIRArrayOfBusNotSupported',...
                    node.tree2str);
                    passed=false;
                end


                if this.checkIsStructFieldEmpty(nodeType)
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:StructHasEmptyField',...
                    node.tree2str);
                    passed=false;
                end
            end




            nonAggregateDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);
            passed=passed&&this.checkLoopDescHasConsistentSize(node,nonAggregateDesc);
        end

        function checkTypeNonConst(this,node)
            type=this.getType(node);



            if type.isCell
                tpNode=node.trueparent;




                while strcmp(tpNode.kind,'ETC')
                    tpNode=tpNode.trueparent;
                end

                if~ismember(tpNode.kind,{'CELL','CALL','EQUALS','FUNCTION'})
                    this.addMessage(node,...
                    internal.mtree.MessageType.Error,...
                    'hdlcommon:matlab2dataflow:CellTypeInvalidTrueParent',...
                    node.tree2str,tpNode.kind);
                end
            end


            if type.isChar
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                this.typeMsgID,...
                type.getMLName,...
                node.tree2str(0,1));
            end
        end
    end

    methods(Access=private)


        function failed=checkIsArrayStruct(this,type)


            if~(type.isScalar||type.isEmpty)
                failed=true;
                return;
            end


            failed=false;


            fieldTypes=type.getFieldTypes;
            nFields=length(fieldTypes);

            for i=1:nFields
                if fieldTypes(i).isStructType
                    failed=this.checkIsArrayStruct(fieldTypes(i));
                    if failed
                        break;
                    end
                end
            end
        end

        function failed=checkIsStructFieldEmpty(this,type)

            failed=false;


            fieldTypes=type.getFieldTypes;
            nFields=length(fieldTypes);

            for i=1:nFields
                if fieldTypes(i).isEmpty
                    failed=true;
                elseif fieldTypes(i).isStructType
                    failed=this.checkIsStructFieldEmpty(fieldTypes(i));
                end

                if failed


                    break;
                end
            end
        end

        function checkIsScalar(this,node,msgId)
            type=this.getType(node);



            if~type.isScalar&&~type.isUnknown
                this.addMessage(node,...
                internal.mtree.MessageType.Error,...
                msgId,...
                node.tree2str);
            end
        end

        function passed=checkLoopDescHasConsistentSize(this,node,desc)
            passed=true;

            if isa(desc,'internal.mtree.analysis.NodeDescriptor')

                for i=1:desc.getLength
                    innerDesc=desc.getVarDesc(i);
                    passed=passed&&this.checkLoopDescHasConsistentSize(node,innerDesc);
                end
            elseif isa(desc,'internal.mtree.analysis.VariableDescriptorLoop')


                forNode=node;
                while~isempty(forNode)&&~strcmp(forNode.kind,'FOR')
                    forNode=forNode.trueparent;
                end

                nodeIsUnderForVector=...
                ~isempty(forNode)&&ismember(node,forNode.Vector.subtree);

                if~nodeIsUnderForVector


                    type=desc.type;
                    loopTypes=getAllTypesFromLoopDesc(desc);

                    for i=1:numel(loopTypes)
                        if~isequal(type.Dimensions,loopTypes(i).Dimensions)
                            this.addMessage(node,...
                            internal.mtree.MessageType.Error,...
                            'hdlcommon:matlab2dataflow:SizeChangingValueInLoop',...
                            node.tree2str);
                            passed=false;




                            return;
                        end
                    end
                end
            end

            function types=getAllTypesFromLoopDesc(descOrMap)
                if isa(descOrMap,'internal.mtree.analysis.VariableDescriptorLoop')
                    types=getAllTypesFromLoopDesc(descOrMap.descriptors);
                elseif isa(descOrMap,'internal.mtree.analysis.VariableDescriptor')
                    types=descOrMap.type;
                else
                    assert(isa(descOrMap,'containers.Map'));
                    typesCell=cellfun(@getAllTypesFromLoopDesc,descOrMap.values,...
                    'UniformOutput',false);
                    types=[typesCell{:}];
                end
            end
        end

    end

end



