function id=getNextAppId()


    mlock;
    persistent gId;
    if isempty(gId)
        gId='a';
    end
    if gId(end)=='z'
        gId(end+1)='a';
    else
        gId(end)=char(gId(end)+1);
    end
    id=gId;
end

