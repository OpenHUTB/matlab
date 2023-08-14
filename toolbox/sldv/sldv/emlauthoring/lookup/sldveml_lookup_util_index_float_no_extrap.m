%#codegen
function[idxLeft,idxRight]=sldveml_lookup_util_index_float_no_extrap(u,mode,n,x)















    coder.allowpcode('plain');

    eml_prefer_const(n,mode,x);

    found=false;

    eml_assert(mode~=0,getString(message('Sldv:sldv:EmlAuthoring:NoInterpolationExtrapolation')));

    idxLeft=int32(0);
    idxRight=int32(n+1);

    if u<x(1)
        idxLeft=int32(0);
        idxRight=int32(1);
    elseif u>=x(n)
        idxLeft=int32(n);
        idxRight=int32(n+1);
    else
        for i=2:n
            if~found&&u<x(i)
                idxRight=int32(i);
                idxLeft=int32(i-1);
                found=true;
            end
        end
    end
end

