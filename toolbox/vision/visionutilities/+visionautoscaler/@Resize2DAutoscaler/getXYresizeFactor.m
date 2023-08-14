
function[horizFactor,vertFactor]=getXYresizeFactor(h,resize)%#ok
    if(length(resize)==2)
        horizFactor=resize(1);
        vertFactor=resize(2);
    else
        vertFactor=resize(1);
        horizFactor=vertFactor;
    end



