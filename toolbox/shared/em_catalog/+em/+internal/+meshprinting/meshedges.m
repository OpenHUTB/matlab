function[NonManifoldAttached,edges,edgesb,edgesnm]=meshedges(P,t)













    count=0;
    NonManifoldAttached=[];
    edges=[t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];
    edges=unique(sort(edges,2),'rows');
    edgesb=[];
    edgesnm=[];
    EDGES=size(edges,1);
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
        if size(IND,1)==1
            edgesb=[edgesb;edges(m,:)];
            NonManifoldAttached=[NonManifoldAttached,IND];
        end
        if size(IND,1)>2
            count=count+1;
            warning('Non-manifold edges found');
            edgesnm=[edgesnm;edges(m,:)];
        end
    end
    NonManifoldAttached=NonManifoldAttached';
end
