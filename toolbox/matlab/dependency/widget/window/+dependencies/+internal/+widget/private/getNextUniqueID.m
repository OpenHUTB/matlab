function id=getNextUniqueID()




    mlock;

    persistent staticId;
    if isempty(staticId)
        staticId=1;
    else
        staticId=staticId+1;
    end
    id=staticId;
end
