function varargout=staticAnalysis(funfcn,inputs,varargin)















































    pnames={'InMemory','ForLoopOnly'};
    dflts={true,true};
    [InMemory,ForLoopOnly]...
    =matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:});


    ASTVisitorBody=matlab.lang.internal.generateTranslation(...
    funfcn,'forLoopVisitor');


    if InMemory

        folder="OptimASTVisitor"+replace(matlab.lang.internal.uuid(),"-","0");
        clearVFS=onCleanup(@()optim.internal.problemdef.clearoptiminmem(folder));
        visFcn=optim.internal.problemdef.writeCompiledFun2VirtualFile(...
        "forLoopVisitor",ASTVisitorBody,folder);
    else
        optim.internal.problemdef.writeCompiledFun2StandardFile(...
        "forLoopVisitor",ASTVisitorBody,pwd);
        visFcn=@forLoopVisitor;
    end


    Analyze=true;
    if ForLoopOnly

        FLDetector=optim.internal.problemdef.ast.ForLoopDetector;
        visFcn(FLDetector);
        Analyze=getOutputs(FLDetector);
    end



    if Analyze

        staticVisitor=optim.internal.problemdef.ast.CreateStaticExpr(inputs);
        stmt=visFcn(staticVisitor);
        nOutputs=nargout;
        varargout=getOutputs(staticVisitor,stmt,nOutputs);
    else

        error('shared_adlib:static','Static Analysis did not run. Try setting ''ForLoopOnly'' to false.');
    end