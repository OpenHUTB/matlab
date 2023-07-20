function out=invertValue(val)



    if strcmp(val,'on')
        out='off';
    elseif strcmp(val,'off')
        out='on';
    else
        out=~val;
    end