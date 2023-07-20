function refreshExplorer(hFigure,node,selectedPath)
    try





        if~iscell(selectedPath)
            selectedPath={strsplit(selectedPath,'.')};
        end

        if isempty(hFigure)||~(hFigure.isvalid)
            return;
        end

        tree=hFigure.getPanels{1}.Figure.Children.Children;




        if~strcmp(tree.Children.Text,node.id)
            selectedPath={};
        end

        if~isempty(selectedPath)
            selectedPath=selectedPath(~cellfun('isempty',selectedPath));
        end


        oldSimlog=tree.UserData;

        tree.Children.delete;
        parentNode=uitreenode(tree,'Text',node.getName,'Tag',node.id);
        simscape.logging.internal.populateExplorerTree(parentNode,node);
        tree.expand();
        tree.UserData=node;



        if~isempty(selectedPath)

            selectedNodePaths=lGetSelectedNodePath(oldSimlog,node,selectedPath);



            if isempty(selectedNodePaths)
                tree.SelectedNodes=parentNode;
            else
                selectedTreePath=cell(1,numel(selectedNodePaths));
                for idx=1:numel(selectedTreePath)
                    selectedTreePath{idx}=lGetTreePath(tree,node,selectedNodePaths{idx});
                end


                if(numel(selectedTreePath)>1)
                    tree.SelectedNodes=[selectedTreePath{:}];
                else
                    tree.SelectedNodes=selectedTreePath{1};
                end
            end
        else
            tree.SelectedNodes=parentNode;
        end

        hFigure.Title=getMessageFromCatalog('ExplorerTitle',node.id);

    catch ME
        disp(ME.getReport);
    end
end

function newSelectedPaths=lGetSelectedNodePath(oldSimlog,...
    newSimlog,oldSelectedPaths)
    newSelectedPaths=cell(1,numel(oldSelectedPaths));
    import simscape.logging.internal.*

    for idx=1:numel(oldSelectedPaths)

        [isValid,nodeSourcePath]=lFindPathForSelectedNode(oldSimlog,...
        newSimlog,oldSelectedPaths{idx});

        oldNodePath=oldSelectedPaths{idx};





        isPathValid=isValid&&~isempty(nodeSourcePath);

        if~isPathValid



            newSelectedPaths{idx}=lMapSelectedNodeToNewSource(oldSimlog,...
            newSimlog,oldNodePath);
        else

            nodePath=lConcatNodePathToSourcePath(oldSimlog,...
            oldNodePath,nodeSourcePath);



            if hasIndexedPath(newSimlog,nodePath)
                newSelectedPaths{idx}=nodePath;
            else
                newSelectedPaths{idx}=nodeSourcePath;
            end
        end
    end





    newSelectedPaths=lFilterSelectedPaths(newSimlog,newSelectedPaths);
end

function nodePath=lMapSelectedNodeToNewSource(oldSimlog,...
    newSimlog,oldNodePath)

    pathIdx=0;
    isValid=false;
    nodePath='';


    while(pathIdx<numel(oldNodePath)&&~isValid)
        pathToFind=oldNodePath(1:end-pathIdx);
        [isValid,nodePath]=lFindPathForSelectedNode(...
        oldSimlog,newSimlog,pathToFind);
        pathIdx=pathIdx+1;
    end
end

function[isValid,nodePath]=lFindPathForSelectedNode(...
    oldSimlog,newSimlog,oldSelectedPath)
    import simscape.logging.internal.*

    isValid=false;
    nodePath='';

    selectedNode=indexedNode(oldSimlog,oldSelectedPath);
    if(isempty(selectedNode))
        return
    else
        if(selectedNode(1).hasSource())
            source=selectedNode(1).getSource();
            try
                [isValid,nodePath]=findPathImpl(newSimlog,source);
                if isValid
                    nodePath=strsplit(nodePath,'.');
                end
            catch ME %#ok<NASGU>
            end
        end
    end
end

function source=lGetNodeSource(oldSimlog,oldNodePath)
    import simscape.logging.internal.*

    node=indexedNode(oldSimlog,oldNodePath);
    source='';
    if node(1).hasSource()
        source=node(1).getSource();
    end
end

function path=lConcatNodePathToSourcePath(...
    oldSimlog,oldNodePath,newSourcePath)

    idx=0;
    curNodeSource=lGetNodeSource(oldSimlog,oldNodePath(1:end-idx));
    prevNodeSource=curNodeSource;



    while((strcmp(curNodeSource,prevNodeSource)||isempty(curNodeSource))&&...
        idx<numel(oldNodePath))
        curNodeSource=prevNodeSource;
        idx=idx+1;
        prevNodeSource=lGetNodeSource(oldSimlog,oldNodePath(1:(end-idx)));
    end






    pathIdx=numel(oldNodePath)-idx+2;
    assert((pathIdx>0),getMessageFromCatalog('InvalidIndex'));


    if pathIdx>numel(oldNodePath)
        path=newSourcePath;
    else

        path=[newSourcePath,oldNodePath(pathIdx:end)];
    end
end

function selectedNodePaths=lFilterSelectedPaths(newSimlog,selectedNodePaths)
    import simscape.logging.internal.*

    selectedNodePaths=selectedNodePaths(~cellfun('isempty',selectedNodePaths));
    if(numel(selectedNodePaths)>1)



        filterNodes=@(x)(numChildren(indexedNode(newSimlog,x))==0);
        nodePaths=selectedNodePaths(cellfun(filterNodes,...
        selectedNodePaths));




        if~isempty(nodePaths)
            selectedNodePaths=nodePaths;
        end
    end
end

function a=lGetTreePath(uitree,node,p)

    if isempty(p)||numel(p)==1&&isempty(p{1})
        a={uitree};
        return;
    end

    tree=uitree;
    t=tree.Children;
    n=node;
    for idx=1:numel(p)
        id=p{idx};
        if(isnumeric(id))
            pm_assert(~isscalar(n));
            linearIdx=simscape.logging.internal.subArray2Ind(size(n),id);
            pm_assert(~isempty(linearIdx));
            t=t.Children(linearIdx);
            t.expand();
            n=n(linearIdx);
        else
            s=simscape.logging.internal.sortChildIds(n);
            jdx=find(strcmp(s,id));
            t=t.Children(jdx);
            t.expand();
            n=n.node(id);
        end
    end
    a=t;
end

