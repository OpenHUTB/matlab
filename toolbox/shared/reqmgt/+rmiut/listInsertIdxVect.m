function[origIdx,insIdx]=listInsertIdxVect(pts,cnts,lng)
    pts(cnts==0)=[];
    cnts(cnts==0)=[];

    mxPt=max(pts);
    if lng<mxPt
        origIdx=1:mxPt;
        inc=zeros(1,mxPt);
    else
        origIdx=1:lng;
        inc=zeros(1,lng);
    end


    for i=1:length(pts)
        inc(pts(i))=inc(pts(i))+cnts(i);
    end
    origIdx=origIdx+cumsum(inc);

    listBoundary=[1,cumsum(cnts(1:(end-1)))+1];
    insLng=sum(cnts);
    insBase(insLng)=0;
    insBase(listBoundary)=1;
    insIdx=pts(cumsum(insBase));
    insIdx=insIdx+(0:(insLng-1));

    origIdx=origIdx(1:lng);
end
