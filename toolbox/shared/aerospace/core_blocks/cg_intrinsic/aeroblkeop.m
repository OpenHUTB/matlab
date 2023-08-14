function out=aeroblkeop(MJD,mjdData,eopData,factor)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Blockset');
    npts=length(eopData)/2;
    out=zeros(2,1);

    if MJD>=mjdData(npts)+1


        out(1)=eopData(npts);
        out(2)=eopData(2*npts);
    elseif MJD<mjdData(1)

        out(1)=eopData(1);
        out(2)=eopData(npts+1);
    else

        if MJD<mjdData(npts)+1&&MJD>=mjdData(npts)

            out(1)=eopData(npts);
            out(2)=eopData(2*npts);
        else
            idx=find((MJD<mjdData));
            out(1)=eopData(idx(1)-1);
            out(2)=eopData(npts+idx(1)-1);
        end

    end
    out=out*factor;
