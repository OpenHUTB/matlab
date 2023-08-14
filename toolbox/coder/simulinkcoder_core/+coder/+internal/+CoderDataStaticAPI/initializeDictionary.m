function initializeDictionary(sourceDD,varargin)












    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    createNewExampleCoderData=false;
    if nargin==2
        createNewExampleCoderData=varargin{1};
    end

    txn=[];
    try
        [dd,loadSLPkg]=Utils.openCDefinitions(sourceDD);
        txn=hlp.beginTxn(dd);
        Utils.initializeDict(dd,loadSLPkg,true);
        if createNewExampleCoderData
            createExampleStorageClasses(sourceDD);
            createFactoryFunctionClasses(sourceDD);
        end
        hlp.commitTxn(txn);
    catch me
        if~isempty(txn)
            hlp.rollbackTxn(txn);
        end
        if nargin==1
            errordlg(me.message);
        else
            rethrow(me);
        end
    end
end
