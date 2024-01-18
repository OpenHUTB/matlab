function[omatch,idx,fmatch]=setmap(from,onto)

    [~,idxf,~]=intersect(from,onto);
    fmatch=false(length(from),1);
    fmatch(idxf)=true;
    [omatch,idx]=rmiut.findidx(from(fmatch),onto);
end
