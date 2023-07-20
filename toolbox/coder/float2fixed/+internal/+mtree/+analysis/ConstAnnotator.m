classdef ConstAnnotator<coder.internal.MTreeVisitor&internal.mtree.ControlFlowManager





    methods(Static)

        function run(functionInfoRegistry,keepDeadFcns,timeout)
            import internal.mtree.analysis.ConstAnnotator.*

            if nargin<2
                keepDeadFcns=false;
            end

            if nargin<3
                timeout=inf;
            end

            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();

            topLevelAnalyzerIdx=1;
            topLevelAnalyzers=cell(1,numel(fcnTypeInfos));

            for ii=numel(fcnTypeInfos):-1:1
                functionTypeInfo=fcnTypeInfos{ii};

                analyzer=internal.mtree.analysis.ConstAnnotator(...
                functionTypeInfo,functionInfoRegistry,analyzers);
                analyzers(functionTypeInfo.uniqueId)=analyzer;

                if functionTypeInfo.isDesign
                    topLevelAnalyzers{topLevelAnalyzerIdx}=analyzer;
                    topLevelAnalyzerIdx=topLevelAnalyzerIdx+1;
                end
            end

            assert(topLevelAnalyzerIdx>1,'no entry point functions found');
            topLevelAnalyzers(topLevelAnalyzerIdx:end)=[];

            analyzers=analyzers.values();


            warnStates=warning('off','all');

            oc=onCleanup(@()warning(warnStates));

            if~isinf(timeout)
                timerObj=timer('TimerFcn',...
                @(~,~)internal.mtree.analysis.ConstAnnotator.setTimeoutReached(analyzers),...
                'StartDelay',timeout);
                cleanupObj=onCleanup(@()stopTimer(timerObj));
                timerObj.start;
            end





            runAll(topLevelAnalyzers,analyzers,keepDeadFcns);

            function stopTimer(t)
                t.stop;
                t.delete;
            end
        end
    end

    methods(Static,Access=protected)

        function runAll(topLevelAnalyzers,analyzers,keepDeadFcns)
            import internal.mtree.analysis.ConstAnnotator.*





            recurseIntoSubfuns=true;

            for i=1:numel(topLevelAnalyzers)
                topFcnTypeInfo=topLevelAnalyzers{i}.FunctionTypeInfo;
                rCalls=topFcnTypeInfo.getRecursiveCalls;

                if~isempty(rCalls)
                    recurseIntoSubfuns=false;
                    break;
                end
            end


            for i=1:numel(topLevelAnalyzers)
                topAnalyzer=topLevelAnalyzers{i};


                inputDescriptors=getInputDescriptors(topAnalyzer);


                topAnalyzer.analyze(inputDescriptors,recurseIntoSubfuns);
            end


            for i=1:numel(analyzers)
                analyzer=analyzers{i};

                if~analyzer.AnalysisHasRun
                    if~isempty(analyzer.FunctionTypeInfo.className)&&...
                        lowersysobj.isPIRSupportedObject(analyzer.FunctionTypeInfo.className)

                        continue;
                    elseif~recurseIntoSubfuns


                        inputDescriptors=getInputDescriptors(analyzer,'INDETERMINABLE_IF_CONST');
                        analyzer.setAttributesProperties(true);
                        analyzer.analyze(inputDescriptors,recurseIntoSubfuns);
                    elseif~keepDeadFcns



                        analyzer.FunctionInfoRegistry.registry.remove(analyzer.FunctionTypeInfo.uniqueId);
                    end
                end
            end
        end

        function inputDescriptors=getInputDescriptors(analyzer,constness)
            chartData=analyzer.FunctionTypeInfo.chartData;
            inp=analyzer.FunctionTypeInfo.tree.Ins;
            inputDescriptors=cell(1,count(inp.List));
            idx=1;

            while~isempty(inp)
                type=analyzer.getType(inp);
                if nargin<2&&strcmp(inp.kind,'ID')


                    inputVar=inp.string;


                    chartInput=chartData.getParameter(inputVar);
                    if isempty(chartInput)
                        chartInput=chartData.getInput(inputVar);
                    end

                    if~isempty(chartInput)&&chartInput.isParameter

                        if type.isStructType
                            type.busName=chartInput.PIRType.getRecordName;
                        end

                        if isa(chartInput,'internal.mtree.mlfb.ConstantParameter')

                            constVal=type.castValueToType(chartInput.Value);
                            desc=internal.mtree.analysis.VariableDescriptor(...
                            'IS_A_CONST',type,...
                            constVal,internal.mtree.formatConstValStr(constVal));
                        else

                            desc=internal.mtree.analysis.VariableDescriptor(...
                            'TUNABLE_CONST',type);
                        end
                    else


                        desc=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',type);
                    end
                else
                    desc=internal.mtree.analysis.VariableDescriptor(...
                    constness,type);
                end
                inputDescriptors{idx}=desc;

                inp=inp.Next;
                idx=idx+1;
            end
        end

    end

    properties(GetAccess=public,SetAccess=private)
FunctionTypeInfo
FunctionInfoRegistry
Analyzers










Attributes
CurrentAttributes

CurrentAttributesMap
CurrentAttributesKey
CurrentAttributesCalleeKey




GlobalVars
Scopes





