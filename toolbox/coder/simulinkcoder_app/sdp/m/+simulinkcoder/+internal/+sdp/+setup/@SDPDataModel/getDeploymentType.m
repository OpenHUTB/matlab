function out=getDeploymentType(obj,id)



    out='';
    role=obj.getRole(id);
    if role==1
        node=obj.getNode(id);
        out=node.DeploymentType;
    elseif role==2
        out=2;
    end
