



classdef(Abstract)model2model<handle
    properties(Access='public')
fOpenXformModel
        fBd;
        fSess;
        fPirCreator;
        fMdl;
        fOriMdl;
        fXformedMdl;
        fErrMsg;

        fMdlRefs;
        fRefMdls;
        fLinkedBlks;
        fXlinkedBlks;
        fLibMdls;
        fLinkedCands;
        fMdlRefInLibMap;

        fXformDir;
        fIsPirAnalyzed;
        fIsPirXformed;
        fCandidateInfo;
        fCandidateBlks;
        fInvalidCandidates;
        fExcludedBlks;
        fXformedInfo;
        fXformedBlks;
        fXformedMdls;
        fRemovedInputLines;
        fRemovedOutputLines;
        fPrefix;
        fPosRefCount;
        fTraceabilityMap;
        fLibCopyOption;
        fBrokenLinks;
        fSimModeMap;
        fTransformed;
        fSkipLinkedBlks;
        fInModelXform;
        fModelFilepath;
        fXformedLibs;
    end

    properties(Hidden)
        cleanup;
    end

    methods(Access='public')

        function m2mObj=model2model(aOriSys)

            if~license('test','SL_Verification_Validation')
                DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseFail');
            end

            if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
                DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseCheckOutFail');
            end
            m2mObj.fOpenXformModel=true;
            m2mObj.fPirCreator=[];
            m2mObj.fMdl=aOriSys;
            m2mObj.fOriMdl=aOriSys;
            m2mObj.fXformedMdl=aOriSys;
            m2mObj.fErrMsg=[];

            m2mObj.fMdlRefs=[];
            m2mObj.fRefMdls=[];
            m2mObj.fLinkedBlks=[];
            m2mObj.fXlinkedBlks=[];
            m2mObj.fLibMdls=[];
            m2mObj.fLinkedCands=containers.Map('KeyType','double','ValueType','any');
            m2mObj.fMdlRefInLibMap=containers.Map('KeyType','char','ValueType','any');

            m2mObj.fXformDir=[];
            m2mObj.fIsPirAnalyzed=0;
            m2mObj.fIsPirXformed=0;
            m2mObj.fCandidateInfo=[];

            m2mObj.fCandidateBlks=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fInvalidCandidates=[];

            m2mObj.fExcludedBlks=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fXformedBlks=[];
            m2mObj.fRemovedInputLines=[];
            m2mObj.fRemovedOutputLines=[];
            m2mObj.fPrefix='gen_';
            m2mObj.fPosRefCount=containers.Map('KeyType','char','ValueType','double');
            m2mObj.fTraceabilityMap;
            m2mObj.fLibCopyOption=1;
            m2mObj.fSimModeMap=containers.Map('KeyType','char','ValueType','char');
            m2mObj.fTransformed=0;
            m2mObj.fSkipLinkedBlks=1;
            m2mObj.fInModelXform=false;
            m2mObj.fModelFilepath='';
            m2mObj.fXformedLibs={};

            hiliteData1=struct('HiliteType','user1','ForegroundColor','black','BackgroundColor','yellow');
            hiliteData2=struct('HiliteType','user2','ForegroundColor','black','BackgroundColor','lightBlue');
            set_param(0,'HiliteAncestorsData',hiliteData1);
            set_param(0,'HiliteAncestorsData',hiliteData2);


            if~bdIsLoaded(aOriSys)
                open_system(aOriSys);
            end


            m2mObj.fXformDir=['m2m_',aOriSys,'/'];


            m2mObj.getAllMdlRefAndLibBlks(aOriSys,[],{});
            if~isempty(m2mObj.fLinkedBlks)
                m2mObj.fLibMdls=unique({m2mObj.fLinkedBlks.lib});
            end

            for lIdx=1:length(m2mObj.fLibMdls)
                if bdIsLoaded(m2mObj.fLibMdls{lIdx})
                    load_system(m2mObj.fLibMdls{lIdx});
                end
            end

            m2mObj.fSess=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
            m2mObj.fBd=Simulink.CMI.CompiledBlockDiagram(m2mObj.fSess,m2mObj.fMdl);


            mdls=[{m2mObj.fMdl},m2mObj.fRefMdls];
            clearPIRs(mdls);


            mdlRefBlks=[];
            if~isempty(m2mObj.fRefMdls)
                mdlRefBlks={m2mObj.fMdlRefs.block};
            end
            simModeMap=m2mObj.fSimModeMap;
            bd=m2mObj.fBd;

            m2mObj.cleanup=onCleanup(@()BaseCleanupFcn(m2mObj,bd,mdls,mdlRefBlks,simModeMap));
        end

        function term(m2mObj)
            if ishandle(m2mObj.fBd.Handle)&&strcmpi(get_param(m2mObj.fBd.Handle,'SimulationStatus'),'paused')
                m2mObj.fBd.term;
            end
        end

        trvdMdls=getAllMdlRefAndLibBlks(this,aMdl,aDir,aTrvdMdls);
        getAllReferlinkedBlks_addOn(this);
        xformedBlocks=getXformedBlocks(this);
        [mdls,linkedBlksInXformedLibs]=getXformedModels(this);
        exclusions=showExclusion(this);
        msg=exclude(this,aBlk);
        msg=include(this,aBlk);
        isExcluded=isExcludedBlk(this,aBlk);
        isInvalid=isInvalidBlk(this,aBlk);
        isCandidate=isCandidateBlk(this,aBlk);
        initializeModelGen(this);
        createBackupModel(this);
        isTraceable=isTraceableBlk(this,aBlk);
        xformedBlks=trace(this,aBlk);
        clearAllHilite(this);
        setSegmentParam(this,aNewSeg,aOldSeg);
        saveGeneratedMdls(this);
        setPrefix(this,prefix);
        errMsg=xformSpecificInit(this);
        errMsg=xformSpecificPreProc(this);
        brokenLinks=deactivateLibBlkwithCandidate(this);
        errMsg=performXformation(this);
        errMsg=propagateChangesInLibraries(this,aBrokenLinks);
        errMsg=xformSpecificPostProc(this);
        errMsg=generateMdls(this,aPrefix);
        initBusStruct=getInitBusStruct(this,aMdl,aBus);
        setSim2ModeNormal(this);
        restoreSimMode(this);
        linkedCandBlk=checkLinkStatusAndRegister(this,aCandidateBlk);
    end

    methods(Access='private')
        function BaseCleanupFcn(m2mObj,aBd,aPIRs,aMdlRefBlks,aSimModeMap)%#ok
            p=pir;

            for idx=1:length(aPIRs)
                try
                    if iskey(aSimModeMap,aPIRs{idx})&&...
                        ~strcmpi(get_param(aPIRs{idx},'SimulationMode'),aSimModeMap(aPIRs{idx}))
                        set_param(aPIRs{idx},'SimulationMode',aSimModeMap(aPIRs{idx}));
                    end
                catch
                end
            end


            try
                if ishandle(aBd.Handle)&&strcmpi(get_param(aBd.Handle,'SimulationStatus'),'paused')
                    aBd.term;
                end
            catch
            end


            modifiedMdls=cell(1,0);
            for idx=1:length(aMdlRefBlks)
                try
                    if isKey(aSimModeMap,aMdlRefBlks{idx})
                        mdlvariants=get_param(aMdlRefBlks{idx},'variants');
                        modelChanged=false;
                        if~strcmpi(get_param(aMdlRefBlks{idx},'SimulationMode'),aSimModeMap(aMdlRefBlks{idx}))
                            set_param(aMdlRefBlks{idx},'SimulationMode',aSimModeMap(aMdlRefBlks{idx}));
                            modifiedMdls=unique([modifiedMdls,bdroot(aMdlRefBlks{idx})]);
                        end
                        if~isempty(mdlvariants)
                            for mIdx=1:length(mdlvariants)
                                if~strcmpi(mdlvariants(mIdx).SimulationMode,aSimModeMap([mdlvariants(mIdx).ModelName,'@',aMdlRefBlks{idx}]))
                                    mdlvariants(mIdx).SimulationMode=aSimModeMap([mdlvariants(mIdx).ModelName,'@',aMdlRefBlks{idx}]);
                                    modelChanged=true;
                                end
                            end
                            if(modelChanged)
                                set_param(aMdlRefBlks{idx},'variants',mdlvariants);
                            end
                        end



                    end
                catch
                end
            end
            for idx=1:length(modifiedMdls)
                save_system(modifiedMdls{idx});
            end
        end
    end

    methods(Abstract)
        errMsg=identify(this);
    end
end

function clearPIRs(aPIRs)
    p=pir;
    for idx=1:length(aPIRs)
        p.destroyPirCtx([aPIRs{idx}]);
    end
end


