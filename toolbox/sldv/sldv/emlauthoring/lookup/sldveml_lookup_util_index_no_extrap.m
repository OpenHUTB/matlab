%#codegen
function[idxLeft,idxRight]=sldveml_lookup_util_index_no_extrap(u,mode,n,x)















    coder.allowpcode('plain');

    eml_prefer_const(n,mode,x);

    idxLow=int32(1);
    idxHi=int32(n);
    found=false;

    idxLeft=idxLow;
    idxRight=idxHi;

    eml_assert(mode~=0,getString(message('Sldv:sldv:EmlAuthoring:NoInterpolationExtrapolation')));

    if mode==4
        if u<=x(1)
            idxRight=idxLow;
        elseif u>=x(n)
            idxLeft=idxHi;
        else
            for i=2:n
                if~found&&u<=x(i)
                    idxRight=int32(i);
                    idxLeft=int32(i-1);
                    found=true;
                end
            end
        end
    else
        if u<=x(1)
            idxRight=idxLow;
        elseif u>=x(n)
            idxLeft=idxHi;
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
end

