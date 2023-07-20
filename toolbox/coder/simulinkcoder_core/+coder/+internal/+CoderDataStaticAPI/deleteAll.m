function deleteAll(sourceDD,unregister)











    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    txn=[];
    try
        [dd,~]=hlp.openDD(sourceDD);
        if~hlp.isOpen(dd)
            return;
        end
        txn=hlp.beginTxn(dd);
        hlp.deleteAll(dd);
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end
    if unregister
        coderdictionary.data.api.remove(dd.owner);
    end
end
