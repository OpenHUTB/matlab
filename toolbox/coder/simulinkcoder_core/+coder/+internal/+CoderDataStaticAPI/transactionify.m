function transactionify(sourceDD,fcnHandle,guiEntry)

















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    if nargin==2
        guiEntry=true;
    end
    txn=[];
    try

        slRoot=slroot;
        if slRoot.isValidSlObject(sourceDD)
            dd=hlp.openDD(sourceDD,'C',true);
        else
            dd=hlp.openDD(sourceDD);
        end
        txn=hlp.beginTxn(dd);
        feval(fcnHandle);
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        if guiEntry
            errordlg(me.message);
        else
            throwAsCaller(me);
        end
    end
end