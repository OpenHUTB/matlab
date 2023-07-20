function selectNode(h,name)





    searchPath=Simulink.SimulationData.BlockPath.manglePath(name);
    node=locFindChild(searchPath,h.getRoot);


    locSelectChild(h,node);

end


function node=locFindChild(searchPath,parentNode)


    node=[];
    searchStrLen=length(searchPath);


    if isempty(parentNode)||~parentNode.isLoaded
        return;
    end


    children=parentNode.getHierarchicalChildren;
    for idx=1:length(children)

        childPath=Simulink.SimulationData.BlockPath.manglePath(...
        children(idx).cachedFullName);


        if strcmp(searchPath,childPath)
            node=children(idx);
            return;
        end



        parentPath=[childPath,'/'];
        pathLen=length(parentPath);
        if pathLen<searchStrLen&&strcmp(searchPath(1:pathLen),parentPath)
            node=locFindChild(searchPath,children(idx));
            if~isempty(node)
                return;
            end
        end

    end

end


function locSelectChild(me,node)



    if isempty(node)
        node=h.getRoot;
    end


    curNode=node;
    nodeList=node;
    while~isempty(curNode)
        curNode=curNode.hParent;
        if~isempty(curNode)
            nodeList=[curNode,nodeList];%#ok<AGROW>
        end
    end


    for idx=1:length(nodeList)
        me.imme.expandTreeNode(nodeList(idx));
    end


    me.imme.selectTreeViewNode(nodeList(end));

end
