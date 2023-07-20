function deleteTreeNode(obj,node,permanently)




    if~isempty(node)
        if~node.parentTree.isActive
            pNodes={};
            if permanently
                pNodes={node};
            end
            aNodes={};
            if~isempty(node.data.dstNode)
                aNodes={node.data.dstNode};
            end

            if~isempty(node.children)
                childNodes=node.children;
                for idx=1:numel(childNodes)
                    cn=childNodes{idx};
                    if permanently
                        pNodes=[{cn},pNodes];%#ok<AGROW>
                    end
                    if~isempty(cn.data.dstNode)
                        aNodes=[aNodes,{cn.data.dstNode}];%#ok<AGROW>
                    end
                end
            end
            obj.root.activeTree.removeTreeNode(aNodes);
            obj.root.passiveTree.removeTreeNode(pNodes);
        else
            aNodes={node};
            obj.root.activeTree.removeTreeNode(aNodes);
        end
        obj.root.activeTree.needAggregate=true;
    end
end