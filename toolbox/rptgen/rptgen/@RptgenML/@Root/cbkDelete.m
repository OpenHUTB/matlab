function actionPerformed=cbkDelete(this,justTesting,currSelect)




    actionPerformed=false;
    if~isa(this.Editor,'DAStudio.Explorer')
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

    if~isa(currSelect,'DAStudio.Object')&&~isa(currSelect,'Simulink.DABaseObject')
        actionPerformed=false;
    else
        try
            actionPerformed=isDeletable(currSelect);
        catch ME
            warning(ME.message);
            actionPerformed=false;
        end
    end

    if~actionPerformed||justTesting
        return;
    end


    nextView=right(currSelect);
    if isempty(nextView)
        nextView=left(currSelect);
    end
    if isempty(nextView)
        nextView=up(currSelect);
    end


    try
        actionPerformed=doDelete(currSelect);
    catch ME
        warning(ME.message);
        actionPerformed=false;
        return;
    end


    if actionPerformed
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',nextView);
        this.Editor.view(nextView);
    end
