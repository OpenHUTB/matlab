function appendTransaction(h,name,reason,funcSet)












    h.Transactions(end+1).name=h.cleanLocationName(name);
    h.Transactions(end).reason=reason;

    if(doUpdate(h))
        h.Transactions(end).done=true;
    else
        h.Transactions(end).done=false;
    end

    h.Transactions(end).functionSet=funcSet;
end
