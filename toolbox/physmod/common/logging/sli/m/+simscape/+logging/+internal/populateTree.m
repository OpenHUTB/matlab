function parent=populateTree(parent,node)




    if isempty(parent)
        parent=lCreateTreeNode(node,'');
    end

    lPopulateTree(parent,node);

end

function lPopulateTree(parentTreeNode,loggingNode)


    if(~isscalar(loggingNode))
        error('Call lPopulateTree for scalar nodes only');
    end


    children=simscape.logging.internal.sortChildIds(loggingNode);
    for iChild=1:numel(children)
        childNode=child(loggingNode,children{iChild});
        if isscalar(childNode)
            treeNode=lCreateTreeNode(childNode,childNode.id);
            if childNode.numChildren>0
                lPopulateTree(treeNode,childNode);
            end
        else
            treeNode=lCreateTreeNodeArray(childNode);
        end
        parentTreeNode.add(treeNode);
    end
end

function parentNode=lCreateTreeNodeArray(loggingNodeArray)
    id=loggingNodeArray(1).id;



    warn=warning('query','MATLAB:uitreenode:DeprecatedFunction');
    curState=warn.state;
    warning('off',warn.identifier);
    finishup=onCleanup(@()warning(curState,warn.identifier));
    parentNode=uitreenode('v0',id,id,lGetTreeNodeIcon(loggingNodeArray(1)),false);

    s=size(loggingNodeArray);
    showSubs=lShowSubs(s);
    for iNode=1:numel(loggingNodeArray)
        id=iNode;
        if showSubs
            id=lInd2Sub(iNode,s);
        end
        treeNode=lCreateTreeNode(loggingNodeArray(iNode),id);
        if loggingNodeArray(iNode).numChildren>0
            lPopulateTree(treeNode,loggingNodeArray(iNode));
        end
        parentNode.add(treeNode);
    end

    function out=lInd2Sub(idx,s)


        out=cell(size(s));
        [out{:}]=ind2sub(s,idx);
        out=cell2mat(out);
    end

    function res=lShowSubs(s)



        res=numel(s)>2||nnz(s>1)>1;
    end
end

function treeNode=lCreateTreeNode(node,id)


    if(~isscalar(node))
        error('Call lPopulateTree for scalar nodes only');
    end

    treeLabel=lGetTreeNodeLabel(node);
    treeIcon=lGetTreeNodeIcon(node);
    isTerminal=(node.numChildren==0);



    warn=warning('query','MATLAB:uitreenode:DeprecatedFunction');
    curState=warn.state;
    warning('off',warn.identifier);
    finishup=onCleanup(@()warning(curState,warn.identifier));
    treeNode=uitreenode('v0',id,treeLabel,treeIcon,isTerminal);
end

function treeLabel=lGetTreeNodeLabel(nodes)

    if numel(nodes)>1
        node=nodes(1);
        defaultTreeLabelFcn=@(n)(n.id);
    else
        node=nodes;
        defaultTreeLabelFcn=@(n)(n.getName);
    end
    fcn=getConfigOption(node,'TreeNodeLabelFcn',defaultTreeLabelFcn);
    treeLabel=fcn(node);
end

function treeIcon=lGetTreeNodeIcon(nodes)

    if numel(nodes)>1
        node=nodes(1);
    else
        node=nodes;
    end

    if node.numChildren==0
        defaultIcon=getLeafIcon();
    else
        defaultIcon=getInteriorIcon();
    end
    treeIcon=getConfigOption(node,'TreeNodeIcon',defaultIcon);
end


