function[P,t,RefinedNodes]=meshrefine(P,t,indexedges,edges)

















    add=length(indexedges);
    RefinedNodes=[1:add,add+unique([edges(indexedges,1)',edges(indexedges,2)'])];


    center=1/2*(P(edges(:,1),:)+P(edges(:,2),:));
    Nodes=center(indexedges,:);
    P=[Nodes;P];
    t=t+size(Nodes,1);
    edges=edges+size(Nodes,1);

    se=em.internal.meshprinting.meshconnte(t,edges);


    remove=[];
    add=[];
    for m=1:size(t,1)
        temp1=find(indexedges==se(m,1));
        temp2=find(indexedges==se(m,2));
        temp3=find(indexedges==se(m,3));
        node1=intersect(edges(se(m,1),:),edges(se(m,3),:));
        node2=intersect(edges(se(m,1),:),edges(se(m,2),:));
        node3=intersect(edges(se(m,2),:),edges(se(m,3),:));
        if~isempty(temp1)|~isempty(temp2)|~isempty(temp3)
            remove=[remove,m];
            if temp1&temp2&temp3
                add=[[temp1,temp2,temp3];...
                [temp1,temp2,node2];...
                [temp1,temp3,node1];...
                [temp2,temp3,node3];...
                add];
            end
            if temp1&temp2&(isempty(temp3))
                add=[[temp1,temp2,node2];...
                [temp1,temp2,node1];...
                [temp2,node1,node3];...
                add];
            end
            if temp1&temp3&(isempty(temp2))
                add=[[temp1,temp3,node1];...
                [temp1,temp3,node3];...
                [temp1,node2,node3];...
                add];
            end
            if temp2&temp3&(isempty(temp1))
                add=[[temp2,temp3,node3];...
                [temp2,temp3,node1];...
                [temp2,node1,node2];...
                add];
            end
            if temp1&(isempty(temp2))&(isempty(temp3))
                add=[[temp1,node1,node3];...
                [temp1,node2,node3];...
                add];
            end
            if temp2&(isempty(temp1))&(isempty(temp3))
                add=[[temp2,node1,node2];...
                [temp2,node1,node3];...
                add];
            end
            if temp3&(isempty(temp1))&(isempty(temp2))
                add=[[temp3,node1,node2];...
                [temp3,node2,node3];...
                add];
            end
        end
    end

    t(remove,:)=[];
    t=[t;add];
    t=sort(t,2);
