function retCellArray=clone(sourceDD,type,names)


















    import coder.internal.CoderDataStaticAPI.*;
    txn=[];
    try
        hlp=getHelper();
        dd=hlp.openDD(sourceDD);
        txn=hlp.beginTxn(dd);
        retCellArray={};
        data=hlp.getCoderData(dd,type);
        if~isempty(data)&&~isempty(names)
            for i=1:length(names)
                newItem=hlp.cloneEntry(dd,type,names{i});
                if~isempty(newItem)
                    retCellArray{end+1}=newItem;%#ok
                end
            end
        end
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        errordlg(me.message);
    end
end
