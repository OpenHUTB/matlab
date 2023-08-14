function text=updateMatlabCode(contextNode,text,oldNode,newFile,updateName)






    oldFile=oldNode.Location{1};
    oldSymbol=matlab.internal.language.introspective.containers.getQualifiedFileName(oldFile);


    [~,oldName]=fileparts(oldFile);
    [~,newName]=fileparts(newFile);
    oldLength=length(oldName);


    tree=mtree(text);
    pos=[i_findFunctionCalls(contextNode,text,oldNode,oldSymbol)...
    ,i_findSuperClasses(tree,oldSymbol)...
    ,i_findStaticProperties(tree,oldSymbol)];
    if updateName
        pos=[pos,i_findFunctionOrClassName(tree,oldSymbol)];
    end


    pos=flip(unique(pos));
    for n=1:length(pos)
        text=[text(1:pos(n)-1),newName,text(pos(n)+oldLength:end)];
    end

end


function pos=i_findFunctionCalls(contextNode,code,oldNode,symbol)



    import dependencies.internal.analysis.DependencyFactory;
    import dependencies.internal.analysis.matlab.handlers.CustomFunctionAnalyzer;

    handler=dependencies.internal.analysis.Handler(...
    @(id,msg)[],...
    @(err)rethrow(err));


    resolvedOldNode=dependencies.internal.graph.Node(oldNode.Location,oldNode.Type,true);
    handler.Analyzers.MATLAB.insert(contextNode,symbol,resolvedOldNode);

    root=dependencies.internal.graph.Component.createRoot(contextNode);
    factory=DependencyFactory(handler,root,'');

    positions=dependencies.internal.util.Reference;
    funcAnalyzer=CustomFunctionAnalyzer(...
    @(~,ref,~)i_processFunctionCall(positions,ref),...
    symbol);

    emptyWs=dependencies.internal.analysis.matlab.Workspace.empty;
    handler.Analyzers.MATLAB.analyze(code,factory,emptyWs,funcAnalyzer);

    pos=positions.Value;

end


function refs=i_processFunctionCall(positions,ref)



    refs=dependencies.internal.analysis.matlab.Reference.empty;

    if strcmp(ref.Type,'FunctionCall')
        positions.Value(end+1)=ref.Function.Position;
    end

end


function pos=i_findSuperClasses(tree,symbol)


    if~isempty(tree.Cexpr)
        classes=tree.Cexpr.Right.Full.mtfind('Kind','ID','String',symbol);
        methods=tree.mtfind('Kind','ATBASE').Right.mtfind('String',symbol);
        pos=[classes.position',methods.position'];


        dotIdx=strfind(symbol,'.');
        if~isempty(dotIdx)
            pos=pos+dotIdx(end);
        end

    else
        pos=[];
    end

end

function pos=i_findFunctionOrClassName(tree,symbol)



    parts=split(symbol,".");
    symbol=parts{end};

    indices=[];
    if tree.root.iskind('FUNCTION')
        indices=tree.Fname.indices;
    elseif~isempty(tree.Cexpr)
        indices=tree.Cexpr.Left.indices;
        if isempty(indices)
            indices=tree.Cexpr.indices;
        end
        indices=[indices...
        ,tree.mtfind('Kind','METHODS').Full.mtfind('Kind','FUNCTION').Fname.indices];
    end

    pos=i_findPositionForMatchingIndices(tree,indices,symbol);

end

function pos=i_findStaticProperties(tree,symbol)
    fieldDots=tree.mtfind('Kind','DOT','Right.Kind','FIELD','Left.Kind','ID');
    indices=[fieldDots.Left.indices];

    pos=i_findPositionForMatchingIndices(tree,indices,symbol);
end

function pos=i_findPositionForMatchingIndices(tree,indices,symbol)
    pos=[];
    for idx=indices
        node=tree.select(idx);
        if strcmp(node.string,symbol)
            pos=[pos,node.position];%#ok<AGROW>
        end
    end
end
