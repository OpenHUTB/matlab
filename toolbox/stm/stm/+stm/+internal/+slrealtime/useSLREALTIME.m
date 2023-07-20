function res=useSLREALTIME(val)
    persistent useslreatime;
    if isempty(useslreatime)
        useslreatime=true;
    end
    if nargin>0
        useslreatime=val;
    end
    res=useslreatime;
end