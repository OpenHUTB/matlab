function entry=createCoderData(dict,type,name)

    txn=[];
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    try
        txn=hlp.beginTxn(dict);
        entry=coder.internal.CoderDataStaticAPI.create(dict,type);
        hlp.setProp(entry,'Name',name);
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        throwAsCaller(me);
    end

end