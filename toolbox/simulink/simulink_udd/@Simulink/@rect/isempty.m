function ret=isempty(slr)








    if width(slr)<=0,
        ret=logical(1);
    elseif height(slr)<=0,
        ret=logical(1);
    else
        ret=logical(0);
    end


