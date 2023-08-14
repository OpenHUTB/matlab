%#codegen
function idx=sldveml_lookup_util_index_extrap(u,n,x)









    coder.allowpcode('plain');

    eml_prefer_const(n,x);

    idxLow=int32(1);
    idxHi=int32(n-1);
    found=false;

    idx=idxLow;
    if u>=x(n)
        idx=idxHi;
    elseif u<=x(1)
        idx=idxLow;
    else
        if u<0
            for i=2:n
                if~found&&u<x(i)
                    idx=int32(i-1);
                    found=true;
                end
            end
        else
            for i=2:n
                if~found&&u<=x(i)
                    idx=int32(i-1);
                    found=true;
                end
            end
        end
    end
end

