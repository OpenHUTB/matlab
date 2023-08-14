function refresh(hFigure,node,varName,selectedPath)
    try






        if~iscell(selectedPath)
            selectedPath={strsplit(selectedPath,'.')};
        end

        if isempty(hFigure)||~(hFigure.isvalid)
            return;
        end

        ud=get(hFigure,'UserData');




        if~strcmp(ud.tree.getRoot.getName,node.id)
            selectedPath={};
        end








        if~iscell(selectedPath)
            selectedPath={selectedPath};
        end

        if~isempty(selectedPath)
            selectedPath=selectedPath(~cellfun('isempty',selectedPath));
        end

        oldSimlog=ud.node;

        ud.tree.getRoot.removeAllChildren();
        simscape.logging.internal.populateTree(ud.tree.getRoot,node);
        ud.tree.getRoot.setName(node.id);
        ud.tree.reloadNode(ud.tree.getRoot);
        ud.node=node;
        ud.inputName=varName;


        if~isempty(selectedPath)

            selectedNodePaths=lGetSelectedNodePath(oldSimlog,node,selectedPath);



            if isempty(selectedNodePaths)
                ud.tree.setSelectedNode(ud.tree.getRoot);
            else
                selectedTreePath=cell(1,numel(selectedNodePaths));


                for idx=1:numel(selectedNodePaths)
                    treePath=lGetTreePath(ud.tree.getRoot,node,...
                    selectedNodePaths{idx});
                    selectedTreePath{idx}=treePath{end};
                end


                if(numel(selectedTreePath)>1)
                    ud.tree.setSelectedNodes(cell2mat(selectedTreePath));
                else
                    ud.tree.setSelectedNode(selectedTreePath{1});
                end

            end
        else
            ud.tree.setSelectedNode(ud.tree.getRoot);
        end


        ud.rootStatistics=getNodeStatistics(node);

        ud.lastSelection={};

        set(hFigure,'UserData',ud);
        set(hFigure,'Name',getMessageFromCatalog('ExplorerTitle',node.id));

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

    a=cell(1,numel(p));
    tree=uitree;
    n=node;
    for idx=1:numel(p)
        id=p{idx};
        if isnumeric(id)
            pm_assert(~isscalar(n));
            linearIdx=simscape.logging.internal.subArray2Ind(size(n),id);
            pm_assert(~isempty(linearIdx));
            z=tree.getChildAt(linearIdx-1);
            n=n(linearIdx);
        else
            s=simscape.logging.internal.sortChildIds(n);
            jdx=find(strcmp(s,id));
            z=tree.getChildAt(jdx-1);
            n=n.node(id);
        end
        a(idx)=z;
        tree=z;
    end
end
