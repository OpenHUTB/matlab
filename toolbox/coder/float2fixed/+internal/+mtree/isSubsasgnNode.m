function res=isSubsasgnNode(node)




    if strcmp(node.kind,'SUBSCR')||strcmp(node.kind,'CELL')


        prevNode=node;
        currNode=node.Parent;
        while~isempty(currNode)&&~strcmp(currNode.kind,'EQUALS')
            prevNode=currNode;
            currNode=currNode.Parent;
        end


        if isempty(currNode)
            res=false;



        else
            res=currNode.Left==prevNode;
        end
    else
        res=false;
    end
end
