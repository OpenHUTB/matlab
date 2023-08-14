function[u,b]=find_unique(v)












    v=v(:);
    [sortV,I]=sort(v);
    repeatedInd=[logical(0);sortV(1:(end-1))==sortV(2:end)];
    u=sortV;
    u(repeatedInd)=[];

    if nargout>1
        b(I)=(1:length(v))'-cumsum(repeatedInd);
    end
