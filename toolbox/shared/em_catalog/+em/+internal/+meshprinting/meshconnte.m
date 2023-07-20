function se=meshconnte(t,edges)











    N=size(t,1);
    se=zeros(N,3);
    t=sort(t,2);
    edges=sort(edges,2);
    for m=1:N
        temp1=edges(:,1)==t(m,1)|edges(:,1)==t(m,2);
        temp2=edges(:,2)==t(m,2)|edges(:,2)==t(m,3);
        se(m,:)=find(temp1&temp2>0);
    end
    se=sort(se,2);
end