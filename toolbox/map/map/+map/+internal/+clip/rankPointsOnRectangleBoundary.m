function rank=rankPointsOnRectangleBoundary(x,y,xlimits,ylimits)









    rank=zeros(size(x));


    n=0;
    ix=find(x==xlimits(1));
    if~isempty(ix)
        [~,k]=sort(y(ix),'ascend');
        p=length(ix);
        rank(ix(k))=n+(1:p);
        n=n+p;
    end


    ix=find(y==ylimits(2));
    if~isempty(ix)
        [~,k]=sort(x(ix),'ascend');
        p=length(ix);
        rank(ix(k))=n+(1:p);
        n=n+p;
    end


    ix=find(x==xlimits(2));
    if~isempty(ix)
        [~,k]=sort(y(ix),'descend');
        p=length(ix);
        rank(ix(k))=n+(1:p);
        n=n+p;
    end


    ix=find(y==ylimits(1)&x>xlimits(1));
    if~isempty(ix)
        [~,k]=sort(x(ix),'descend');
        p=length(ix);
        rank(ix(k))=n+(1:p);
    end




    [~,k]=sort(rank);
    xs=x(k);
    ys=y(k);
    for m=1:(length(k)-1)
        if xs(m)==xs(m+1)&&ys(m)==ys(m+1)
            rank(k(m+1))=rank(k(m));
        end
    end
end
