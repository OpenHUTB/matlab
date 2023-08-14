function ret=isProcRegistered(reg,procName,pitType)





    if(nargin>2)
        procIdx=getProcRegIdx(reg,procName,pitType);
    else
        procIdx=getProcRegIdx(reg,procName);
    end
    ret=~isempty(procIdx);

end
