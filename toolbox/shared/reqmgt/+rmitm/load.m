function success=load(testSuite,force)
    testSuite=convertStringsToChars(testSuite);

    if nargin==1
        force=false;
    end

    tPath=rmitm.getFilePath(testSuite);

    if rmitm.hasData(tPath)
        if~force&&rmitm.hasChanges(tPath)
            error(message('Slvnv:rmitm:TestCaseHasChanges',tPath));
        else
            rmitm.discard(tPath);
        end
    end

    success=slreq.utils.loadLinkSet(tPath);

end

