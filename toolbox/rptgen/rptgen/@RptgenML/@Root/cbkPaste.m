function actionPerformed=cbkPaste(this,justTesting,currSelect)




    actionPerformed=false;
    if isempty(this.HandleClipboard)||~isa(this.Editor,'DAStudio.Explorer')
        return;
    end

    if nargin<2
        justTesting=false;
    end

    if nargin<3
        ime=DAStudio.imExplorer;
        ime.setHandle(this.Editor);
        currSelect=ime.getCurrentTreeNode;
    end

    try
        actionPerformed=canAcceptDrop(currSelect,this.HandleClipboard);
    catch ME
        warning(ME.identifier,ME.message);
        actionPerformed=false;
    end

    if~actionPerformed||justTesting
        return;
    end


    try


        copiedClipboard=doCopy(this.HandleClipboard);
    catch ME
        warning(ME.identifier,ME.message);
        actionPerformed=false;
        return;
    end

    actionPerformed=acceptDrop(currSelect,copiedClipboard);



    if actionPerformed&&isa(copiedClipboard,'rptgen.DAObject')


        this.Editor.view(copiedClipboard);
    end