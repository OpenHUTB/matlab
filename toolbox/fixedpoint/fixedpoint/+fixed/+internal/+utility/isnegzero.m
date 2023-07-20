function bool=isnegzero(val)












    narginchk(1,1);
    validateattributes(val,{'numeric','logical','embedded.fi'},{'real'});
    if fixed.internal.type.isAnyFloat(val)
        bool=val==0;
        bool(bool)=1./double(val(bool))<0;
    else
        bool=false(size(val));
    end
end
