function eng=getSetEngine(obj)

    mlock;
    persistent SDIEngine;
    if nargin>0
        SDIEngine=obj;
    end
    eng=SDIEngine;
end
