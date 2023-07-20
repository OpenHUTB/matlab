function[eCellInt,P]=inter4_earr_parr(PCellInt)






    P=[];
    E=[];
    esize=zeros(1,size(PCellInt,2));
    for m=1:size(PCellInt,2)

        e=[];
        temp=PCellInt{m};
        esize(m)=size(temp,1);
        e(:,1)=[1:esize(m)]';
        e(:,2)=[2:esize(m),1]';
        e(:,1)=e(:,1)+size(P,1);
        e(:,2)=e(:,2)+size(P,1);
        P=[P;PCellInt{m}];
        E=[E;e];
    end


    [P,ia,IC]=unique(P,'rows','stable');
    NodesTotal=size(IC,1);
    for m=1:NodesTotal
        index=find(E(:,1)==m);
        E(index,1)=IC(m);
        index=find(E(:,2)==m);
        E(index,2)=IC(m);
    end


    for m=1:size(PCellInt,2)
        temp=sum(esize(1:m-1))+1:sum(esize(1:m));
        eCellInt{m}=E(temp,:);
    end

end

