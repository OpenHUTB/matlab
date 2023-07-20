function typeChain=getTypeChain(studio)


    root=coder.internal.toolstrip.util.getCodeGenRoot(studio.App.getActiveEditor);
    current=studio.App.getActiveEditor.blockDiagramHandle;


    defaultCtx='OneCoderAppContext';


    if isempty(root)
        cgbCtx='NoCodeGenContext';
        typeChain={defaultCtx,cgbCtx};
        return;
    end

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [app,~,lang,appName]=cp.getInfo(root);


    appCtx=[appName,'Context'];


    layoutCtx=[app,'_',lang,'_Context'];


    outputCtx=coder.internal.toolstrip.util.getOutputContext(root);


    libCtx='libraryContext';


    isGenCodeOnly=strcmpi(get_param(root,'GenCodeOnly'),'on');
    if isGenCodeOnly
        buildCtx='generateCodeOnlyContext';
    else
        buildCtx='generateCodeAndBuildContext';
    end


    typeChain={defaultCtx,appCtx,layoutCtx,outputCtx,libCtx,buildCtx};


    if root~=current
        typeChain{end+1}='UnderCodeGenRoot';
    end
