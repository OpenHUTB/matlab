classdef IndexingAnalyzer<coder.internal.MTreeVisitor




    properties
FunctionTypeInfo
Attributes
FunctionNode
IndexType

Analyzers
    end

    properties
Context
IndexingContext
NonIndexingContext
GeneralContext

Cause
Dirty
    end

    properties(Dependent)
CurrentContextName
    end


    methods
        function name=get.CurrentContextName(this)
            if this.Context==this.IndexingContext
                name='IndexingContext';
            elseif this.Context==this.NonIndexingContext
                name='NonIndexingContext';
            else
                name='GeneralContext';
            end
        end
    end

    methods(Static)
        function messages=run(functionInfoRegistry,indexType)
            messages=coder.internal.lib.Message.empty;
            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();
            designTypeInfo=[];
            for ii=1:numel(fcnTypeInfos)
                functionTypeInfo=fcnTypeInfos{ii};
                analyzer=coder.internal.analysis.IndexingAnalyzer(functionTypeInfo,analyzers,indexType);
                analyzers(functionTypeInfo.specializationName)=analyzer;
                if functionTypeInfo.isDesign
                    designTypeInfo=functionTypeInfo;
                    inputVars=functionTypeInfo.inputVarNames;
                    inNode=functionTypeInfo.tree.Ins;
                    for jj=1:numel(inputVars)
                        inVar=inputVars{jj};
                        analyzer.NonIndexingContext(inVar)={inNode};
                        inNode=inNode.Next;
                    end
                    outputVars=functionTypeInfo.outputVarNames;
                    outNode=functionTypeInfo.tree.Outs;
                    for jj=1:numel(outputVars)
                        outVar=outputVars{jj};
                        analyzer.NonIndexingContext(outVar)={outNode};
                        outNode=outNode.Next;
                    end
                end
            end

            analyzers=analyzers.values();
            runAll(analyzers);

            for ii=1:numel(analyzers)
                fcnMsgs=analyzers{ii}.proposeTypes();
                messages=[messages,fcnMsgs];
            end

            if~isempty(messages)&&~isempty(designTypeInfo)
                messages(end+1)=coder.internal.lib.Message.buildMessage(designTypeInfo,designTypeInfo.tree,coder.internal.lib.Message.WARN,...
                'Coder:FXPCONV:DTS_IndexVarMessage');

            end

            function runAll(analyzers)
                iterations=1;
                while iterations<=100
                    reanalyzed=false;
                    for kk=1:numel(analyzers)
                        if analyzers{kk}.Dirty
                            analyzers{kk}.analyze();
                            reanalyzed=true;
                        end
                    end
                    if~reanalyzed
                        break;
                    end
                    iterations=iterations+1;
                end
            end
        end
    end

    methods
        function this=IndexingAnalyzer(functionTypeInfo,analyzers,indexType)



            this.FunctionTypeInfo=functionTypeInfo;
            this.Attributes=functionTypeInfo.treeAttributes;
            this.FunctionNode=functionTypeInfo.tree;
            this.Analyzers=analyzers;
            this.IndexType=indexType;
            this.initalizeForProcessing();
        end
    end

    methods
        function analyze(this)

            if this.Dirty
                for ii=1:100


                    this.Dirty=0;
                    this.visit(this.FunctionNode,[]);
                    if this.Dirty==0
                        break;
                    end
                end
            end
        end

        function messages=proposeTypes(this)
            messages=coder.internal.lib.Message.empty;
            indexVars=[this.IndexingContext.keys(),this.GeneralContext.keys()];
            indexVars=unique(indexVars);
            for ii=1:numel(indexVars)
                idxVar=indexVars{ii};

                varInfos=this.FunctionTypeInfo.getVarInfosByName(idxVar);
                if isempty(varInfos)

                    continue;
                end

                if~varInfos{1}.isNumericVar()

                    continue;
                end

                if varInfos{1}.isVarInSrcComplex()

                    continue;
                end

                switch varInfos{1}.inferred_Type.Class
                case{'single','double'}
                otherwise,

                    continue;
                end


                if varInfos{1}.isSpecialized||this.NonIndexingContext.isKey(idxVar)
                    locs=this.NonIndexingContext(idxVar);
                    if this.IndexingContext.isKey(idxVar)
                        if this.FunctionTypeInfo.isDesign
                            if any(ismember(this.FunctionTypeInfo.inputVarNames,idxVar))||...
                                any(ismember(this.FunctionTypeInfo.outputVarNames,idxVar))
                                continue;
                            end
                        end

                        if this.Cause.isKey(idxVar)
                            msg=this.Cause(idxVar);
                            messages(end+1)=msg;
                        end
                    end
                    continue;
                end

                for jj=1:numel(varInfos)
                    varInfos{jj}.proposed_Type=this.IndexType;
                    varInfos{jj}.annotated_Type=this.IndexType;
                end
            end
        end
    end

    methods
        function initalizeForProcessing(this)
            this.IndexingContext=containers.Map();
            this.NonIndexingContext=containers.Map();
            this.GeneralContext=containers.Map();
            this.Context=this.GeneralContext;
            this.Cause=containers.Map();
            this.Dirty=1;
        end
    end

    methods
        function addInputCause(this,varName,callerFcn,callNode)
            if~this.Cause.isKey(varName)
                varNode=this.FunctionTypeInfo.tree.Ins;
                while~isempty(varNode)
                    if strcmp(varNode.kind,'ID')&&strcmp(string(varNode),varName)
                        break;
                    end
                    varNode=varNode.Next;
                end
                if~isempty(varNode)
                    varLink=this.getLink(this.FunctionTypeInfo.scriptPath,varNode);
                    callSiteLink=this.getLink(callerFcn.scriptPath,callNode);
                    msg=coder.internal.lib.Message.buildMessage(this.FunctionTypeInfo,varNode,coder.internal.lib.Message.WARN,...
                    'Coder:FXPCONV:DTS_InputIndexVarFloatingPoint',{varLink,callSiteLink,this.FunctionTypeInfo.functionName});
                    this.Cause(varName)=msg;
                end
            end
        end

        function addOutputCause(this,varName,callerFcn,callNode)
            if~this.Cause.isKey(varName)
                varNode=this.FunctionTypeInfo.tree.Outs;
                while~isempty(varNode)
                    if strcmp(string(varNode),varName)
                        break;
                    end
                    varNode=varNode.Next;
                end
                if~isempty(varNode)
                    varLink=this.getLink(this.FunctionTypeInfo.scriptPath,varNode);
                    callSiteLink=this.getLink(callerFcn.scriptPath,callNode);
                    msg=coder.internal.lib.Message.buildMessage(this.FunctionTypeInfo,varNode,coder.internal.lib.Message.WARN,...
                    'Coder:FXPCONV:DTS_OutputIndexVarFloatingPoint',{varLink,callSiteLink,this.FunctionTypeInfo.functionName});
                    this.Cause(varName)=msg;
                end
            end
        end

        function addCause(this,varName,node)
            if~this.Cause.isKey(varName)
                scriptPath=this.FunctionTypeInfo.scriptPath;
                locLink=this.getLink(scriptPath,node);

                msg=coder.internal.lib.Message.buildMessage(this.FunctionTypeInfo,node,coder.internal.lib.Message.WARN,...
                'Coder:FXPCONV:DTS_IndexVarFloatingPoint',{varName,locLink});

                this.Cause(varName)=msg;
            end
        end

        function link=getLink(this,scriptPath,node)
            link=sprintf('<a href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'',%s);">%s</a>',...
            scriptPath,num2str(node.lineno),strtrim(node.tree2str(0,1)));
        end
    end

    methods
        function ctx=visit(this,node,input)
            switch node.kind
            case{'EXPR','IF','SWITCH','FOR','ELSE','CASE','WHILE'}
                this.Context=this.GeneralContext;
            end
            origCtx=this.Context;
            ctx=this.visit@coder.internal.MTreeVisitor(node,input);
            this.Context=origCtx;
            if isa(ctx,'double')
                ctx=this.Context;
            end
        end

        function ctx=visitGLOBAL(this,node,input)
            ctx=this.NonIndexingContext;
            varNode=node.Arg;
            while~isempty(varNode)
                var=string(varNode);
                this.NonIndexingContext(var)={varNode};
                varNode=varNode.Next;
            end
        end

        function ctx=visitID(this,node,input)
            varName=string(node);
            varInfo=this.FunctionTypeInfo.getVarInfo(node);
            if~isempty(varInfo)
                if~this.Context.isKey(varName)
                    this.Context(varName)={node};
                    this.Dirty=this.Dirty+1;

                    if this.Context==this.NonIndexingContext

                        try
                            this.addCause(varName,node.Parent);
                        catch
                            this.addCause(varName,node);
                        end
                    end
                end

                locs=this.Context(varName);
                locs{end+1}=node;
                this.Context(varName)=locs;

                candidate=false;
                alreadyIndexType=false;
                if varInfo.isNumericVar()&&...
                    ~varInfo.isVarInSrcComplex()&&...
                    ~varInfo.isSpecialized


                    switch varInfo.inferred_Type.Class
                    case{'double','single'},candidate=true;
                    case this.IndexType,alreadyIndexType=true;
                    end
                end

                if~candidate&&~alreadyIndexType&&~this.NonIndexingContext.isKey(varName)

                    this.NonIndexingContext(varName)={node};
                end
            end
            if this.NonIndexingContext.isKey(varName)
                ctx=this.NonIndexingContext;
            elseif this.IndexingContext.isKey(varName)
                ctx=this.IndexingContext;
            else
                ctx=this.Context;
            end
        end


        function ctx=visitSiblingNodes(this,input,varargin)
            ctx=this.Context;
            if numel(varargin)==1&&iscell(varargin{1})
                nodes=varargin{1};
            else
                nodes=varargin;
            end

            if isempty(nodes)
                return;
            end

            anyNonIndexing=false;
            for ii=1:numel(nodes)
                node_ctx=this.visit(nodes{ii},input);
                if node_ctx==this.NonIndexingContext
                    anyNonIndexing=true;
                    break;
                end
            end

            if anyNonIndexing
                this.Context=this.NonIndexingContext;
                for ii=1:numel(nodes)
                    this.visit(nodes{ii},input);
                end

                this.Context=ctx;
                ctx=this.NonIndexingContext;
            end
        end

        function ctx=visitLB(this,node,input)
            row=node.Arg;
            if row.iskind('ROW')
                items={};
                while~isempty(row)
                    elem=row.Arg;
                    while~isempty(elem)
                        items{end+1}=elem;
                        elem=elem.Next;
                    end
                    row=row.Next;
                end

                ctx=this.visitSiblingNodes(input,items);
            elseif~isempty(row)
                lhsArgs=row;
                ctx=this.visitNodeList(lhsArgs,input);
            else
                ctx=this.Context;
            end
        end

        function ctx=visitRELBINEXPR(this,node,input)
            this.visitSiblingNodes(input,{node.Left,node.Right});
            ctx=this.GeneralContext;
        end

        function s=isNonScalar(this,node)
            s=true;
            typeInfo=this.FunctionTypeInfo.getOriginalTypeInfo(node);
            if~isempty(typeInfo)
                s=any(typeInfo.SizeDynamic)||prod(typeInfo.Size)>1;
            end
        end

        function ctx=visitBINEXPR(this,node,input)
            origCtx=this.Context;
            switch node.kind
            case{'PLUS','MINUS','DOTMUL'}

            case{'MUL'}
                if this.isNonScalar(node.Left)&&this.isNonScalar(node.Right)

                    this.Context=this.NonIndexingContext;
                else




                end
            otherwise
                this.Context=this.NonIndexingContext;
            end

            ctx=this.visitSiblingNodes(input,node.Left,node.Right);
            this.Context=origCtx;
        end

        function ctx=visitSUBSCR(this,node,input)
            if strcmp(node.Left.kind,'DOT')&&strcmp(node.Left.tree2str,'coder.unroll')


                arg=node.Right;
                if~isempty(arg)
                    ctx=this.visit(arg,input);
                else
                    ctx=this.Context;
                end
                return;
            end
            ctx=this.Context;
            this.Context=this.IndexingContext;
            if~isempty(node.Right)
                this.visitNodeList(node.Right,input);
            end
            this.Context=ctx;
            ctx=this.visit(node.Left,input);
        end

        function ctx=visitDOTBINEXPR(this,node,input)
            ctx=this.Context;
            this.Context=this.NonIndexingContext;
            this.visit(node.Left,input);
            this.visit(node.Right,input);
            this.Context=ctx;
            ctx=this.NonIndexingContext;
        end

        function ctx=visitDOT(this,node,input)

            this.visit(node.Left,input);
            ctx=this.NonIndexingContext;
        end

        function ctx=visitEQUALS(this,node,input)
            ctx=this.GeneralContext;
            rhsCtx=this.visit(node.Right,input);
            if strcmp(node.Left.kind,'LB')
                if~iscell(rhsCtx)

                    rhsCtx={rhsCtx};
                end
                lhsNode=node.Left.Arg;
                ii=1;
                while~isempty(lhsNode)&&ii<=numel(rhsCtx)
                    this.Context=rhsCtx{ii};
                    this.visit(lhsNode,input);
                    lhsNode=lhsNode.Next;
                    ii=ii+1;
                end
            else
                if iscell(rhsCtx)
                    rhsCtx=rhsCtx{1};
                end

                this.Context=rhsCtx;
                this.visit(node.Left,input);
                this.Context=this.GeneralContext;
                ctx=this.Context;
            end
        end

        function classifyVar(this,context,varName,node)
            assert(context==this.IndexingContext||...
            context==this.NonIndexingContext||...
            context==this.GeneralContext);

            varInfo=this.FunctionTypeInfo.getVarInfo(varName);
            if~isempty(varInfo)&&~varInfo.isSpecialized()&&varInfo.isNumericVar()
                if~context.isKey(varName)
                    context(varName)={node};
                    this.Dirty=this.Dirty+1;
                end
            end
        end

        function ctx=getCorrespondingContext(this,other,ctx)
            if ctx==other.IndexingContext
                ctx=this.IndexingContext;
            elseif ctx==other.NonIndexingContext
                ctx=this.NonIndexingContext;
            else
                ctx=this.GeneralContext;
            end
        end

        function ctx=visitCALL(this,node,input)
            callNode=node;
            ctx=this.Context;
            origCtx=this.Context;
            argsList={};
            arg=node.Right;
            while~isempty(arg)
                argsList{end+1}=arg;
                arg=arg.Next;
            end

            if~isempty(this.Attributes(node).CalledFunction)


                calleeTypeInfo=this.Attributes(node).CalledFunction;
                calleeAnalyzer=this.Analyzers(calleeTypeInfo.specializationName);


                inputVarNames=calleeTypeInfo.inputVarNames;
                for ii=1:numel(argsList)
                    argNode=argsList{ii};
                    if ii<=numel(inputVarNames)
                        inVar=inputVarNames{ii};


                        this.Context=this.GeneralContext;
                        argCtx=this.visit(argNode,input);
                        corresPondingCtx=calleeAnalyzer.getCorrespondingContext(this,argCtx);
                        if corresPondingCtx==calleeAnalyzer.NonIndexingContext
                            if~strcmp(inVar,'~')
                                calleeAnalyzer.addInputCause(inVar,this.FunctionTypeInfo,callNode);
                            end
                        end
                        calleeAnalyzer.classifyVar(corresPondingCtx,inVar,argNode);
                    else

                        this.Context=this.NonIndexingContext;
                        argCtx=this.visit(argNode,input);
                    end
                end




                this.Context=ctx;


                outputVarNames=calleeTypeInfo.outputVarNames;

                callInNonIndexingContext=this.Context==this.NonIndexingContext;
                if callInNonIndexingContext
                    for ii=1:numel(outputVarNames)
                        outVar=outputVarNames{ii};
                        if callInNonIndexingContext
                            try
                                calleeAnalyzer.addOutputCause(outVar,this.FunctionTypeInfo,callNode.Parent);
                            catch ex
                                calleeAnalyzer.addOutputCause(outVar,this.FunctionTypeInfo,callNode);
                            end
                            calleeAnalyzer.classifyVar(calleeAnalyzer.getCorrespondingContext(this,this.Context),outVar,node);
                        end
                        break;
                    end
                end

                calleeAnalyzer.analyze();

                for ii=1:numel(argsList)
                    if ii<=numel(inputVarNames)
                        inVar=inputVarNames{ii};
                        inVarInfo=calleeTypeInfo.getVarInfo(inVar);
                        if~isempty(inVarInfo)&&~inVarInfo.isSpecialized()&&inVarInfo.isNumericVar()
                            if calleeAnalyzer.NonIndexingContext.isKey(inVar)
                                this.Context=this.NonIndexingContext;
                            elseif calleeAnalyzer.IndexingContext.isKey(inVar)
                                this.Context=this.IndexingContext;
                            else
                                this.Context=this.GeneralContext;
                            end
                            argNode=argsList{ii};
                            this.visit(argNode,input);
                        end
                    end
                end

                ctx={};


                for ii=1:numel(outputVarNames)
                    ctx{end+1}=this.NonIndexingContext;

                    outVar=outputVarNames{ii};
                    outVarInfo=calleeTypeInfo.getVarInfo(outVar);
                    if~isempty(outVarInfo)&&~outVarInfo.isSpecialized()&&outVarInfo.isNumericVar()
                        if calleeAnalyzer.NonIndexingContext.isKey(outVar)
                            ctx{end}=this.NonIndexingContext;
                        elseif calleeAnalyzer.IndexingContext.isKey(outVar)
                            ctx{end}=this.IndexingContext;
                        else
                            ctx{end}=this.GeneralContext;
                        end
                    end
                end

                if numel(ctx)==1
                    ctx=ctx{1};
                end
                try
                    if~strcmp(node.Parent.kind,'EQUALS')&&iscell(ctx)&&numel(ctx)==1
                        ctx=ctx{1};
                    end
                catch
                end

                this.Context=origCtx;
            else
                callee=string(node.Left);
                switch callee
                case{'size','numel','length','ndims','sub2ind'}
                    this.Context=this.GeneralContext;
                    this.visitNodeList(node.Right,input);
                    this.Context=ctx;
                    ctx=this.IndexingContext;

                case{'end'}
                    ctx=this.IndexingContext;

                case{'flipdim','flip','fliplr','flipud',...
                    'shiftdim','circshift','fftshift',...
                    'permute','rot90',...
                    'repmat','reshape','squeeze'}
                    firstArg=node.Right;
                    firstArgCtx=this.Context;

                    if~isempty(firstArg)
                        this.Context=this.GeneralContext;
                        firstArgCtx=this.visit(firstArg,input);
                        secondArg=firstArg.Next;
                        if~isempty(secondArg)
                            this.Context=this.GeneralContext;
                            this.visitNodeList(secondArg,input);
                        end
                        this.Context=origCtx;
                    end
                    ctx=firstArgCtx;


                case{'isempty'}
                    this.Context=this.GeneralContext;
                    this.visitNodeList(node.Right,input);
                    this.Context=ctx;
                case{'zeros','eye','ones','true','false'}
                    this.Context=this.IndexingContext;
                    this.visitNodeList(node.Right,input);
                    this.Context=ctx;
                    ctx=this.GeneralContext;

                case{'floor','ceil'}
                    this.Context=this.NonIndexingContext;
                    this.visitNodeList(node.Right,input);
                    this.Context=ctx;

                    ctx=this.GeneralContext;

                case{'mod'}
                    this.Context=this.GeneralContext;
                    newCtx=this.visitSiblingNodes(input,argsList);
                    this.Context=ctx;
                    ctx=newCtx;

                case{'double','single','fi','logical',...
                    'int8','int16','int32','int64',...
                    'uint8','uint16','uint32','uint64',...
                    'cast'}

                    ctx=this.Context;
                    this.Context=this.GeneralContext;
                    this.visit(argsList{1},input);
                    this.Context=ctx;
                    if strcmp(callee,this.IndexType)
                        ctx=this.GeneralContext;
                    else
                        ctx=this.NonIndexingContext;
                    end

                case{'min','max'}
                    ctx=this.visitSiblingNodes(input,argsList);

                case{'sort'}
                    ctx=this.Context;
                    arg1Ctx=this.visit(node.Right,input);
                    arg2=node.Right.Next;
                    if~isempty(arg2)
                        this.visitNodeList(arg2,input);
                    end
                    this.Context=ctx;
                    if strcmp(node.Parent.kind,'EQUALS')
                        ctx={arg1Ctx,this.IndexingContext};
                    else
                        ctx=arg1Ctx;
                    end

                otherwise
                    this.Context=this.NonIndexingContext;
                    this.visitNodeList(node.Right,input);
                    this.Context=ctx;
                    ctx=this.NonIndexingContext;
                end

                this.Context=origCtx;
            end
        end

        function ctx=visitFOR(this,forNode,input)


            this.Context=this.GeneralContext;
            this.visitBody(forNode.Body,input);


            this.Context=this.IndexingContext;
            vecCtx=this.visit(forNode.Vector,input);

            this.Context=vecCtx;
            this.visit(forNode.Index,input);

            this.Context=this.GeneralContext;
            ctx=this.GeneralContext;
        end

        function ctx=visitCOLON(this,node,input)
            nodes={};
            ctx=this.Context;
            if~isempty(node.Left)
                nodes{end+1}=node.Left;
            end
            if~isempty(node.Right)
                nodes{end+1}=node.Right;
            end
            if~isempty(nodes)
                ctx=this.visitSiblingNodes(input,nodes);
            end
        end

        function ctx=visitLITERAL(this,node,input)
            switch node.kind
            case{'INT'},ctx=this.GeneralContext;
            case{'DOUBLE','CHARVECTOR'},ctx=this.NonIndexingContext;
            otherwise
                ctx=this.NonIndexingContext;
            end
        end

    end
end
