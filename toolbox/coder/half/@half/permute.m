function r=permute(A,dimorder)

















    narginchk(2,2);

    if isa(dimorder,'half')
        dimorder=uint16(dimorder);
    end

    if isa(A,'half')
        tmp=permute(A.storedInteger,dimorder);
        r=half.typecast(tmp);
    else
        r=permute(A,dimorder);
    end



end