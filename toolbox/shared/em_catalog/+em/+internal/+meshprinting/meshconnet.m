function AttachedTriangles=meshconnet(t,edges,flag)













    EDGES=size(edges,1);temp=cell(EDGES,1);
    for m=1:EDGES
        ind1=(t(:,1)==edges(m,1));
        ind2=(t(:,2)==edges(m,1));
        ind3=(t(:,3)==edges(m,1));
        IND1=ind1|ind2|ind3;
        ind1=(t(:,1)==edges(m,2));
        ind2=(t(:,2)==edges(m,2));
        ind3=(t(:,3)==edges(m,2));
        IND2=ind1|ind2|ind3;
        IND=find(IND1&IND2);
        temp{m}=IND;
    end
    if strcmp(flag,'manifold')
        AttachedTriangles=cell2mat(temp')';
    else
        AttachedTriangles=temp;
    end
end