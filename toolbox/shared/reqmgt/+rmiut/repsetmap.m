function[omatch,idx,fmatch]=repsetmap(from,onto)

    [uFrom,~,fIdx]=unique(from);
    [omatch,umdx,ufmatch]=rmiut.setmap(uFrom,onto);

    idxUF=zeros(length(uFrom),1);
    idxUF(ufmatch)=umdx;
    idx=idxUF(fIdx);
    idx(idx==0)=[];

    fmatch=ufmatch(fIdx);
end
