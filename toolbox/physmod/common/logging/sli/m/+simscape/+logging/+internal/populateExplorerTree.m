function populateExplorerTree(parent,node)





    if isempty(parent)
        parent=uitreenode(uit,'Text',node.getName,...
        'Tag',node.id);
    end

    lPopulateTree(parent,node);

end

function lPopulateTree(parentTreeNode,loggingNode)


    if(~isscalar(loggingNode))
        error('Call lPopulateTree for scalar nodes only');
    end


    children=simscape.logging.internal.sortChildIds(loggingNode);


    for i=1:numel(children)
        childNode=child(loggingNode,children{i});
        if isscalar(childNode)
            treeNode=lCreateUITreeNode(parentTreeNode,childNode);
            if childNode.numChildren>0
                lPopulateTree(treeNode,childNode);
            end
        else
            treeNode=lCreateArrayUITreeNode(parentTreeNode,childNode);
            lCreateTreeNodeArray(treeNode,childNode);
        end
    end
end

function treeNode=lCreateUITreeNode(parentTreeNode,childNode)
    iconPath=lGetTreeNodeIcon(childNode);
    treeNode=uitreenode(parentTreeNode,'Text',childNode.getName,...
    'Icon',iconPath,'Tag',childNode.id);

end

function treeNode=lCreateArrayUITreeNode(parentTreeNode,childNode)
    iconPath=lGetTreeNodeIcon(childNode(1));
    treeNode=uitreenode(parentTreeNode,'Text',childNode(1).id,'Icon',iconPath);
end

function lCreateTreeNodeArray(parentTreeNode,loggingNodeArray)
    for iNode=1:numel(loggingNodeArray)
        iconPath=lGetTreeNodeIcon(loggingNodeArray(iNode));
        treeNode=uitreenode(parentTreeNode,'Text',...
        loggingNodeArray(iNode).getName,...
        'Icon',iconPath,'Tag',loggingNodeArray(iNode).id);
        if loggingNodeArray(iNode).numChildren>0
            lPopulateTree(treeNode,loggingNodeArray(iNode));
        end
    end
end

function IconPath=lGetTreeNodeIcon(nodes)
    if numel(nodes)>1
        node=nodes(1);
    else
        node=nodes;
    end

    if node.numChildren==0
        IconPath=fullfile(matlabroot,'toolbox','physmod','common',...
        'logging','sli','m','resources','icons','signal.png');
    else
        IconPath=fullfile(matlabroot,'toolbox','physmod','common',...
        'logging','sli','m','resources','icons',...
        'nonterminal_node.png');
    end
end