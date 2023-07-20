function ret=create(sourceDD,type,varargin)















    import coder.internal.CoderDataStaticAPI.*;

    persistent nMap;
    if isempty(nMap)
        nMap=containers.Map;
    end
    txn=[];
    ret=[];
    try
        hlp=getHelper();
        slRoot=slroot;
        if isa(sourceDD,'coderdictionary.softwareplatform.FunctionPlatform')
            dd=sourceDD;
        elseif slRoot.isValidSlObject(sourceDD)
            dd=hlp.openDD(sourceDD,'C',true);
        else
            dd=hlp.openDD(sourceDD);
        end
        txn=hlp.beginTxn(dd);
        key=[Utils.getCurrentDictID(dd),type];
        if~nMap.isKey(key)
            nMap(type)=1;
        end
        n=nMap(type);
        data=hlp.getCoderData(dd,type);
        if isempty(data)
            dataNames={};
        else
            dataNames={data.Name};
        end
        switch type
        case 'FunctionClass'
            seed='FunctionTemplate';
        case 'IRTFunction'
            seed='InitTerm';
        otherwise
            seed=type;
        end
        [newName,n]=Utils.generateNextName(dataNames,[seed,'%d'],n);
        nMap(type)=n;
        ret=hlp.createEntry(dd,type,newName);
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        errordlg(me.message);
    end
end


