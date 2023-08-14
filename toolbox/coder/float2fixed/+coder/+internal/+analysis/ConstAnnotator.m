classdef ConstAnnotator<coder.internal.MTreeVisitor

    methods(Static)
        function messages=run(functionInfoRegistry)
            messages=coder.internal.lib.Message.empty;
            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();
            for ii=1:numel(fcnTypeInfos)
                functionTypeInfo=fcnTypeInfos{ii};
                analyzer=coder.internal.analysis.ConstAnnotator(functionTypeInfo,analyzers);
                analyzers(functionTypeInfo.specializationName)=analyzer;

                if true
                    if functionTypeInfo.isDesign

                        argInitialConstness=false;
                    else
                        argInitialConstness=true;
                    end

                    inputVars=functionTypeInfo.inputVarNames;
                    for jj=1:numel(inputVars)
                        inVar=inputVars{jj};
                        analyzer.markVarInCurrentScope(inVar,argInitialConstness);
                    end
                end
            end

            analyzers=analyzers.values();
            runAll(analyzers);

            function runAll(analyzers)
                iterations=1;
                while iterations<=100
                    for kk=1:numel(analyzers)
                        analyzers{kk}.Dirty=false;
                    end

                    for kk=1:numel(analyzers)
                        if analyzers{kk}.FunctionTypeInfo.isDesign

                            analyzers{kk}.analyze();
                        end
                    end

                    changed=false;

                    for kk=1:numel(analyzers)
                        changed=changed||analyzers{kk}.Dirty;
                    end

                    if~changed
                        break;
                    end
                    iterations=iterations+1;
                end
            end

            for ii=1:numel(analyzers)
                analyzers{ii}.debugPrint();
            end
        end
    end

    properties
FunctionTypeInfo
Attributes
Analyzers

NonConstVars
Scopes
Dirty

