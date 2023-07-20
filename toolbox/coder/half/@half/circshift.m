function b=circshift(a,p,dim)
































    narginchk(2,3);

    if nargin<3
        b=matlab.internal.builtinhelper.circshift(a,p);
    else
        b=matlab.internal.builtinhelper.circshift(a,p,dim);
    end


end