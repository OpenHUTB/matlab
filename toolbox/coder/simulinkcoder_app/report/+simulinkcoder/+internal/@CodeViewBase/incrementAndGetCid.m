function out=incrementAndGetCid()

    mlock();

    persistent cid;

    if isempty(cid)
        cid=0;
    end

    cid=cid+1;

    out=cid;


