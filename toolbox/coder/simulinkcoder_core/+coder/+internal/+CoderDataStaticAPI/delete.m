function delete(sourceDD,type,names)


















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    txn=[];
    try
        if isa(sourceDD,'coderdictionary.softwareplatform.FunctionPlatform')
            dd=sourceDD;
        else
            dd=hlp.openDD(sourceDD);
        end
        txn=hlp.beginTxn(dd);
        data=hlp.getCoderData(dd,type);
        if~isempty(data)&&~isempty(names)
            for i=1:length(names)
                name=names{i};
                hlp.deleteEntry(dd,type,name)
            end
        end
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        rethrow(me);
    end
end
