classdef m2m_lut<slEnginePir.model2model&handle




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

    properties(Hidden)
        cleanup_lut;
    end

    methods(Access='public')
        function m2mObj=m2m_lut(aOriSys)
            p=pir;
            p.destroyPirCtx(aOriSys);
            m2mObj@slEnginePir.model2model(aOriSys);


            m2mObj.fCandidateInfo=struct('isExcluded',{},'BPs',{},'src',{},'group',{});
            m2mObj.fCompiled=false;
            m2mObj.fCandidate2IdxMap=struct('');
            m2mObj.fXformCommands={};
            m2mObj.fInvalidCandidates=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fTraceabilityMap=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fExcludedPorts=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fRemovedSrcSegs=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fRemovedDstSegs=containers.Map('KeyType','char','ValueType','any');


            m2mObj.setSimMode2Normal;


            mdls=[{m2mObj.fOriMdl},m2mObj.fRefMdls];
            bd=m2mObj.fBd;
            m2mObj.cleanup_lut=onCleanup(@()CleanupFcn(m2mObj,bd));

            creator=slEnginePir.CloneDetectionCreator(Simulink.SLPIR.Event.PostCompBlock);
            creator.createGraphicalPir(mdls);

            m2mObj.fPirCreator=slEnginePir.PIRUpdate(Simulink.SLPIR.Event.PostCompBlock);
            m2mObj.fPirCreator.add;


            set_param(m2mObj.fOriMdl,'SLPIR','on');


            ME=MException('','');
            try
                m2mObj.fBd.init;
            catch ME
            end
            if~isempty(ME.message)
                DAStudio.error('sl_pir_cpp:creator:UnsimulatableModel',aOriSys);
            end
            m2mObj.fCompiled=true;

            m2mObj.fXformObj=Simulink.SLPIR.M2MLUTXform;
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


