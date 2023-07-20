function retval=getFlattenedValue(constVal)








    if isscalar(constVal)

        retval={constVal};
    else
        sz=size(constVal);
        nrows=sz(1);
        ncols=sz(2);
        flatsz=nrows*ncols;
        if ismatrix(constVal)
            reshapeVal=reshape(constVal,flatsz,1);
            retval{1}=reshapeVal;
        else



            assert(ndims(constVal)==3);
            ntime=sz(3);
            reshapeVal=reshape(constVal,flatsz,1,ntime);
            retval{1}=reshapeVal;
        end
    end
end
