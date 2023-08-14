

function y=isenabled(v)
    if islogical(v)
        y=v;
    else
        y=~strcmpi(v,'off');
    end
