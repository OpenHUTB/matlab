function[mjdT,T,T2,T3]=getJulianCenturies(utc)


























    mjdT=mjuliandate(utc);
    T=(mjdT-51544.5)./36525;
    if nargout>2
        T2=T.*T;
    end
    if nargout>3
        T3=T2.*T;
    end
end
