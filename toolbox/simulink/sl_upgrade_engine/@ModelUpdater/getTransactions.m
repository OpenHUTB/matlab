function blks=getTransactions(h,name,done,reason)





















    nTrans=length(h.Transactions);
    blks=cell(nTrans,1);


    nBlks=0;
    for i=1:nTrans
        trans=h.Transactions(i);
        if~isempty(name)&&~strcmp(trans.name,name)
            continue;
        elseif~isempty(done)&&trans.done~=done
            continue;
        elseif~isempty(reason)&&~strcmp(trans.reason,reason)
            continue;
        end
        nBlks=nBlks+1;
        blks{nBlks}=trans.name;
    end


    blks=blks(1:nBlks);

end
