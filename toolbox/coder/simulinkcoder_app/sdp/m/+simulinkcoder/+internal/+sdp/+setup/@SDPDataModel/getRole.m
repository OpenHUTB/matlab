function[role,node]=getRole(obj,id)



    list=strsplit(id,'/');
    n=length(list);

    index=0;
    node=[];
    for i=1:n
        name=strjoin(list(1:i),'/');
        node=obj.getNode(name);
        if node.CodeGen
            index=i;
            break;
        end
    end

    if index==0
        role=0;
    elseif index<n
        role=2;
    elseif index==n
        role=1;
    end


