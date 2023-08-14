function is=isTwoDimensional(value)
    is=false;
    s=size(value);
    if(length(s)==2)&&~isscalar(value)
        is=true;
    end
end

