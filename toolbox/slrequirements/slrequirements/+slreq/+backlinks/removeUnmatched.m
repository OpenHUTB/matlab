function[numRemoved,numChecked]=removeUnmatched(type,externalDocument,source,linksData,doSave)




    numRemoved=0;
    numChecked=0;

    if nargin<5
        doSave=false;
    end

    definedType=rmi.linktype_mgr('resolveByRegName',type);
    if isempty(definedType)
        return;
    end
    if isempty(definedType.BacklinksCleanupFcn)
        return;
    end

    [numRemoved,numChecked]=definedType.BacklinksCleanupFcn(externalDocument,source,linksData,doSave);

end

