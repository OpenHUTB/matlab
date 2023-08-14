




function getReducedBlocks(coveng,modelH,testId)

    try
        modelCovId=get_param(modelH,'CoverageId');
        topCvId=cv('get',cv('get',modelCovId,'.activeRoot'),'.topSlsf');
        analyzedH=cv('get',topCvId,'.handle');


        allBlocks=find_system(analyzedH,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'Type','block');
        getOptimizedBlocks(allBlocks,testId);
        getBlockReduction(modelH,allBlocks,testId);
        getNotAnalyzedByBlockSettings(allBlocks,testId);
        getNotAnalyzedMdlRefs(analyzedH,testId);
        if strcmpi(get_param(coveng.topModelH,'CovSFcnEnable'),'on')
            getNotAnalyzedSFunction(coveng.slccCov.sfcnCov,allBlocks,testId);
        end
    catch MEx
        rethrow(MEx);
    end

    function getOptimizedBlocks(allBlocks,testId)
        blockTypesToConsider={'Abs'};
        rb={};
        for i=1:length(allBlocks)
            cb=allBlocks(i);
            cvId=get_param(cb,'CoverageId');
            if cvId~=0
                for idx=1:numel(blockTypesToConsider)
                    cbt=blockTypesToConsider{idx};
                    if strcmpi(get_param(cb,'BlockType'),cbt)
                        covid=get_param(cb,'CoverageId');
                        if cv('get',covid,'.isReduced')
                            rat=getString(message('Slvnv:simcoverage:cvhtml:AbsUnsignedNotReported'));
                            rb=[rb,{{Simulink.ID.getSID(cb),rat}}];%#ok<AGROW>
                        end
                    end
                end
            end
        end
        addReduced(testId,rb);

        function getBlockReduction(modelH,allBlocks,testId)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

            o=get_param(modelH,'object');
            cect=o.getCondExecTree;
            nCecT=[];
            for i=1:numel(cect)
                if strcmpi(cect(i).cecType,'CondInput')
                    if isempty(nCecT)
                        nCecT=cect(i);
                    else
                        nCecT(end+1)=cect(i);%#ok<AGROW>
                    end
                end
            end
            condExecBlocks=[];
            if~isempty(nCecT)
                condExecBlocks=unique([nCecT.blocksMovedToCECInputSide,nCecT.blocksMovedToCECOutputSide]);
            end
            rb={};
            cvt=cvtest(testId);
            cvs=cvt.settings;
            for i=1:length(allBlocks)
                cvId=get_param(allBlocks(i),'CoverageId');

                if cvId~=0
                    object=get_param(allBlocks(i),'object');
                    rat=[];
                    cecb=condExecBlocks(condExecBlocks==object.Handle);
                    if~isempty(cecb)&&SlCov.CoverageAPI.hasEnabledMetric(cvId,cvs)
                        rat=getString(message('Slvnv:simcoverage:cvhtml:ConditionallyExecutedBlock'));
                    end













                    if object.isPostCompileVirtual&&...
                        (~object.isModelReference||isEliminatedModelRef(allBlocks(i)))&&...
                        ~object.isObserverReference
                        rat=[getString(message('Slvnv:simcoverage:cvhtml:BlockReductionEliminated')),' ',rat];%#ok<AGROW>
                    end
                    if~isempty(rat)
                        rb=[rb,{{Simulink.ID.getSID(object.Handle),rat}}];%#ok<AGROW>
                    end
                end
            end
            addReduced(testId,rb);

            function eliminated=isEliminatedModelRef(blockH)



                if strcmpi(get_param(blockH,'SimulationMode'),'accelerator')
                    eliminated=false;
                    return;
                end
                eliminated=true;
                modelName=get_param(blockH,'ModelName');
                covId=get_param(modelName,'CoverageId');
                if covId~=0
                    currentTest=cv('get',covId,'.currentTest');
                    eliminated=(currentTest==0);
                end


                function addReduced(testId,rb)
                    if isempty(rb)
                        return;
                    end
                    crb=cv('get',testId,'.reducedBlocks');
                    crb=[crb,rb];
                    cv('set',testId,'.reducedBlocks',crb);


                    function getNotAnalyzedMdlRefs(analyzedH,testId)
                        modelH=bdroot(analyzedH);
                        if Simulink.internal.useFindSystemVariantsMatchFilter()
                            [refMdls,mdlBlks]=find_mdlrefs(modelH,...
                            'MatchFilter',@Simulink.match.activeVariants);
                        else
                            [refMdls,mdlBlks]=find_mdlrefs(modelH,'Variants','ActiveVariants');
                        end


                        isLoaded=bdIsLoaded(refMdls);
                        load_system(refMdls(~isLoaded));
                        isCopyMdl=cellfun(@(c)Simulink.internal.isModelReferenceMultiInstanceNormalModeCopy(c),refMdls);

                        rb={};
                        if strcmpi(get_param(modelH,'CovAccelSimSupport'),'off')
                            for idx=1:numel(mdlBlks)
                                if strcmpi(get_param(mdlBlks{idx},'SimulationMode'),'accelerator')
                                    rat=getString(message('Slvnv:simcoverage:cvhtml:AcceleratedModelReference'));
                                    rb=[rb,{{Simulink.ID.getSID(mdlBlks{idx}),rat}}];%#ok<AGROW>
                                end
                            end
                        end

                        close_system(refMdls(~(isLoaded|isCopyMdl)),0)

                        addReduced(testId,rb);

                        function getNotAnalyzedByBlockSettings(allBlocks,testId)

                            rb={};
                            for idx=1:numel(allBlocks)
                                if strcmpi(get_param(allBlocks(idx),'BlockType'),'SubSystem')&&...
                                    strcmpi(get_param(allBlocks(idx),'Permissions'),'NoReadOrWrite')
                                    rb=[rb,{{Simulink.ID.getSID(allBlocks(idx)),getString(message('Slvnv:simcoverage:cvhtml:SubsystemWithNoReadOrWrite'))}}];%#ok<AGROW>
                                end
                            end
                            addReduced(testId,rb);


                            function getNotAnalyzedSFunction(sfcnCov,allBlocks,testId)

                                rb={};
                                if sfcnCov.incompSFcnSet.length()>0

                                    goodBlkH=allBlocks(ishandle(allBlocks));
                                    if isempty(goodBlkH)
                                        return
                                    end


                                    sfcnBlkH=unique(find_system(goodBlkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','BlockType','S-Function'));
                                    if isempty(sfcnBlkH)
                                        return
                                    end

                                    keys=sfcnCov.incompSFcnSet.keys();
                                    for ii=1:numel(keys)


                                        blkH=find_system(sfcnBlkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FunctionName',keys{ii});
                                        if~isempty(blkH)
                                            val=sfcnCov.incompSFcnSet(keys{ii});
                                            for jj=1:numel(blkH)
                                                if val{2}==1
                                                    msg=getString(message('Slvnv:simcoverage:cvhtml:SFcnNotCompatible'));
                                                else
                                                    msg=getString(message('Slvnv:simcoverage:cvhtml:SFcnCompatibleButError'));
                                                end
                                                rb=[rb,{{Simulink.ID.getSID(blkH(jj)),msg}}];%#ok<AGROW>
                                            end
                                        end
                                    end
                                    addReduced(testId,rb);
                                end