MemoizedInputs




        RecurseIntoSubfuns(1,1)logical



        AnalysisHasRun(1,1)logical
    end

    properties(Access=private)



        TimeoutReached(1,1)logical
    end

    methods(Access=protected)

        function this=ConstAnnotator(...
            functionTypeInfo,functionInfoRegistry,analyzers)
            this.FunctionTypeInfo=functionTypeInfo;
            this.setAttributesProperties;
            this.GlobalVars=containers.Map();
            this.Analyzers=analyzers;
            this.FunctionInfoRegistry=functionInfoRegistry;
            this.beginScope();

            this.MemoizedInputs={};

            this.RecurseIntoSubfuns=false;
            this.AnalysisHasRun=false;

            this.TimeoutReached=false;
        end

        function setAttributesProperties(this,singletonOverride)
            if nargin<2
                singletonOverride=false;
            end
            if this.FunctionTypeInfo.isDesign||singletonOverride


                this.Attributes=this.FunctionTypeInfo.treeAttributes;
                this.CurrentAttributes=this.Attributes;
            else
                this.Attributes=this.FunctionTypeInfo.treeAttributesMap;
                this.CurrentAttributes=internal.mtree.MTreeAttributes.empty;
            end
            this.CurrentAttributesMap=containers.Map;
            this.CurrentAttributesKey=[];
            this.CurrentAttributesCalleeKey=[];
        end

        function outputDescriptors=analyze(this,inputDescriptors,recurseIntoSubfuns)

            oldRecurseIntoSubfuns=this.RecurseIntoSubfuns;
            this.RecurseIntoSubfuns=recurseIntoSubfuns;

            input=this.FunctionTypeInfo.tree.Ins;
            inputIndices=input.List.indices;

            numInputs=count(input.List);
            numInputDescriptors=numel(inputDescriptors);

            if numInputDescriptors<numInputs


                extraInputDescriptors=cell(1,numInputs-numInputDescriptors);

                nextInputIdx=inputIndices(numInputDescriptors+1);
                extraInputNode=input.List.select(nextInputIdx);

                for i=1:numel(extraInputDescriptors)
                    extraInputDescriptors{i}=internal.mtree.analysis.VariableDescriptor(...
                    'INDETERMINABLE_IF_CONST',this.getType(extraInputNode));
                    extraInputNode=extraInputNode.Next;
                end

                inputDescriptors=[inputDescriptors,extraInputDescriptors];
            end



            assert(numel(inputDescriptors)>=numInputs);


            if~isempty(inputIndices)
                lastInputIdx=inputIndices(end);
                lastInputNode=input.List.select(lastInputIdx);

                if strcmp(lastInputNode.kind,'ID')&&strcmp(lastInputNode.string,'varargin')


                    descsBeforeVarargin=inputDescriptors(1:numInputs-1);
                    descsAfterVarargin=inputDescriptors(numInputs:end);


                    if this.FunctionTypeInfo.isDesign
                        vararginDesc=inputDescriptors{end};
                        vararginType=vararginDesc.type;
                        assert(vararginType.isCell,...
                        'Top level varargin type is not cell');


                        unknownDesc=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',internal.mtree.type.UnknownType);
                        descArray=repmat({unknownDesc},size(vararginType.cellTypes));

                        vararginDesc=internal.mtree.analysis.VariableDescriptorList(...
                        'NOT_A_CONST',vararginType,descArray);


                    else
                        vararginLen=numel(descsAfterVarargin);
                        vararginType=internal.mtree.type.Cell([1,vararginLen]);

                        vararginIsAllConst=true;
                        vararginHasAnyConst=false;
                        vararginConst=cell(1,vararginLen);

                        for ii=1:vararginLen
                            elemDesc=descsAfterVarargin{ii};

                            if elemDesc.isConst

                                vararginConst{ii}=elemDesc.constVal;
                                vararginType.setCellType(ii,elemDesc.type);
                                vararginHasAnyConst=true;
                            elseif elemDesc.isIndeterminate



                                vararginType.setDimensions([0,0]);
                                vararginConst={};
                                break
                            else


                                vararginIsAllConst=false;
                                vararginType.setCellType(ii,elemDesc.type);
                            end
                        end

                        if vararginIsAllConst

                            constValStr=internal.mtree.formatConstValStr(vararginConst);
                            vararginDesc=internal.mtree.analysis.VariableDescriptor(...
                            'IS_A_CONST',vararginType,vararginConst,constValStr);

                        else

                            if vararginHasAnyConst
                                constness='PARTIALLY_CONST';
                            else
                                constness='NOT_A_CONST';
                            end
                            vararginDesc=internal.mtree.analysis.VariableDescriptorList(...
                            constness,vararginType,descsAfterVarargin);
                        end
                    end

                    inputDescriptors=[descsBeforeVarargin,{vararginDesc}];

                end
            end



            assert(numel(inputDescriptors)==numInputs);

            [hasBeenMemoized,outputDescriptors]=this.checkIfMemoized(inputDescriptors);
            if hasBeenMemoized



                return
            end

            i=1;
            while~isempty(input)



                this.setNodeDescriptor(input,inputDescriptors{i});




                this.setVarDescriptor(input,inputDescriptors{i});

                input=input.Next;
                i=i+1;
            end

            this.visitNodeList(this.FunctionTypeInfo.tree.Body,[]);

            output=this.FunctionTypeInfo.tree.Outs;
            outputDescriptors=cell(1,count(output.List));

            i=1;
            while~isempty(output)



                outputDesc=this.getVarDescriptor(output.string);



                if strcmp(output.string,'varargout')&&outputDesc.isConst
                    newOutputDesc=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',outputDesc.type);
                    outputDesc=newOutputDesc;
                end

                outputDescriptors{i}=outputDesc;





                this.setNodeDescriptor(output,outputDesc);

                output=output.Next;
                i=i+1;
            end



            this.memoize(inputDescriptors,outputDescriptors);

            this.AnalysisHasRun=true;


            this.RecurseIntoSubfuns=oldRecurseIntoSubfuns;
        end






        function memoize(this,inputDescriptors,outputDescriptors)
            thisRun=struct;
            thisRun.recurseIntoSubfuns=this.RecurseIntoSubfuns;
            thisRun.inputDescriptors=inputDescriptors;
            thisRun.outputDescriptors=outputDescriptors;
            thisRun.treeAttributes=this.CurrentAttributes;
            this.MemoizedInputs{end+1}=thisRun;
        end







        function[hasBeenMemoized,outputDescriptors]=checkIfMemoized(this,inputDescriptors)
            hasBeenMemoized=false;
            outputDescriptors=[];

            for ii=1:numel(this.MemoizedInputs)
                oldRun=this.MemoizedInputs{ii};

                if oldRun.recurseIntoSubfuns==this.RecurseIntoSubfuns&&...
                    isequal(oldRun.inputDescriptors,inputDescriptors)
                    hasBeenMemoized=true;
                    outputDescriptors=oldRun.outputDescriptors;


                    this.CurrentAttributes=oldRun.treeAttributes;
                    break;
                end
            end
        end

        function scope=beginScope(this)
            scope=containers.Map();
            this.Scopes{end+1}=scope;
        end

        function scope=endScope(this)
            scope=this.Scopes{end};
            this.Scopes(end)=[];
        end

        function setNodeDescriptor(this,node,descIn,override)

            if nargin<4


                override=false;
            end

            assert(isa(descIn,'internal.mtree.analysis.VariableDescriptor')||...
            isa(descIn,'internal.mtree.analysis.NodeDescriptor'),...
            'unexpected variable descriptor class');


            if isa(descIn,'internal.mtree.analysis.NodeDescriptor')
                varLength=descIn.getLength;
                assert(varLength>1,'NodeDescriptor wrongly used for a single VariableDescriptor');

                newDesc=internal.mtree.analysis.NodeDescriptor(cell(0,0));
            else

                varLength=1;
            end
            isNodeDescriptor=varLength>1;

            prevDesc=this.getNodeDescriptor(node);


            prevVarDesc=prevDesc;





            for idx=1:varLength
                if isNodeDescriptor

                    descInVar=descIn.getVarDesc(idx);
                    if~isempty(prevDesc)
                        prevVarDesc=prevDesc.getVarDesc(idx);
                    end
                else

                    descInVar=descIn;
                end

                if override
                    newVarDesc=descInVar;
                elseif isempty(prevVarDesc)||prevVarDesc.isIndeterminate



                    newVarDesc=descInVar;

                elseif prevVarDesc.isConst



                    if descInVar.isIndeterminate
                        newVarDesc=prevVarDesc;
                    elseif descInVar.isConst
                        if prevVarDesc.isConstEqual(descInVar)
                            newVarDesc=descInVar;
                        else
                            newVarDesc=internal.mtree.analysis.VariableDescriptor(...
                            'NOT_A_CONST',this.getType(descIn));
                        end
                    else
                        assert(descInVar.isNonConst||descInVar.isPartiallyConst)
                        newVarDesc=descInVar;
                    end

                else

                    assert(prevVarDesc.isNonConst||descInVar.isPartiallyConst)
                    newVarDesc=prevVarDesc;
                end

                newVarDesc.isConditionallyExecuted=this.isInConditional;



                prevWholeDesc=this.CurrentAttributes(node).VariableDescriptor;
                if isa(prevWholeDesc,'internal.mtree.analysis.NodeDescriptor')
                    prevWholeDesc=prevWholeDesc.getVarDesc(idx);
                end

                if~isempty(prevWholeDesc)

                    newVarDesc=prevWholeDesc.setVarDesc(...
                    newVarDesc,this.getLocalIteration);
                else

                    if any(this.getLocalIteration)


                        newVarDesc=internal.mtree.analysis.VariableDescriptorLoop(...
                        newVarDesc,this.getLocalIteration);
                    end
                end


                if~isNodeDescriptor

                    newDesc=newVarDesc;
                else

                    newDesc.setVarDesc(newVarDesc,idx);
                end
            end

            this.CurrentAttributes(node).VariableDescriptor=newDesc;



            aggregateDesc=this.FunctionTypeInfo.treeAttributesAggregate(node).VariableDescriptor;
            assert(isa(aggregateDesc,'internal.mtree.analysis.VariableDescriptor')||...
            isa(aggregateDesc,'internal.mtree.analysis.NodeDescriptor')||...
            isempty(aggregateDesc),...
            'aggregate descriptor should not contain any loop information');

            if~isempty(aggregateDesc)

                for ii=1:varLength
                    if isNodeDescriptor

                        aggregateVarDesc=aggregateDesc.getVarDesc(ii);
                        newVarDesc=newDesc.getVarDesc(ii);
                    else

                        aggregateVarDesc=aggregateDesc;
                        newVarDesc=newDesc;
                    end


                    if newVarDesc.isConditionallyExecuted
                        aggregateVarDesc.isConditionallyExecuted=newVarDesc.isConditionallyExecuted;
                    end


                    if~newVarDesc.isConst
                        aggregateVarDesc=aggregateVarDesc.setVarDesc(newVarDesc);
                    elseif aggregateVarDesc.isConst


                        aggregateVarDesc.constVal{end+1}=newVarDesc.constVal;
                    end


                    aggregateDesc=aggregateDesc.setVarDesc(aggregateVarDesc,ii);
                end
            else

                if isNodeDescriptor
                    aggregateDesc=internal.mtree.analysis.NodeDescriptor([]);
                else
                    aggregateDesc=internal.mtree.analysis.VariableDescriptor(...
                    'INDETERMINABLE_IF_CONST',internal.mtree.type.UnknownType);
                end

                for ii=1:varLength
                    if isNodeDescriptor
                        aggregateVarDesc=newDesc.getVarDesc(ii);
                    else
                        aggregateVarDesc=newDesc;
                    end



                    tmpDesc=internal.mtree.analysis.VariableDescriptor(...
                    'INDETERMINABLE_IF_CONST',internal.mtree.type.UnknownType);
                    tmpDesc=tmpDesc.setVarDesc(aggregateVarDesc);

                    if tmpDesc.isConst

                        tmpDesc.constVal={tmpDesc.constVal};
                    end



                    aggregateDesc=aggregateDesc.setVarDesc(tmpDesc,ii);
                end
            end

            this.FunctionTypeInfo.treeAttributesAggregate(node).VariableDescriptor=aggregateDesc;
        end

        function desc=getNodeDescriptor(this,node)

            desc=this.CurrentAttributes(node).VariableDescriptor;

            if isa(desc,'internal.mtree.analysis.NodeDescriptor')&&desc.isLoopDesc



                numOutputDesc=desc.getLength;
                nonLoopVarDescs=cell(1,numOutputDesc);
                for i=1:numOutputDesc




                    nonLoopVarDescs{i}=desc.getVarDesc(i).getVarDesc(this.getLocalIteration);
                end
                if all(cellfun(@(x)isempty(x),nonLoopVarDescs))

                    desc=[];
                else


                    desc=internal.mtree.analysis.NodeDescriptor(nonLoopVarDescs);
                end
            elseif~isempty(desc)&&desc.isLoopDesc
                desc=desc.getVarDesc(this.getLocalIteration);
            end

            assert(isempty(desc)||...
            isa(desc,'internal.mtree.analysis.VariableDescriptor')||...
            isa(desc,'internal.mtree.analysis.NodeDescriptor'),...
            'unexpected descriptor class returned for the node');
        end

        function setVarDescriptor(this,var,descIn)
            if ischar(var)
                varName=var;
            elseif isa(var,'coder.internal.translator.F2FMTree')
                switch var.kind
                case 'ID'
                    varName=var.string;
                case 'NOT'

                    return
                otherwise
                    error(['Unexpected variable type: ',var.kind])
                end
            end

            scope=this.Scopes{end};
            scope(varName)=descIn;%#ok<NASGU>
        end

        function desc=getVarDescriptor(this,varName)
            desc=getVarDescriptor_helper(this,varName,numel(this.Scopes));

            if isempty(desc)

                constness='INDETERMINABLE_IF_CONST';


                desc=internal.mtree.analysis.VariableDescriptor(...
                constness,internal.mtree.type.UnknownType);
            end
        end

        function varName=getVarName(this,node)
            varName='';
            switch node.kind
            case 'ID',varName=string(node);
            case 'SUBSCR',varName=this.getVarName(node.Left);
            end
        end

        function transferScope(this,scope)
            vars=scope.keys();
            for ii=1:numel(vars)
                var=vars{ii};
                desc=scope(var);
                this.setVarDescriptor(var,desc);
            end
        end

        function calleeAnalyzer=setupCalleeAnalyzer(this,node,calleeTypeInfo)


            if nargin<3||isempty(calleeTypeInfo)
                calleeTypeInfo=this.CurrentAttributes(node).CalledFunction;
            end

            if~isempty(calleeTypeInfo)
                calleeAnalyzer=this.Analyzers(calleeTypeInfo.uniqueId);

                if~this.RecurseIntoSubfuns&&...
                    isa(calleeAnalyzer.Attributes,'internal.mtree.MTreeAttributes')


                    return;
                end


                currentAttributesMap=calleeAnalyzer.Attributes;
                mapKey=this.FunctionTypeInfo.generateCalleeKey(node);

                if~isempty(this.CurrentAttributesCalleeKey)

                    mapKey=[this.CurrentAttributesCalleeKey,' ',mapKey];
                end

                calleeAnalyzer.CurrentAttributesCalleeKey=mapKey;
                currIter=this.getCompleteIteration;

                if~isempty(currIter)



                    for ii=1:numel(currIter)
                        if isKey(currentAttributesMap,mapKey)

                            assert(isa(currentAttributesMap,'containers.Map'),...
                            'unexpected object found for loop map');
                        else



                            currentAttributesMap(mapKey)=containers.Map(...
                            'KeyType','double','ValueType','any');
                        end
                        currentAttributesMap=currentAttributesMap(mapKey);
                        mapKey=currIter(ii);
                    end
                end

                assert(~isKey(currentAttributesMap,mapKey),...
                'unexpected analysis found for the function call');
                currentAttributesMap(mapKey)=copy(...
                calleeAnalyzer.FunctionTypeInfo.treeAttributes);

                assert(isempty(calleeAnalyzer.CurrentAttributes),...
                'unexpected ongoing analysis found for the function call');
                calleeAnalyzer.CurrentAttributes=currentAttributesMap(mapKey);

                calleeAnalyzer.CurrentAttributesMap=currentAttributesMap;
                calleeAnalyzer.CurrentAttributesKey=mapKey;



                this.setCalleeControlFlowInfo(calleeAnalyzer);
            else
                calleeAnalyzer=[];
            end
        end

        function finalizeCalleeAnalyzer(this)


            if~this.RecurseIntoSubfuns&&isa(this.Attributes,'internal.mtree.MTreeAttributes')
                return
            end





            this.CurrentAttributesMap(this.CurrentAttributesKey)=this.CurrentAttributes;


            this.CurrentAttributes=internal.mtree.MTreeAttributes.empty;
            this.CurrentAttributesMap=containers.Map;
            this.CurrentAttributesKey=[];


            this.clearCallerControlFlowInfo;
        end
    end

    methods(Access=public)

        function nodeDescriptor=visit(this,node,input)
            if~this.TimeoutReached
                nodeDescriptor=visit@coder.internal.MTreeVisitor(this,node,input);
            else




                error('Timeout has been reached');
            end
        end

        function nodeDescriptors=visitNodeList(this,nodeList,input)


            node=nodeList;
            nodeDescriptors=cell(1,count(node.List));
            i=1;

            while~isempty(node)
                nodeDescriptors{i}=this.visit(node,input);

                node=node.Next;
                i=i+1;
            end
        end

        function nodeDescriptors=visitFUNCTION(this,node,input)



            this.beginScope;

            inp=node.Ins;
            while~isempty(inp)

                desc=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',this.getType(inp));

                this.setVarDescriptor(inp,desc);
                this.setNodeDescriptor(inp,desc);

                inp=inp.Next;
            end

            this.visitNodeList(node.Body,input);

            out=node.Outs;
            nodeDescriptors=cell(1,count(out.List));
            i=1;

            while~isempty(out)
                outDesc=this.getVarDescriptor(out.string);

                nodeDescriptors{i}=outDesc;
                this.setNodeDescriptor(out,outDesc);

                out=out.Next;
                i=i+1;
            end

            this.endScope;
        end

        function nodeDescriptor=visitDOT(this,node,input)
            if internal.mtree.isFunctionCallNode(node,this.FunctionTypeInfo)

                nodeDescriptor=this.visitCALL(node,input);
            else
                lDescriptor=this.visit(node.Left,input);
                rDescriptor=this.visit(node.Right,input);

                nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
                this.setNodeDescriptor(node,nodeDescriptor);
            end
        end

        function nodeDescriptor=visitFIELD(this,node,~)
            nodeDescriptor=this.nodeEval(node,{});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitLITERAL(this,node,~)
            nodeDescriptor=this.nodeEval(node,{});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitID(this,node,~)
            varName=node.string;
            nodeDescriptor=this.getVarDescriptor(varName);

            if isequal(nodeDescriptor.constType,internal.mtree.analysis.ConstType('INDETERMINABLE_IF_CONST'))


                nodeDescriptor=this.nodeEval(node,{});
            end

            if nodeDescriptor.type.isUnknown


                newType=this.getType(node);
                nodeDescriptor.type=newType;
            end

            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function out=visitGLOBAL(this,node,~)
            out=this.handlePersistentAndGlobalVars(node);
        end

        function out=visitPERSISTENT(this,node,~)
            out=this.handlePersistentAndGlobalVars(node);
        end

        function out=handlePersistentAndGlobalVars(this,node)
            varNode=node.Arg;
            while~isempty(varNode)
                assert(strcmp(varNode.kind,'ID'))
                varName=varNode.string;


                this.GlobalVars(varName)=true;

                type=this.getType(varNode);
                if type.isSystemObject


                    constness='INDETERMINABLE_IF_CONST';
                else



                    constness='NOT_A_CONST';
                end
                varDesc=internal.mtree.analysis.VariableDescriptor(...
                constness,type);

                this.setVarDescriptor(varName,varDesc);
                this.setNodeDescriptor(varNode,varDesc);

                varNode=varNode.Next;
            end



            out=[];
        end

        function nodeDescriptor=visitDOTLP(this,node,input)
            lDescriptor=this.visit(node.Left,input);
            rDescriptor=this.visit(node.Right,input);

            nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitBINEXPR(this,node,input)
            lDescriptor=this.visit(node.Left,input);
            rDescriptor=this.visit(node.Right,input);

            nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitDOTBINEXPR(this,node,input)
            lDescriptor=this.visit(node.Left,input);
            rDescriptor=this.visit(node.Right,input);

            nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitPARENS(this,node,input)
            argDescriptor=this.visit(node.Arg,input);

            nodeDescriptor=this.nodeEval(node,{argDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitUNEXPR(this,node,input)
            argDescriptor=this.visit(node.Arg,input);

            nodeDescriptor=this.nodeEval(node,{argDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitLOGBINEXPR(this,node,input)
            lDescriptor=this.visit(node.Left,input);
            rDescriptor=this.visit(node.Right,input);

            nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitRELBINEXPR(this,node,input)
            lDescriptor=this.visit(node.Left,input);
            rDescriptor=this.visit(node.Right,input);

            nodeDescriptor=this.nodeEval(node,{lDescriptor,rDescriptor});
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitSUBSCR(this,node,input)
            if internal.mtree.isPragma(node)

                nodeDescriptor=this.handlePragma(node,input);
            elseif internal.mtree.isFunctionCallNode(node,this.FunctionTypeInfo)

                nodeDescriptor=this.visitCALL(node,input);
            else

                matDescriptor=this.visit(node.Left,input);

                if matDescriptor.type.isFunctionHandle


                    nodeDescriptor=this.visitCALL(node,input);
                else
                    idxDescriptors=this.visitNodeList(node.Right,input);
                    nodeDescriptor=this.nodeEval(node,[{matDescriptor},idxDescriptors]);
                    this.setNodeDescriptor(node,nodeDescriptor);
                end
            end
        end

        function nodeDescriptor=visitCELL(this,node,input)
            cellDescriptor=this.visit(node.Left,input);
            idxDescriptors=this.visitNodeList(node.Right,input);



            expandedIdxDescs=internal.mtree.analysis.expandDescriptors(idxDescriptors);

            numOut=1;
            for i=1:numel(expandedIdxDescs)
                numVals=prod(expandedIdxDescs{i}.type.Dimensions,'all');
                numOut=numOut*numVals;
            end

            nodeDescriptor=this.nodeEval(node,[{cellDescriptor},idxDescriptors],numOut);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitROW(this,node,input)
            elemDescriptors=this.visitNodeList(node.Arg,input);
            nodeDescriptor=this.nodeEval(node,elemDescriptors);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitLB(this,node,input)
            if strcmp(node.Arg.kind,'ROW')
                rowDescriptors=this.visitNodeList(node.Arg,input);

                nodeDescriptor=this.nodeEval(node,rowDescriptors);
                this.setNodeDescriptor(node,nodeDescriptor);
            else
                error('LHS LB node not handled in visitEQUALS')
            end
        end

        function nodeDescriptor=visitLC(this,node,input)
            rowDescriptors=this.visitNodeList(node.Arg,input);

            nodeDescriptor=this.nodeEval(node,rowDescriptors);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitCALL(this,node,input)









            if(strcmp(node.kind,'SUBSCR')&&strcmp(node.Left.kind,'DOT'))...
                ||strcmp(node.kind,'DOT')
                this.visit(node.Left,input);
            end


            if strcmp(node.kind,'DOT')

                argDescriptors={};
            else
                argDescriptors=this.visitNodeList(node.Right,input);
            end

            calleeAnalyzer=this.setupCalleeAnalyzer(node);

            if~isempty(calleeAnalyzer)
                nodeDescriptor=this.handleUserFunction(...
                node,calleeAnalyzer,argDescriptors);
            else
                numOut=this.getNumOutputs(node);

                nodeDescriptor=this.nodeEval(node,argDescriptors,numOut);
            end

            if strcmp(node.Left.tree2str,'step')&&numel(argDescriptors)>=1&&...
                argDescriptors{1}.type.isSystemObject



                sysObjNode=node.Right;
                sysObjDesc=argDescriptors{1};
                sysObjDesc.constType='NOT_A_CONST';
                sysObjDesc.constVal=[];
                sysObjDesc.evaluateableString='';
                if strcmp(sysObjNode.kind,'ID')


                    this.setVarDescriptor(sysObjNode,sysObjDesc);
                end
            end

            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitLP(this,node,input)

            nodeDescriptor=this.visitCALL(node,input);
        end

        function nodeDescriptor=visitCOLON(this,node,input)
            args={};

            if~isempty(node.Left)&&strcmp(node.Left.kind,'COLON')

                lhs=this.visit(node.Left.Left,input);
                stepSize=this.visit(node.Left.Right,input);

                args={lhs,stepSize};
            elseif~isempty(node.Left)

                args={this.visit(node.Left,input)};
            end

            if~isempty(node.Right)

                args=[args,{this.visit(node.Right,input)}];
            end

            nodeDescriptor=this.nodeEval(node,args);

            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitWHILE(this,node,input)


            this.processNonUnrolledLoop(node.Body,input);



            this.visit(node.Left,input);



            nodeDescriptor=[];
        end

        function nodeDescriptor=visitFOR(this,node,input)
            idxNode=node.Index;
            vectorNode=node.Vector;

            vecDescriptor=this.visit(vectorNode,input);

            idxElemType=this.getType(idxNode);
            idxNACDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'NOT_A_CONST',idxElemType);


            this.setNodeDescriptor(idxNode,idxNACDescriptor);

            if vecDescriptor.isConst






                [streamLoop,~]=this.getLoopStreaming;

                if streamLoop&&strcmp(hdlfeature('EnableForIterator'),'on')

                    this.setVarDescriptor(idxNode,idxNACDescriptor);

                    this.processNonUnrolledLoop(node.Body,input);


                    for finalIdxVal=vecDescriptor.constVal
                    end
                    finalIdxValStr=internal.mtree.formatConstValStr(finalIdxVal);
                    finalIdxDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'IS_A_CONST',idxElemType,finalIdxVal,finalIdxValStr);
                    this.setVarDescriptor(idxNode,finalIdxDescriptor);
                else



                    this.addIterationDimension();
                    for idxVal=vecDescriptor.constVal
                        this.incrementIteration();
                        idxValStr=internal.mtree.formatConstValStr(idxVal);
                        idxDescriptor=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',idxElemType,idxVal,idxValStr);



                        this.setVarDescriptor(idxNode,idxDescriptor);

                        this.visitNodeList(node.Body,input);
                    end


                    this.removeIterationDimension();
                end
            else





                this.setVarDescriptor(idxNode,idxNACDescriptor);

                this.processNonUnrolledLoop(node.Body,input);
            end



            nodeDescriptor=[];
        end

        function nodeDescriptor=visitSWITCH(this,node,input)






            numConditions=count(node.Body.List);
            conditionConsts=cell(1,numConditions);
            conditionScopes=cell(1,numConditions);

            hasAlwaysExecutedCase=false;
            varDesc=this.visit(node.Left,input);

            conditionNode=node.Body;
            idx=1;

            while~isempty(conditionNode)&&~hasAlwaysExecutedCase
                switch conditionNode.kind
                case 'CASE'
                    caseDesc=this.visit(conditionNode.Left,input);

                    if varDesc.isConst


                        caseVals=this.getAllConstCaseVals(conditionNode.Left);

                        if ismember(varDesc.constVal,caseVals)
                            conditionConsts{idx}=true;


                            hasAlwaysExecutedCase=true;
                        elseif caseDesc.isConst



                            this.visit(conditionNode,[1,0]);
                            conditionNode=conditionNode.Next;
                            continue;
                        end
                    end







                    caseTypes=this.getAllCaseTypes(conditionNode.Left);
                    hasSameDimsFcn=@(x)...
                    isempty(x.Dimensions)||isequal(x.Dimensions,varDesc.type.Dimensions);
                    caseHasDimsMatch=isempty(varDesc.type.Dimensions)||...
                    any(arrayfun(hasSameDimsFcn,caseTypes));

                    if~hasAlwaysExecutedCase&&~caseHasDimsMatch
                        this.visit(conditionNode,[1,0]);
                        conditionNode=conditionNode.Next;
                        continue;
                    end



                    this.beginConditional(idx==1&&hasAlwaysExecutedCase);
                    conditionScopes{idx}=this.beginScope;
                    this.visitNodeList(conditionNode.Body,input);
                    this.endScope;

                    idx=idx+1;
                    this.endConditional;

                    this.visit(conditionNode,[hasAlwaysExecutedCase,hasAlwaysExecutedCase]);
                case 'OTHERWISE'

                    this.beginConditional(idx==1);
                    conditionConsts{idx}=true;

                    conditionScopes{idx}=this.beginScope;
                    this.visitNodeList(conditionNode.Body,input);
                    this.endScope;

                    idx=idx+1;
                    this.endConditional;
                case{'COMMENT','BLKCOM','CELLMARK'}



                otherwise
                    assert(false,'unexpected switch-node found');
                end

                conditionNode=conditionNode.Next;
            end


            conditionConsts(idx:end)=[];
            conditionScopes(idx:end)=[];

            this.updateScopeAfterConditional(conditionConsts,conditionScopes);



            nodeDescriptor=[];
        end

        function nodeDescriptor=visitCASE(this,node,input)
            nodeDescriptor=internal.mtree.analysis.VariableDescriptor('NOT_A_CONST',...
            internal.mtree.Type.makeType('logical',[1,1]));
            if input(1)

                nodeDescriptor=nodeDescriptor.setConstness(true);
                if input(2)

                    nodeDescriptor.constVal=true;
                    nodeDescriptor.evaluateableString='true';
                else

                    nodeDescriptor.constVal=false;
                    nodeDescriptor.evaluateableString='false';
                end
            end

            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitIF(this,node,input)






            numConditions=count(node.Arg.List);
            conditionConsts=cell(1,numConditions);
            conditionScopes=cell(1,numConditions);

            conditionNode=node.Arg;
            i=1;
            isPersistentInitCondition=false;
            while~conditionNode.isempty
                switch conditionNode.kind
                case{'IFHEAD','ELSEIF'}
                    conditionArg=conditionNode.Left;
                    condDescriptor=this.visit(conditionArg,input);
                    if internal.mtree.isPersistentInitCondition(this.GlobalVars,conditionArg)


                        condDescriptor.constType='NOT_A_CONST';
                        condDescriptor.constVal=[];
                        condDescriptor.evaluateableString='';
                        this.setNodeDescriptor(conditionArg,condDescriptor);
                        isPersistentInitCondition=true;
                    end
                    if condDescriptor.isConst
                        conditionConsts{i}=condDescriptor.constVal;

                        if condDescriptor.constVal



                            this.beginConditional(i==1);
                            conditionScopes{i}=this.beginScope;
                            this.visitNodeList(conditionNode.Body,input);
                            this.endScope;


                            i=i+1;
                            this.endConditional;
                            break;
                        else






                            conditionNode=conditionNode.Next;
                            continue;
                        end
                    else


                        if~isPersistentInitCondition






                            this.beginConditional;
                        end
                        conditionScopes{i}=this.beginScope;
                        this.visitNodeList(conditionNode.Body,input);
                        this.endScope;


                        i=i+1;
                        if~isPersistentInitCondition
                            this.endConditional;
                        else
                            isPersistentInitCondition=false;
                        end
                    end

                case 'ELSE'

                    this.beginConditional;
                    conditionConsts{i}=true;

                    conditionScopes{i}=this.beginScope;
                    this.visitNodeList(conditionNode.Body,input);
                    this.endScope;


                    i=i+1;
                    this.endConditional;
                otherwise
                    assert(false,'unknown if-node found');
                end

                conditionNode=conditionNode.Next;
            end


            conditionConsts(i:end)=[];
            conditionScopes(i:end)=[];

            this.updateScopeAfterConditional(conditionConsts,conditionScopes);


            nodeDescriptor=[];
        end

        function nodeDescriptor=visitEQUALS(this,node,input)
            rhs=node.Right;
            lhs=node.Left;


            allRhsDescriptors=this.visit(rhs,input);

            idx=1;
            if strcmp(lhs.kind,'LB')

                varNode=lhs.Arg;
                isLHSLB=true;
            else
                varNode=lhs;
                isLHSLB=false;
            end

            isNodeDesc=isa(allRhsDescriptors,'internal.mtree.analysis.NodeDescriptor');
            if isNodeDesc
                numDescriptors=allRhsDescriptors.getLength;
            else
                numDescriptors=1;
            end
            lhsVarDescriptors=cell(1,numDescriptors);
            rhsTypeChange=false;

            while~isempty(varNode)
                if isNodeDesc

                    rhsDescriptor=allRhsDescriptors.getVarDesc(idx);
                else

                    rhsDescriptor=allRhsDescriptors;
                end

                if isempty(rhsDescriptor)



                    rhsDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',this.getType(varNode));
                end

                lhsDescriptor=this.handleSingleLHSNode(varNode,rhsDescriptor,input);
                lhsVarDescriptors{idx}=lhsDescriptor;
                if rhsDescriptor.type.isUnknown

                    rhsDescriptor.type=lhsDescriptor.type.copy;
                    if isNodeDesc
                        allRhsDescriptors.setVarDesc(rhsDescriptor,idx);
                    else
                        allRhsDescriptors=rhsDescriptor;
                    end
                    rhsTypeChange=true;
                end

                idx=idx+1;
                varNode=varNode.Next;
            end

            lhsVarDescriptors(idx:end)=[];

            if rhsTypeChange
                this.setNodeDescriptor(rhs,allRhsDescriptors,true);
            end


            if isLHSLB
                if numel(lhsVarDescriptors)>1
                    this.setNodeDescriptor(lhs,internal.mtree.analysis.NodeDescriptor(lhsVarDescriptors));
                else
                    this.setNodeDescriptor(lhs,lhsVarDescriptors{1});
                end
            end



            nodeDescriptor=[];
        end

        function nodeDescriptor=visitAT(this,node,~)



            type=this.getType(node);
            nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'IS_A_CONST',type,type.getExampleValue,type.getExampleValueString);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitANON(this,node,in)



            this.visitNodeList(node.Left,in);


            this.visitNodeList(node.Right,in);




            type=this.getType(node);
            nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'NOT_A_CONST',type);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=visitANONID(this,node,~)


            type=this.getType(node);
            nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'NOT_A_CONST',type);
            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function type=getType(this,nodeOrDesc,idx)
            if nargin<3
                idx=1;
            end

            if isa(nodeOrDesc,'coder.internal.translator.F2FMTree')
                type=this.getTypeFromMTree(nodeOrDesc,idx);
            elseif isa(nodeOrDesc,'internal.mtree.analysis.NodeDescriptor')

                type=nodeOrDesc.getVarDesc(idx).type;
            else

                type=nodeOrDesc.type;
            end
        end

    end

    methods(Access=protected)

        function type=getTypeFromMTree(this,nodeOrDesc,idx)

            type=internal.mtree.getType(...
            nodeOrDesc,this.FunctionTypeInfo,this.FunctionInfoRegistry,idx);
        end

        function descriptor=nodeEval(this,node,inputs,numOut)
            if nargin<4
                numOut=1;
            end

            descriptor=internal.mtree.analysis.EvalExpr.NodeEval(...
            node,inputs,numOut,this);
        end

        function desc=getVarDescriptor_helper(this,varName,depth)
            if depth<=0
                desc=[];
            else
                scope=this.Scopes{depth};

                if scope.isKey(varName)
                    desc=scope(varName);
                else
                    desc=getVarDescriptor_helper(this,varName,depth-1);
                end
            end
        end

        function nodeDescriptor=handlePragma(this,node,input)
            pragmaName=node.Left.tree2str(0,1);
            argDescriptors=this.visitNodeList(node.Right,input);
            calleeAnalyzer=this.setupCalleeAnalyzer(node);

            if strcmp(pragmaName,'hdl.npufun')
                nodeDescriptor=this.handleNPUFun(node,argDescriptors);
            elseif strcmp(pragmaName,'hdl.iteratorfun')
                nodeDescriptor=this.handleIteratorFun(node,argDescriptors);
            elseif~isempty(calleeAnalyzer)
                assert(strcmp(pragmaName,'coder.const')&&...
                argDescriptors{1}.type.isFunctionHandle);



                fcnArgDescriptors=argDescriptors(2:end);

                nodeDescriptor=this.handleUserFunction(...
                node,calleeAnalyzer,fcnArgDescriptors);
            else
                numOut=this.getNumOutputs(node);

                nodeDescriptor=this.nodeEval(node,argDescriptors,numOut);



                if strcmp(pragmaName,'coder.hdl.loopspec')
                    streamLoop=false;
                    if numel(argDescriptors)>=1&&argDescriptors{1}.isConst
                        streamLoop=strcmp(argDescriptors{1}.constVal,'stream');
                    end

                    streamingFactor=[];
                    if numel(argDescriptors)>=2&&argDescriptors{2}.isConst
                        streamingFactor=argDescriptors{2}.constVal;
                    end

                    this.setLoopStreamingIfNextNodeIsFor(node,streamLoop,streamingFactor);
                end
            end

            this.setNodeDescriptor(node,nodeDescriptor);
        end

        function nodeDescriptor=handleNPUFun(this,node,argDescriptors)


            useAggregate=false;
            npuInfo=internal.mtree.utils.npufun.Info(node,...
            argDescriptors,this.FunctionInfoRegistry,useAggregate);



            numInputsDescriptors=numel(npuInfo.KernelArgIdxs);
            fcnArgDescriptors=cell(1,numel(npuInfo.KernelArgIdxs));

            for i=1:numInputsDescriptors
                fcnArgDescriptors{i}=argDescriptors{npuInfo.KernelArgIdxs(i)};
                if ismember(i,npuInfo.StreamedArgIdxsInternal)
                    desc=fcnArgDescriptors{i};



                    inputType=desc.type.copy;
                    inputType.setDimensions(npuInfo.KernelSize);

                    if desc.isIndeterminate
                        constness='INDETERMINABLE_IF_CONST';
                    else
                        constness='NOT_A_CONST';
                    end

                    fcnArgDescriptors{i}=...
                    internal.mtree.analysis.VariableDescriptor(constness,inputType);
                end
            end



            calleeAnalyzer=this.setupCalleeAnalyzer(node,npuInfo.CalleeFcnInfo);

            kernelOutDesc=this.handleUserFunction(...
            node,calleeAnalyzer,fcnArgDescriptors);

            numOut=this.getNumOutputs(node);



            if numOut>1
                assert(strcmp(node.Parent.kind,'EQUALS')&&...
                strcmp(node.Parent.Left.kind,'LB'));
                outNode=node.Parent.Left.Arg;

                nodeDescriptorCell=cell(1,numOut);

                for i=1:numOut
                    if kernelOutDesc.getVarDesc(i).isIndeterminate
                        constness='INDETERMINABLE_IF_CONST';
                    else
                        constness='NOT_A_CONST';
                    end

                    type=this.getType(outNode);

                    nodeDescriptorCell{i}=...
                    internal.mtree.analysis.VariableDescriptor(constness,type);

                    outNode=outNode.Next;
                end

                nodeDescriptor=internal.mtree.analysis.cellToNodeDescriptor(nodeDescriptorCell);
            else
                if isa(kernelOutDesc,'internal.mtree.analysis.NodeDescriptor')
                    kernelOutDesc=kernelOutDesc.getVarDesc(1);
                end

                if kernelOutDesc.isIndeterminate
                    constness='INDETERMINABLE_IF_CONST';
                else
                    constness='NOT_A_CONST';
                end



                type=this.getType(node);

                nodeDescriptor=...
                internal.mtree.analysis.VariableDescriptor(constness,type);
            end
        end

        function nodeDescriptor=handleIteratorFun(this,node,argDescriptors)
            iteratorInfo=internal.mtree.utils.iteratorfun.Info(node,...
            argDescriptors,this.FunctionInfoRegistry);


            fcnArgDescriptors=argDescriptors(2:end);

            fcnHandleArg=node.Right;
            inputArg=fcnHandleArg.Next;
            for i=1:numel(fcnArgDescriptors)
                desc=fcnArgDescriptors{i};



                inputType=desc.type.copy;



                if i==1
                    inputType.setDimensions([1,1]);
                elseif i==2
                    inputType.setDimensions(iteratorInfo.OutputSize);
                end

                if desc.isIndeterminate
                    constness='INDETERMINABLE_IF_CONST';
                else
                    constness='NOT_A_CONST';
                end

                fcnArgDescriptors{i}=...
                internal.mtree.analysis.VariableDescriptor(constness,inputType);

                inputArg=inputArg.Next;
            end


            cntArgIdx=3;
            cntSize=prod(iteratorInfo.ImageSize);
            cntType=internal.mtree.Type.getIntToHold(cntSize,1);
            cntDesc=internal.mtree.analysis.VariableDescriptor('NOT_A_CONST',cntType);
            fcnArgDescriptors=[fcnArgDescriptors(1:cntArgIdx-1),{cntDesc},fcnArgDescriptors(cntArgIdx:end)];



            calleeAnalyzer=this.setupCalleeAnalyzer(node,iteratorInfo.CalleeFcnInfo);

            kernelOutDesc=this.handleUserFunction(...
            node,calleeAnalyzer,fcnArgDescriptors);

            numOut=this.getNumOutputs(node);


            assert(numOut==1);
            if isa(kernelOutDesc,'internal.mtree.analysis.NodeDescriptor')
                kernelOutDesc=kernelOutDesc.getVarDesc(1);
            end

            if kernelOutDesc.isIndeterminate
                constness='INDETERMINABLE_IF_CONST';
            else
                constness='NOT_A_CONST';
            end

            type=this.getType(node);
            nodeDescriptor=...
            internal.mtree.analysis.VariableDescriptor(constness,type);
        end

        function nodeDescriptor=handleUserFunction(this,node,calleeAnalyzer,argDescriptors)
            import internal.mtree.analysis.*;

            argDescriptors=expandDescriptors(argDescriptors);

            numOut=this.getNumOutputs(node);
            nodeType=this.getType(node);

            if nodeType.isSystemObject&&nodeType.IsPIRBased

                nodeDescriptor=this.nodeEval(node,argDescriptors);
            else
                if this.RecurseIntoSubfuns


                    nodeDescriptorCell=calleeAnalyzer.analyze(argDescriptors,this.RecurseIntoSubfuns);

                    if numel(nodeDescriptorCell)>numOut



                        nodeDescriptorCell=nodeDescriptorCell(1:numOut);
                    end

                    nodeDescriptor=cellToNodeDescriptor(nodeDescriptorCell);



                    argNode=node.Right;

                    if~isempty(argNode)&&this.getType(argNode).isSystemObject
                        nodeDescriptor=this.handleSetupAndResetSysObjCalls(...
                        node,argDescriptors);
                    end
                else



                    nodeDescriptorCell=cell(1,numOut);

                    outNode=calleeAnalyzer.FunctionTypeInfo.tree.Outs;

                    for idx=1:numOut
                        assert(~isempty(outNode));
                        nodeDescriptorCell{idx}=internal.mtree.analysis.VariableDescriptor(...
                        'INDETERMINABLE_IF_CONST',calleeAnalyzer.getType(outNode));
                        outNode=outNode.Next;
                    end

                    nodeDescriptor=cellToNodeDescriptor(nodeDescriptorCell);
                end
            end



            calleeAnalyzer.finalizeCalleeAnalyzer;
        end

        function nodeDescriptor=handleSetupAndResetSysObjCalls(...
            this,node,argDescriptors)

            nodes=[node.Left,node.Right];

            for nd=nodes
                if strcmp(nd.kind,'CALL')

                    continue;
                end

                calleeAnalyzer=this.setupCalleeAnalyzer(nd);

                if isempty(calleeAnalyzer)

                    continue;
                end



                if strcmp(calleeAnalyzer.FunctionTypeInfo.functionName,'resetImpl')
                    calleeAnalyzer.analyze(argDescriptors(1),this.RecurseIntoSubfuns);
                else
                    calleeAnalyzer.analyze(argDescriptors,this.RecurseIntoSubfuns);
                end

                calleeAnalyzer.finalizeCalleeAnalyzer;
            end



            nodeDescriptor=this.nodeEval(node,argDescriptors);
        end

        function processNonUnrolledLoop(this,loopBody,input)


            this.addIterationDimension;
            firstPassScope=this.beginScope;
            this.visitNodeList(loopBody,input);
            this.endScope;



            this.beginScope;

            varsInLoop=firstPassScope.keys;
            for i=1:numel(varsInLoop)
                firstPassDesc=firstPassScope(varsInLoop{i});
                nacDesc=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',firstPassDesc.type);

                this.setVarDescriptor(varsInLoop{i},nacDesc);
            end


            secondPassScope=this.beginScope;





            this.incrementIteration;
            this.visitNodeList(loopBody,input);


            this.endScope;
            this.endScope;

            this.removeIterationDimension;





            this.transferScope(secondPassScope);
        end

        function updateScopeAfterConditional(this,conditionConsts,conditionScopes)


            nonFalseConditions=cellfun(@(x)isempty(x)||x,conditionConsts);
            nonFalseConsts=conditionConsts(nonFalseConditions);
            nonFalseScopes=conditionScopes(nonFalseConditions);



            trueConditions=cellfun(@(x)~isempty(x),nonFalseConsts);
            firstTrueCondition=find(trueConditions,1);

            if isempty(firstTrueCondition)
                prunedScopes=nonFalseScopes;
            else
                prunedScopes=nonFalseScopes(1:firstTrueCondition);
            end

            if isempty(prunedScopes)

                return
            end







            varsInSomeConditional=prunedScopes{1}.keys;
            varsInAllConditionals=prunedScopes{1}.keys;

            for i=2:numel(prunedScopes)
                varsInScope=prunedScopes{i}.keys;
                varsInSomeConditional=union(varsInSomeConditional,varsInScope);
                varsInAllConditionals=intersect(varsInAllConditionals,varsInScope);
            end

            varsBeforeConditional={};
            for i=1:numel(this.Scopes)
                varsBeforeConditional=union(varsBeforeConditional,this.Scopes{i}.keys);
            end

            varsToConsider=union(varsInAllConditionals,...
            intersect(varsInSomeConditional,varsBeforeConditional));

            currentScope=this.Scopes{end};

            for i=1:numel(varsToConsider)
                var=varsToConsider{i};

                if~isempty(firstTrueCondition)&&firstTrueCondition==1



                    newNodeDescriptor=prunedScopes{1}(var);

                elseif~isempty(firstTrueCondition)








                    newNodeDescriptor=this.mergeVarIfSameInAllBranches(var,prunedScopes);

                    if~newNodeDescriptor.isConst

                        newNodeDescriptor=this.mergeVarIfSameAsBefore(var,prunedScopes);
                    end

                else




                    newNodeDescriptor=this.mergeVarIfSameAsBefore(var,prunedScopes);
                end


                currentScope(var)=newNodeDescriptor;
            end
        end

        function nodeDescriptor=mergeVarIfSameInAllBranches(~,var,conditionalScopes)

            for i=1:numel(conditionalScopes)
                condScope=conditionalScopes{i};

                if condScope.isKey(var)
                    type=condScope(var).type;
                    break
                end
            end

            nodeDescriptor=internal.mtree.analysis.VariableDescriptor('NOT_A_CONST',type);
            descInBranches=[];

            for i=1:numel(conditionalScopes)
                condScope=conditionalScopes{i};

                if condScope.isKey(var)
                    if isempty(descInBranches)

                        descInBranches=condScope(var);

                        if~descInBranches.isConst



                            return
                        end
                    elseif~descInBranches.isConstEqual(condScope(var))


                        return
                    end
                else


                    return
                end
            end

            if~isempty(descInBranches)



                nodeDescriptor=descInBranches;
            end
        end

        function nodeDescriptor=mergeVarIfSameAsBefore(this,var,conditionalScopes)
            descBeforeBranch=this.getVarDescriptor(var);

            if~descBeforeBranch.isIndeterminate


                type=descBeforeBranch.type;
            else



                numInst=0;
                instantiations=cell(1,numel(conditionalScopes));

                for i=1:numel(conditionalScopes)
                    condScope=conditionalScopes{i};
                    if condScope.isKey(var)
                        numInst=numInst+1;
                        instantiations{numInst}=condScope(var);
                    end
                end

                instantiations(numInst+1:end)=[];

                if numel(instantiations)==1||...
                    all(cellfun(@(x)x.isConstEqual(instantiations{1}),instantiations(2:end)))


                    nodeDescriptor=instantiations{1};
                    return
                end


                assert(~isempty(instantiations),'variable not found within condition scopes');
                type=instantiations{1}.type;
            end

            nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'NOT_A_CONST',type);

            if~descBeforeBranch.isConst



                return
            end

            for i=1:numel(conditionalScopes)
                condScope=conditionalScopes{i};

                if condScope.isKey(var)
                    if~descBeforeBranch.isConstEqual(condScope(var))



                        return
                    end
                end
            end



            nodeDescriptor=descBeforeBranch;
        end

        function vals=getAllConstCaseVals(this,node)
            vals={};
            nodeDesc=this.getNodeDescriptor(node);

            if nodeDesc.isConst
                vals=nodeDesc.constVal;

                if~iscell(vals)&&~isnumeric(vals)
                    vals={vals};
                end
            elseif strcmp(node.kind,'LC')





                vals=cell(1,count(node.Tree));
                valIdx=1;

                rowNode=node.Arg;

                while~isempty(rowNode)
                    elemNode=rowNode.Arg;

                    while~isempty(elemNode)
                        elemDesc=this.getNodeDescriptor(elemNode);

                        if elemDesc.isConst
                            vals{valIdx}=elemDesc.constVal;
                            valIdx=valIdx+1;
                        end

                        elemNode=elemNode.Next;
                    end

                    rowNode=rowNode.Next;
                end

                vals(valIdx:end)=[];
            end
        end

        function vals=getAllCaseTypes(this,node)

            if strcmp(node.kind,'LC')


                vals=repmat(internal.mtree.type.UnknownType,1,count(node.Tree));
                valIdx=1;

                rowNode=node.Arg;

                while~isempty(rowNode)
                    elemNode=rowNode.Arg;

                    while~isempty(elemNode)
                        elemDesc=this.getNodeDescriptor(elemNode);

                        vals(valIdx)=elemDesc.type;
                        valIdx=valIdx+1;

                        elemNode=elemNode.Next;
                    end

                    rowNode=rowNode.Next;
                end

                vals(valIdx:end)=[];
            else

                nodeDesc=this.getNodeDescriptor(node);
                vals=nodeDesc.type;
            end
        end

        function nodeDescriptor=handleSingleLHSNode(this,node,rhsDescriptor,input)
            assert(isa(rhsDescriptor,'internal.mtree.analysis.VariableDescriptor')||...
            isa(rhsDescriptor,'internal.mtree.analysis.VariableDescriptorLoop'),...
            'Descriptor for RHS should be a VariableDescriptor object');


            [oldDescriptor,subscriptIndices,~,indicesAreConst]=...
            this.getOldDescriptorAndSubscripts(node,1,input);



            lhsType=oldDescriptor.type;

            if isempty(subscriptIndices)


                nodeDescriptor=rhsDescriptor;



                lhsType=this.getType(node);
            elseif indicesAreConst



                rhsType=rhsDescriptor.type;

                lhsAsFalse=replicateTypeAsValue(lhsType,false);
                rhsAsTrue=replicateTypeAsValue(rhsType,true);

                try
                    asgnWithLogicalsResult=this.subsasgn(lhsAsFalse,subscriptIndices,rhsAsTrue);

                    allAreCovered=applyQuantifierToStruct(asgnWithLogicalsResult,@all);
                    anyAreCovered=applyQuantifierToStruct(asgnWithLogicalsResult,@any);
                catch





                    allAreCovered=false;
                    anyAreCovered=true;
                end

                if allAreCovered&&rhsDescriptor.isConst




                    if lhsType.isUnknown||lhsType.isSystemObject
                        oldVal=repmat(rhsDescriptor.constVal(1),lhsType.Dimensions);
                    else
                        try



                            oldVal=lhsType.getExampleValue;
                        catch
                            oldVal=[];
                        end
                    end

                    if~isempty(oldVal)

                        newVal=this.subsasgn(oldVal,subscriptIndices,...
                        rhsDescriptor.constVal);
                        newValStr=internal.mtree.formatConstValStr(newVal);

                        nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',lhsType,newVal,newValStr);
                    else
                        nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',lhsType);
                    end
                elseif anyAreCovered&&oldDescriptor.isConst&&rhsDescriptor.isConst



                    try


                        oldValStr=oldDescriptor.evaluateableString;
                        oldVal=eval(oldValStr);
                        newVal=this.subsasgn(oldVal,subscriptIndices,...
                        rhsDescriptor.constVal);
                        if lhsType.isSystemObject


                            newValStr=string([oldValStr,'; ',node.Left.tree2str]);
                            for indCount=1:numel(subscriptIndices)
                                indexing=subscriptIndices(indCount);
                                switch indexing.type
                                case{'()','{}'}
                                    parenType=indexing.type;
                                    newValStr=newValStr.append(parenType(1));
                                    indexing_subs=indexing.subs{1};
                                    for dimCount=1:numel(indexing_subs)
                                        newValStr=newValStr.append(int2str(indexing_subs{dimCount}));
                                        if dimCount~=numel(indexing_subs)
                                            newValStr=newValStr.append(',');
                                        end
                                    end
                                    newValStr=newValStr.append(parenType(2));
                                case '.'
                                    newValStr=newValStr.append(['.',indexing.subs]);
                                otherwise
                                    error('unexpected subsasgn usage found');
                                end
                            end
                            newValStr=newValStr.append(['=',rhsDescriptor.evaluateableString]);
                            newValStr=newValStr.char;
                        else


                            newValStr=internal.mtree.formatConstValStr(newVal);
                        end

                        nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',lhsType,newVal,newValStr);
                    catch



                        nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',lhsType);
                    end
                elseif~anyAreCovered



                    nodeDescriptor=oldDescriptor;
                elseif oldDescriptor.isIndeterminate&&isequal(lhsType,rhsDescriptor.type)


                    nodeDescriptor=rhsDescriptor;
                else

                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',lhsType);
                end
            else


                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',lhsType);
            end

            if~lhsType.isUnknown
                rhsType=nodeDescriptor.type;
                nodeDescriptor.type=lhsType.copy;
                if nodeDescriptor.type.isSizeDynamic


                    nodeDescriptor.type.setDimensions(rhsType.Dimensions);
                end
                if nodeDescriptor.isConst&&~lhsType.isTypeEqual(rhsType)...
                    &&~(lhsType.isSystemObject&&rhsType.isSystemObject)




                    nodeDescriptor.constVal=lhsType.castValueToType(nodeDescriptor.constVal);
                    nodeDescriptor.evaluateableString=internal.mtree.formatConstValStr(...
                    nodeDescriptor.constVal);
                end
            end


            this.setNewLHSDescriptors(node,nodeDescriptor);

            function newVal=replicateTypeAsValue(type,val)
                if type.isStructType
                    fieldNames=type.getFieldNames;
                    fieldVals=arrayfun(@(x){replicateTypeAsValue(x,val)},...
                    type.getFieldTypes);
                    valToRep=type.nameValToStruct(fieldNames,fieldVals);
                else
                    valToRep=val;
                end

                if~(type.isUnknown&&strcmp(type.Name,'unknown')&&isempty(type.Dimensions))


                    newVal=repmat(valToRep,type.Dimensions);
                else
                    newVal=valToRep;
                end
            end

            function result=applyQuantifierToStruct(val,quantifier)
                if isstruct(val)
                    structResults=false(1,numel(val));

                    for ii=1:numel(val)
                        s=val(ii);

                        structFields=fields(s);
                        innerStructResults=false(1,numel(structFields));

                        for jj=1:numel(structFields)
                            field=structFields{jj};

                            innerStructResults(jj)=applyQuantifierToStruct(s.(field),quantifier);
                        end

                        structResults(ii)=quantifier(innerStructResults);
                    end

                    result=quantifier(structResults);
                else
                    result=quantifier(val(:));
                end
            end
        end
















        function[oldDescriptor,subscriptIndices,subscriptIdx,indicesAreConst]=...
            getOldDescriptorAndSubscripts(this,node,recursionLevel,input)

            switch node.kind
            case{'ID','NOT'}


                if strcmp(node.kind,'ID')

                    oldDescriptor=this.getVarDescriptor(node.string);
                    if oldDescriptor.isIndeterminate&&oldDescriptor.type.isUnknown




                        oldDescriptor.type=this.getType(node);
                    end
                else

                    oldDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',this.getType(node));
                end




                subscriptIndices=repmat(struct('type','','subs',[]),...
                1,recursionLevel-1);


                subscriptIdx=1;


                indicesAreConst=true;

            case{'SUBSCR','CELL'}




                idxDescriptors=this.visitNodeList(node.Right,input);


                [oldDescriptor,subscriptIndices,subscriptIdx,indicesAreConst]=...
                this.getOldDescriptorAndSubscripts(node.Left,recursionLevel+1,input);

                if strcmp(node.kind,'SUBSCR')
                    subscrType='()';
                else
                    subscrType='{}';
                end




                indices=cell(1,numel(idxDescriptors));
                for ii=1:numel(idxDescriptors)
                    if idxDescriptors{ii}.isConst
                        indices{ii}=idxDescriptors{ii}.constVal;
                    else
                        subscrType='nonconst';
                        indices={};
                        indicesAreConst=false;
                        break
                    end
                end

                subscriptIndices(subscriptIdx)=struct('type',subscrType,'subs',{indices});
                subscriptIdx=subscriptIdx+1;

            case{'DOT','DOTLP'}




                fieldDescriptor=this.visit(node.Right,input);


                [oldDescriptor,subscriptIndices,subscriptIdx,indicesAreConst]=...
                this.getOldDescriptorAndSubscripts(node.Left,recursionLevel+1,input);



                if fieldDescriptor.isConst
                    subscrType='.';
                    field=fieldDescriptor.constVal;
                else
                    subscrType='nonconst';
                    field='';
                    indicesAreConst=false;
                end

                subscriptIndices(subscriptIdx)=struct('type',subscrType,'subs',field);
                subscriptIdx=subscriptIdx+1;

            otherwise
                error(['unexpected LHS node kind: ',node.kind]);
            end
        end

        function nodeDescriptor=setNewLHSDescriptors(this,node,topDescriptor)

            switch node.kind
            case{'ID','NOT'}




                this.setVarDescriptor(node,topDescriptor);
                this.setNodeDescriptor(node,topDescriptor);
                nodeDescriptor=topDescriptor;

            case{'SUBSCR','CELL','DOT','DOTLP'}





                lhsDescriptor=this.setNewLHSDescriptors(node.Left,topDescriptor);




                arg=node.Right;
                idxDescriptors=cell(1,count(arg.List));

                for i=1:numel(idxDescriptors)
                    idxDescriptors{i}=this.getNodeDescriptor(arg);
                    assert(~isempty(idxDescriptors{i}));

                    arg=arg.Next;
                end



                nodeDescriptor=this.nodeEval(node,[{lhsDescriptor},idxDescriptors]);
                this.setNodeDescriptor(node,nodeDescriptor);

            otherwise
                error(['unexpected LHS node kind: ',node.kind]);
            end
        end

        function retVal=subsasgn(~,A,S,B)
            retVal=builtin('subsasgn',A,S,B);
        end
    end

    methods(Static,Access=protected)

        function numOut=getNumOutputs(node)


            if strcmp(node.Parent.kind,'EQUALS')&&strcmp(node.Parent.Left.kind,'LB')

                lbNode=node.Parent.Left;
                numOut=count(lbNode.Arg.List);
            else
                numOut=1;
            end
        end

    end

    methods(Static,Access=private)
        function setTimeoutReached(analyzers)
            for i=1:numel(analyzers)
                analyzers{i}.TimeoutReached=true;
            end
        end
    end
end




