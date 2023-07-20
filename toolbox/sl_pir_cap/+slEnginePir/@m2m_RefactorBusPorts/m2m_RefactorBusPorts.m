classdef m2m_RefactorBusPorts<slEnginePir.model2model&handle




    properties(Access='public')
        fCompiled;
        fCandidate2IdxMap;
        fXformObj;
        fCommonSrcLUTs;
        fCandidates;
        fCollapsedCandidates;
        fXformCommands;
        fExcludedPorts;
        fRemovedSrcSegs;
        fRemovedDstSegs;
    end

    methods
        function m2mObj=m2m_RefactorBusPorts(model)
            m2mObj@slEnginePir.model2model(model);

        end

        msg=identify(this);
        msg=refactoring(this,aPrefix);
        msg=performXformation(this);


        msg=trace(this,aBlk);
        msg=hiliteCandidates(this);
        info=getCandidateInfo(this);
        isTraceable=isTraceableBlk(m2mObj,aBlk);
        addBlock(this,aBlkType,aBlkFullPath);
        deleteBlock(this,aBlk);
        addLine(this,aSys,aSrcBlk,aSrcIdx,aDstBlk,aDstIdx);
        deleteLine(this,aSys,aSrcBlk,aSrcIdx,aDstBlk,aDstidx);
        setParam(this,aBlk,aParam,aVal);
        addTraceability(this,aOriBlk,aNewBlk);
        setPosRefTo(this,aTrgBlk,aRefBlk,aDir);
        xformSpecificInit(this);
        msg=excludePort(this,aBlk,aPortIdx);
        msg=includePort(this,aBlk,aPortIdx);
        excluded=isExcludedPort(this,aBlk,aPortIdx);
        msg=xformSpecificPostProc(this);
    end

    methods(Access='private')
        function CleanupFcn(m2mObj,aBd)%#ok
        end
    end
end
