function out=findEdgeGroups(~,t)

    n=size(t,1);
    m=size(t,2)-3;
    edgesdup=[t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];
    e1=sort(edgesdup,2);
    tLabel=repmat((1:n)',3,1);
    eLabel=kron([1;2;3],ones(n,1));
    if m<=0
        tData=[];
    else
        tData=repmat(t(:,4:end),3,m);
    end
    e1x=[e1,tLabel,eLabel,tData];
    B=sortrows(e1x);
    [~,~,ic]=unique(B(:,1:2),'rows','stable');
    h=accumarray(ic,1);
    Bx=[h(ic),B];
    Bxs=sortrows(Bx);
    ncell=max(h);
    out=cell(ncell,1);
    iter=1:ncell;
    if~any(h==1)
        iter=2:ncell;
    end
    istart=1;
    for i=iter
        iend=find(Bxs(:,1)==i,1,'last');
        out{i}=Bxs(istart:iend,2:end);

        istart=iend+1;
    end
end

