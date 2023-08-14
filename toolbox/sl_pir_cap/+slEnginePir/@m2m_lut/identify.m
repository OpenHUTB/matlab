function errMsg=identify(m2mObj)




    errMsg=[];

    if m2mObj.fIsPirAnalyzed
        return;
    end

    m2mObj.fIsPirAnalyzed=1;

    mdls=[{m2mObj.fMdl},m2mObj.fRefMdls];
    m2mObj.fExcludedBlks=containers.Map('KeyType','char','ValueType','any');
    m2mObj.fInvalidCandidates=containers.Map('KeyType','char','ValueType','any');

    linkedCandidates=containers.Map('KeyType','double','ValueType','any');

    m2mObj.fXformObj.clearObject;
    for mIdx=1:length(mdls)
        mdl=mdls{mIdx};
        m2mObj.fXformObj.setContext(mdl);
        m2mObj.fXformObj.skipLibraryBlocks(m2mObj.fSkipLinkedBlks);
        m2mObj.fXformObj.analyzeModel();
        candidates=m2mObj.fXformObj.getCandidates();
        oneElemCands=[];
        for cIdx=1:length(candidates)
            if length(candidates(cIdx).LutPorts)==1
                oneElemCands=[oneElemCands,cIdx];
            end
        end
        candidates(oneElemCands)=[];
        candLutBlks=[];
        for gIdx=1:length(candidates)
            for pIdx=1:length(candidates(gIdx).LutPorts)
                candLutBlks=[candLutBlks,get_param(candidates(gIdx).LutPorts(pIdx).Block,'Handle')];
            end
        end


        m2mObj.fCandidates=[m2mObj.fCandidates;candidates];


        candLutBlks=unique(candLutBlks);
        for bIdx=1:length(candLutBlks)
            candBlk=struct('Model',mdl,'Handle',candLutBlks(bIdx));
            candBlk=checkLinkStatusAndRegister(m2mObj,candBlk);
            if isKey(m2mObj.fCandidateBlks,candBlk.Model)
                m2mObj.fCandidateBlks(candBlk.Model)=unique([m2mObj.fCandidateBlks(candBlk.Model),candBlk.Handle]);
            else
                m2mObj.fCandidateBlks(candBlk.Model)=candBlk.Handle;
            end
        end

        duplicatedGroup=[];
        for gIdx=1:length(candidates)
            linkStatus=get_param(candidates(gIdx).LutPorts(1).Block,'linkstatus');
            if~strcmpi(linkStatus,'implicit')&&~strcmpi(linkStatus,'resolved')
                continue;
            end
            candidates(gIdx).CommonSrc.Block=get_param(candidates(gIdx).CommonSrc.Block,'ReferenceBlock');
            for pIdx=1:length(candidates(gIdx).LutPorts)
                refBlk=get_param(candidates(gIdx).LutPorts(pIdx).Block,'ReferenceBlock');
                phs=get_param(refBlk,'porthandles');
                ph=phs.Inport(candidates(gIdx).LutPorts(pIdx).Port+1);
                if isKey(linkedCandidates,ph)
                    duplicatedGroup=[duplicatedGroup,gIdx];
                    break;
                else
                    linkedCandidates(ph)=[];
                    candidates(gIdx).LutPorts(pIdx).Block=refBlk;
                end
            end
        end
        candidates(duplicatedGroup)=[];
        m2mObj.fCollapsedCandidates=[m2mObj.fCollapsedCandidates;candidates];


        m2mObj.fCommonSrcLUTs=[m2mObj.fCommonSrcLUTs;m2mObj.fXformObj.getCommonSourceLUTs()];
        for cIdx=1:length(m2mObj.fCommonSrcLUTs)
            for pIdx=1:length(m2mObj.fCommonSrcLUTs(cIdx).DstPorts)
                if m2mObj.fCommonSrcLUTs(cIdx).DstPorts(pIdx).Params.atomicSSofSrc>0
                    m2mObj.fCommonSrcLUTs(cIdx).DstPorts(pIdx).Params.atomicSSofSrc=...
                    getfullname(m2mObj.fCommonSrcLUTs(cIdx).DstPorts(pIdx).Params.atomicSSofSrc);
                end
            end
        end
    end
    try
        m2mObj.fBd.term;
    catch
    end
end