replacements
Print
    end

    methods
        function this=ConstAnnotator(functionTypeInfo,analyzers)
            this.FunctionTypeInfo=functionTypeInfo;
            this.Attributes=functionTypeInfo.treeAttributes;
            this.NonConstVars=containers.Map();
            this.Analyzers=analyzers;
            this.Dirty=true;
            this.replacements={};
            this.Print=false;
            this.beginScope();
        end

        function analyze(this)
            this.visit(this.FunctionTypeInfo.tree,[]);
        end
    end

    methods
        function scope=beginScope(this)
            scope=containers.Map();
            this.Scopes{end+1}=scope;
        end

        function scope=endScope(this)
            scope=this.Scopes{end};
            this.Scopes(end)=[];
        end
    end

    methods
        function isConst=visit(this,node,input)
            if~this.Print
                isConst=this.visit@coder.internal.MTreeVisitor(node,input);
                if isempty(isConst)
                    isConst=false;
                end

                if~isConst

                    compiledMxLocInfo=this.Attributes(node).CompiledMxLocInfo;
                    if~isempty(compiledMxLocInfo)
                        if compiledMxLocInfo.MxValueID<0

                        end
                    end
                end

                this.Attributes(node).IsConstant=isConst;
            else
                if this.Attributes(node).IsConstant
                    scriptPath=this.FunctionTypeInfo.scriptPath;
                    str=node.tree2str(0,1);
                    lines=strsplit(str,char(10));
                    lineno=node.lineno;
                    for ii=1:numel(lines)
                        str=lines{ii};
                        if numel(str)>500
                            str=[str(1:500),'...'];
                        end
                        lines{ii}=sprintf('<a href="matlab:matlab.desktop.editor.openAndGoToLine(''%s'',%s);">%s</a>',...
                        scriptPath,num2str(lineno),str);
                        lineno=lineno+1;
                    end
                    markedUpStr=strjoin(lines,char(10));

                    this.replacements{end+1}=node;
                    this.replacements{end+1}=markedUpStr;
                    isConst=true;
                else
                    isConst=this.visit@coder.internal.MTreeVisitor(node,input);
                    if isempty(isConst)
                        isConst=false;
                    end
                end
            end
        end

        function debugPrint(this)
            this.Print=true;
            this.replacements={};
            this.visit(this.FunctionTypeInfo.tree,[]);
            code=this.FunctionTypeInfo.tree.tree2str(0,1,this.replacements);


            disp(code);
            disp(' ');
        end

        function isConst=visitNodeList(visitor,nodeList,input)
            isConst=true;
            node=nodeList;
            while~isempty(node)
                switch node.kind
                case{'COMMENT'}

                otherwise
                    isConst=visitor.visit(node,input)&&isConst;
                end

                node=node.Next;
            end
        end

        function varName=getVarName(this,node)
            varName='';
            switch node.kind
            case 'ID',varName=string(node);
            case 'SUBSCR',varName=this.getVarName(node.Left);
            end
        end

        function markVarInCurrentScope(this,varName,isConst)
            if this.NonConstVars.isKey(varName)
                return;
            end
            scope=this.Scopes{end};
            if scope.isKey(varName)
                if scope(varName)~=isConst
                    scope(varName)=isConst;
                end
            else
                scope(varName)=isConst;
            end
        end

        function isConst=getConstness(this,varName)
            isConst=false;
            for ii=numel(this.Scopes):-1:1
                scope=this.Scopes{ii};
                if scope.isKey(varName)
                    isConst=scope(varName);
                    return;
                end
            end
        end

        function transferScope(this,scope)
            currentScope=this.Scopes{end};
            vars=scope.keys();
            for ii=1:numel(vars)
                var=vars{ii};
                currentScope(var)=scope(var);
            end
        end
    end

    methods(Access=public)
        function isConst=visitFUNCTION(this,node,input)
            isConst=false;

            inp=node.Ins;
            while~isempty(inp)
                inpName=inp.tree2str(0,1);
                if~strcmp(inpName,'~')
                    scope(inpName)=false;
                end
                inp=inp.Next;
            end
            isConst=this.visitBody(node.Body,input);
        end

        function isConst=visitLITERAL(this,node,input)
            isConst=true;
        end

        function isConst=visitID(this,node,input)
            varName=string(node);
            isConst=this.getConstness(varName);
        end



        function isConst=visitGLOBAL(this,node,input)
            isConst=false;
            varNode=node.Arg;
            while~isempty(varNode)
                var=string(varNode);
                this.NonConstVars(var)=true;
                this.markVarInCurrentScope(var,false);
                this.visit(varNode,input);
                varNode=varNode.Next;
            end
        end


        function isConst=visitPERSISTENT(this,node,input)
            isConst=false;
            varNode=node.Arg;
            while~isempty(varNode)
                var=string(varNode);
                this.NonConstVars(var)=true;
                this.markVarInCurrentScope(var,false);
                this.visit(varNode,input);
                varNode=varNode.Next;
            end
        end

        function isConst=visitBINEXPR(this,node,input)
            lIsConst=this.visit(node.Left,input);
            rIsConst=this.visit(node.Right,input);
            isConst=lIsConst&&rIsConst;
        end

        function isConst=visitLOGBINEXPR(this,node,input)
            lIsConst=this.visit(node.Left,input);
            rIsConst=this.visit(node.Right,input);
            isConst=lIsConst&&rIsConst;
        end

        function isConst=visitRELBINEXPR(this,node,input)
            lIsConst=this.visit(node.Left,input);
            rIsConst=this.visit(node.Right,input);
            isConst=lIsConst&&rIsConst;
        end

        function isConst=visitSUBSCR(this,node,input)
            switch node.Left.tree2str(0,1)
            case{'coder.inline','coder.unroll'}
                isConst=this.visit(node.Right,input);
                return;
            end
            isConst=this.visit(node.Left,input);
            idxNode=node.Right;
            if~isempty(idxNode)
                idxIsConst=this.visitNodeList(idxNode,input);
                isConst=isConst&&idxIsConst;
            end
        end

        function isConst=visitCALL(this,node,input)
            isConst=false;

            if~isempty(this.Attributes(node).CalledFunction)
                isConst=this.handleUserDefinedFunctionCall(node,input);
            else
                isConst=this.handleBuiltinFunctionCall(node,input);
            end
        end

        function isConst=visitCOLON(this,node,input)
            isConst=true;
            if~isempty(node.Left)
                isConst=this.visit(node.Left,input)&&isConst;
            end
            if~isempty(node.Right)
                isConst=this.visit(node.Right,input)&&isConst;
            end
        end


        function isConst=visitFOR(this,node,input)
            idxNode=node.Index;
            idxVar=this.getVarName(idxNode);

            vectorNode=node.Vector;
            vecIsConst=this.visit(vectorNode,input);

            scope=this.beginScope();

            this.markVarInCurrentScope(idxVar,vecIsConst);


            body=node.Body;
            if~isempty(body)

                this.visitBody(body,input);



                varsAssigned=scope.keys();
                for ii=1:numel(varsAssigned)
                    var=varsAssigned{ii};
                    scope(var)=false;
                end


                secondItrScope=this.beginScope();
                isConst=this.visitBody(body,input);


                this.endScope();
                this.endScope();




                this.transferScope(scope);
            else

                isConst=vecIsConst;
                scope=this.endScope();
                this.transferScope(secondItrScope);
            end
        end


        function isConst=visitIF(this,node,input)
            isConst=true;

            branchScopes={};

            ifHead=node.Arg;
            branchScopes{end+1}=this.beginScope();
            isConst=this.visit(ifHead.Left,input)&&isConst;
            isConst=this.visitNodeList(ifHead.Body,input)&&isConst;
            this.endScope();

            branch=ifHead.Next;
            elseFound=false;
            while~isempty(branch)
                switch branch.kind
                case 'ELSEIF'
                    isConst=this.visit(branch.Left,input)&&isConst;
                    branchScopes{end+1}=this.beginScope();
                    isConst=this.visitNodeList(branch.Body,input)&&isConst;
                    this.endScope();
                case 'ELSE'
                    elseFound=true;
                    branchScopes{end+1}=this.beginScope();
                    isConst=this.visitNodeList(branch.Body,input)&&isConst;

                end
                branch=branch.Next;
            end

            mergedScope=this.mergeBranchScopes(branchScopes);



            if~elseFound
                mergedScope=this.mergeBranchScopes({this.Scopes{end},mergedScope});
            end
            this.transferScope(mergedScope);
        end

        function mergedScope=mergeBranchScopes(this,branchScopes)
            mergedScope=containers.Map();
            for ii=1:numel(branchScopes)
                branchScope=branchScopes{ii};
                vars=branchScope.keys();
                for jj=1:numel(vars)
                    var=vars{jj};
                    if mergedScope.isKey(var)
                        mergedScope(var)=mergedScope(var)&&branchScope(var);
                    else
                        mergedScope(var)=branchScope(var);
                    end
                end
            end
        end

        function isConst=handleBuiltinFunctionCall(this,node,input)
            argNode=node.Right;
            if~isempty(argNode)
                argsConst=this.visitNodeList(node.Right,input);
            else

                argsConst=true;
            end

            isConst=argsConst;

            callee=node.Left.tree2str(0,1);
            switch callee
            case{'rand','randi'}
                isConst=false;

            case{'size','length'}

                isConst=true;
            end
        end

        function isConst=handleUserDefinedFunctionCall(this,node,input)
            isConst=false;
            calleeTypeInfo=this.Attributes(node).CalledFunction;
            argNames=calleeTypeInfo.inputVarNames;
            calleeAnalyzer=this.Analyzers(calleeTypeInfo.specializationName);

            argNode=node.Right;
            idx=1;
            while~isempty(argNode)
                argIsConst=this.visit(argNode,input);
                argName=argNames{idx};

                if~argIsConst


                    if calleeAnalyzer.getConstness(argName)==true
                        calleeAnalyzer.markVarInCurrentScope(argName,false);
                        calleeAnalyzer.Dirty=true;
                    end
                end
                argNode=argNode.Next;
                idx=idx+1;
            end

            calleeAnalyzer.analyze();


            outputNames=calleeTypeInfo.outputVarNames;
            if~isempty(outputNames)
                outputVar=outputNames{1};
                isConst=calleeAnalyzer.getConstness(outputVar);
            end
        end

        function isConst=visitLB(visitor,node,input)
            isConst=true;

            row=node.Arg;
            if row.iskind('ROW')
                while(~isempty(row))
                    items=row.Arg;
                    if~isempty(items)
                        isConst=visitor.visitNodeList(items,input)&&isConst;
                    end

                    row=row.Next;
                end
            else
                lhsArgs=row;
                if~isempty(lhsArgs)
                    isConst=visitor.visitNodeList(lhsArgs,input);
                end
            end
        end

        function isConst=visitEQUALS(this,node,input)
            lhs=node.Left;
            rhs=node.Right;

            isConst=this.visit(rhs,input);
            if strcmp(lhs.kind,'LB')
                lhsNode=lhs.Arg;
                while~isempty(lhsNode)
                    lhsVar=this.getVarName(lhsNode);
                    if~isempty(lhsVar)
                        this.markVarInCurrentScope(lhsVar,false);
                    end
                    lhsNode=lhsNode.Next;
                end

                isConst=false;
            else
                lhsVar=this.getVarName(lhs);
                if~isempty(lhsVar)
                    this.markVarInCurrentScope(lhsVar,isConst);
                    isConst=this.visit(lhs,input);
                    if this.NonConstVars.isKey(lhsVar)
                        isConst=false;
                    end
                else
                    this.visit(lhs,input);
                    isConst=false;
                end


            end
        end

    end
end
