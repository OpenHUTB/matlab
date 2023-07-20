classdef RedundantCastAnnotator<coder.internal.MTreeVisitor
    properties
Attributes
Scopes
PersistentVars
InputVars
DontTouchVars
DoubleToSingle
FunctionTypeInfo
    end

    methods(Access=public)
        function this=RedundantCastAnnotator(attributes,doubleToSingle)
            this.Attributes=attributes;
            this.Scopes={};
            this.PersistentVars={};
            this.DontTouchVars={};
            this.DoubleToSingle=doubleToSingle;
        end

        function run(this,functionNode,functionTypeInfo)
            this.DontTouchVars=containers.Map();
            this.FunctionTypeInfo=functionTypeInfo;
            this.registerDontTouchVars(functionTypeInfo);
            this.visit(functionNode,[]);
        end
    end

    methods(Access=private)
        function r=equalTypes(~,type1,type2)
            try
                r=strcmp(type1.Class,type2.Class)&&...
                all(type1.Size==type2.Size)&&...
                all(type1.SizeDynamic==type2.SizeDynamic);
            catch ex %#ok<NASGU>
                r=false;
            end
        end
    end

    methods(Access=public)
        function registerDontTouchVars(this,functionTypeInfo)
            varNames=functionTypeInfo.getAllVarNames();
            for ii=1:length(varNames)
                varName=varNames{ii};
                varInfos=functionTypeInfo.getVarInfosByName(varName);
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    if varInfo.isStruct()||varInfo.isVarInSrcSystemObj()...
                        ||varInfo.isMCOSClass()
                        this.DontTouchVars(varName)=true;
                        break;
                    end

                    if any(varInfo.inferred_Type.SizeDynamic)

                        this.DontTouchVars(varName)=true;
                        break;
                    end

                    if varInfo.isSpecialized()
                        this.DontTouchVars(varName)=true;
                        break;
                    end

                    supportedType=varInfo.isNumericVar()||varInfo.isStruct()||varInfo.isVarInSrcBoolean()...
                    ||varInfo.isEnum()||varInfo.isVarInSrcChar();
                    if~supportedType
                        this.DontTouchVars(varName)=true;
                        break;
                    end
                end
            end
        end

        function output=visitFUNCTION(this,functionNode,input)
            this.Scopes={containers.Map()};
            this.PersistentVars=containers.Map();
            this.InputVars=containers.Map();
            inputVarNames=this.FunctionTypeInfo.inputVarNames;
            for ii=1:numel(inputVarNames)
                var=inputVarNames{ii};
                this.InputVars(var)=true;
            end
            output=this.visitFUNCTION@coder.internal.MTreeVisitor(functionNode,input);
        end

        function output=visitPERSISTENT(this,node,input)%#ok<INUSD>
            output=[];
            var=node.Arg;
            while~isempty(var)
                varName=string(var);
                this.PersistentVars(varName)=true;
                var=var.Next;
            end
        end

        function output=visitFOR(this,forNode,input)

            forScope=containers.Map();

            this.Scopes{end+1}=forScope;
            output=this.visitFOR@coder.internal.MTreeVisitor(forNode,input);
            this.Scopes(end)=[];



        end

        function output=visitWHILE(this,whileNode,input)

            whileScope=containers.Map();

            this.Scopes{end+1}=whileScope;
            output=this.visitWHILE@coder.internal.MTreeVisitor(whileNode,input);
            this.Scopes(end)=[];



        end

        function output=visitIF(this,node,input)
            output=[];
            branches={};

            branch=node.Arg;
            while~isempty(branch)
                branches{end+1}=branch;%#ok<AGROW>
                branch=branch.Next;
            end

            this.visitControlFlowBranches(branches,input);
        end

        function output=visitSWITCH(this,node,input)
            output=[];
            branches={};

            branch=node.Body;
            while~isempty(branch)
                branches{end+1}=branch;%#ok<AGROW>
                branch=branch.Next;
            end

            this.visitControlFlowBranches(branches,input);
        end

        function mergeControlFlowBranchScopes(this,branchScopes)

            definedVars=branchScopes{1};
            varNames=definedVars.keys();
            parentScope=this.Scopes{end};
            for ii=1:length(varNames)
                varName=varNames{ii};
                varInfo=definedVars(varName);
                definedInAllBranches=true;

                for jj=2:length(branchScopes)
                    otherBranchScope=branchScopes{jj};
                    if~otherBranchScope.isKey(varName)
                        definedInAllBranches=false;
                        break;
                    end

                end

                if definedInAllBranches
                    parentScope(varName)=varInfo;
                end
            end
        end

        function visitControlFlowBranches(this,branches,input)
            branchScopes={};
            for ii=1:length(branches)
                branch=branches{ii};
                branchScope=containers.Map();
                branchScopes{end+1}=branchScope;%#ok<AGROW>
                this.Scopes{end+1}=branchScope;
                this.visitBody(branch.Body,input);
                this.Scopes(end)=[];
            end


        end

        function visitSingleLHSNode(this,lhs,rhsType)
            if strcmp(lhs.kind,'SUBSCR')||strcmp(lhs.kind,'LP')
                if strcmp(lhs.Left.kind,'ID')
                    varExpr=string(lhs.Left);
                else

                    return;
                end
            elseif strcmp(lhs.kind,'CELL')
                return;
            elseif strcmp(lhs.kind,'DOT')

                return;
            elseif strcmp(lhs.kind,'DOTLP')

                return;
            elseif strcmp(lhs.kind,'NOT')

                return;
            else

                varExpr=string(lhs);
            end

            varExpr=strtrim(varExpr);
            if this.DontTouchVars.isKey(varExpr)
                return;
            end

            assign=getLastAssignment(varExpr);

            if~isempty(assign)


                this.Attributes(lhs).IsCastRedundant=true;

                if~strcmp(lhs.kind,'SUBSCR')&&~strcmp(lhs.kind,'LP')
                    this.Attributes(lhs).UseColonSyntax=true;
                end
            else

                if this.DoubleToSingle
                    try
                        lhsVarInfo=this.FunctionTypeInfo.getVarInfo(lhs);
                        varIsOriginallySingle=strcmp(lhsVarInfo.inferred_Type.Class,'single');
                        if varIsOriginallySingle
                            this.Attributes(lhs).IsCastRedundant=true;
                        end
                    catch ex
                    end
                end
            end

            if this.PersistentVars.isKey(varExpr)
                outermostScope=this.Scopes{1};
                outermostScope(varExpr)=true;%#ok<NASGU>
            else
                currentScope=this.Scopes{end};
                currentScope(varExpr)=true;%#ok<NASGU>
            end

            function assign=getLastAssignment(qualifiedVarName)
                assign=[];
                for ii=length(this.Scopes):-1:1
                    scope=this.Scopes{ii};
                    if scope.isKey(qualifiedVarName)
                        assign=scope(qualifiedVarName);
                        return;
                    end
                end
            end
        end

        function output=visitEQUALS(this,assignNode,~)
            output=[];
            lhs=assignNode.Left;
            rhs=assignNode.Right;

            [isGrowAssgn,~,lhsNode]=coder.internal.translator.Phase.isGrowingAssignment(assignNode);
            if isGrowAssgn
                varInfo=this.FunctionTypeInfo.getVarInfo(lhsNode);
                if any(varInfo.inferred_Type.SizeDynamic)
                    this.Attributes(lhs).IsCastRedundant=true;
                    this.Attributes(lhs).UseColonSyntax=false;
                    return;
                end
            end

            omitCast=false;
            if this.DoubleToSingle
                if this.isRHSSingle(rhs)&&this.isSingle(lhs)
                    if strcmp(rhs.kind,'ID')&&~this.FunctionTypeInfo.isDesign





                        varName=string(rhs);
                        if this.InputVars.isKey(varName)
                            omitCast=false;
                        else


                            omitCast=true;
                        end
                    else

                        omitCast=true;
                    end
                end
            end

            if strcmp(lhs.kind,'LB')
                lhs=lhs.Arg;
                lhsIDs={};
                while~isempty(lhs)
                    if omitCast
                        this.Attributes(lhs).IsCastRedundant=true;
                    end
                    if strcmp(lhs.kind,'ID')
                        lhsID=string(lhs);
                        if any(ismember(lhsIDs,lhsID))


                            lhs=lhs.Next;
                            continue;
                        end
                        lhsIDs{end+1}=lhsID;
                    end
                    this.visitSingleLHSNode(lhs);
                    lhs=lhs.Next;
                end
            else
                if omitCast
                    this.Attributes(lhs).IsCastRedundant=true;
                end
                this.visitSingleLHSNode(lhs);
            end
        end

        function res=isRHSSingle(this,rhs)
            res=this.isSingle(rhs);
        end

        function res=isSingleVarInfo(this,varTypeInfo)
            if~isempty(varTypeInfo)&&varTypeInfo.isNumericVar()...
                &&ischar(varTypeInfo.annotated_Type)&&strcmp(varTypeInfo.annotated_Type,'single')
                res=true;
            else
                res=false;
            end
        end

        function res=isSingle(this,node)
            res=false;
            if~isempty(this.Attributes(node).CalledFunction)
                calleeTypeInfo=this.Attributes(node).CalledFunction;
                outputVarNames=calleeTypeInfo.outputVarNames;
                res=true;
                for ii=1:numel(outputVarNames)
                    outVar=outputVarNames{ii};
                    outVarInfo=calleeTypeInfo.getVarInfo(outVar);
                    if~isempty(outVarInfo)
                        if~outVarInfo.isSpecialized()&&outVarInfo.isNumericVar()
                            res=this.isSingleVarInfo(outVarInfo);
                        else
                            res=false;
                        end
                    end
                    if~res
                        break;
                    end
                end
            else
                switch node.kind
                case{'PLUS','MINUS','MUL','DIV','EXP','DOTMUL','DOTDIV','DOTLDIV','DOTEXP'}
                    res=this.isSingle(node.Left)||this.isSingle(node.Right);
                case 'SUBSCR'
                    matStr=strtrim(node.Left.tree2str(0,1));
                    switch matStr
                    case{'coder.nullcopy'}
                        res=this.isSingle(node.Right);
                    otherwise
                        res=this.isSingle(node.Left);
                    end
                case 'ID'
                    varInfo=this.FunctionTypeInfo.getVarInfo(node);
                    if~isempty(varInfo)
                        if this.isSingleVarInfo(varInfo)
                            res=true;
                        end
                    end
                case{'CALL'}

                    argsSingle=false;
                    arg=node.Right;
                    while~isempty(arg)
                        argsSingle=argsSingle&&this.isSingle(arg);
                        arg=arg.Next;
                    end



                    switch node.Left.tree2str(0,0)

                    case{'flipdim','flip','fliplr','flipud',...
                        'shiftdim','circshift','fftshift',...
                        'permute','rot90',...
                        'repmat','reshape','squeeze',...
                        'sort'}
                        firstArg=node.Right;
                        if~isempty(firstArg)
                            res=this.isSingle(firstArg);
                            return;
                        end
                    end

                    if argsSingle
                        switch node.Left.tree2str(0,0)

                        case{'length','ndims','numel','size','height','width',...
                            'iscolumn','isempty','ismatrix','isrow','isscalar','isvector'}


                        case{'ones','zeros','eye'}

                            res=false;
                        otherwise
                            res=true;
                        end
                    end
                end
            end
        end
    end
end