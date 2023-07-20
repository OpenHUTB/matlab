

function status=isParentOf(this,childID,parentID)
    status=false;

    node=this.getComponent(childID);

    status=t_isParent(this,parentID,node);
end


function found=t_isParent(this,parentID,node)
    found=false;
    p=this.getParentNodes(node.ID);

    for n=1:length(p)
        if strcmp(p(n).ID,parentID)
            found=true;
            break;
        else
            found=t_isParent(this,parentID,p(n));
            if found
                break;
            end
        end
    end
end