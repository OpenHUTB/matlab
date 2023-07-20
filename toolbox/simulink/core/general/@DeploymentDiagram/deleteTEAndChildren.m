function deleteTEAndChildren(te)




    if isa(te.archSelectDialog,'DAStudio.Dialog')
        delete(te.archSelectDialog);
        te.archSelectDialog=[];
    end

    deleteChildren(te.getRoot);
    te.MCOSListeners=[];
    if isa(te,'DeploymentDiagram.explorer')
        te.hide;

        te.showDialogView(true);
        delete(te);
    end


    function deleteChildren(node)

        if(~isempty(node.getChildren))
            c=node.getChildren;
        else
            c=node.getHierarchicalChildren;
        end
        for i=1:length(c)
            if iscell(c)
                deleteChildren(c{i});
            else
                deleteChildren(c(i));
            end
        end

        if isa(node,'DAStudio.DAObjectProxy')
            node=node.getMCOSObjectReference;
        end
        if isa(node,'Simulink.DistributedTarget.Mapping')
            node.shutdownExplorer();
        end
