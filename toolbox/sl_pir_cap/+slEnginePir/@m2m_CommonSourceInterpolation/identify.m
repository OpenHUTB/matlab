function errMsg=identify(m2mObj)





    errMsg=[];

    if m2mObj.fIsPirAnalyzed
        return;
    end

    m2mObj.fIsPirAnalyzed=1;

    mdls=[{m2mObj.fMdl},m2mObj.fRefMdls];
    m2mObj.fExcludedBlks=containers.Map('KeyType','char','ValueType','any');
    m2mObj.fInvalidCandidates=containers.Map('KeyType','char','ValueType','any');

    m2mObj.fXformObj.clearObject();
    for mIdx=1:length(mdls)
        mdl=mdls{mIdx};
        m2mObj.fXformObj.setContext(mdl);
        m2mObj.fXformObj.skipLibraryBlocks(m2mObj.fSkipLinkedBlks);
        m2mObj.fXformObj.analyzeModel();
        candidates=m2mObj.fXformObj.getCandidates();


        m2mObj.fCandidates=[m2mObj.fCandidates;candidates];
    end
    try
        m2mObj.fBd.term;
    catch
    end
end
