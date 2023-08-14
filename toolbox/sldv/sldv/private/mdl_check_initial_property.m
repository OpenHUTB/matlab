function[status,stubsfcns]=mdl_check_initial_property(status,modelH,testcomp,sldvopts,aBlks,aBlkTypes)














    stubsfcns=[];

    UnstubbableBlockTypes={'Integrator','SecondOrderIntegrator','RandomNumber',...
    'StateSpace','TransferFcn','ZeroPole',...
    'UniformRandomNumber','Stop','TestFcnCallException',...
    'EntityTransportDelay','Neighborhood'};

    if~supportingSystemObjects
        UnstubbableBlockTypes{end+1}='MATLABSystem';
    end













    if slfeature('ParameterWriteToModelWorkspaceVariable')
        UnstubbableBlockTypes{end+1}='ParameterWriter';
    end

    FcnBlockUnsupportSet={'^','acos','asin','atan','atan2','cos','cosh','exp',...
    'hypot','ln','log','log10','pow','power','sin','sinh','tan','tanh',...
    'sqrt'};



    if exist('fbt_testing_active','file')&&fbt_testing_active()
        SFcnUnsupported={'sfix_dtprop'};
    else
        SFcnUnsupported={};
    end




    dsp_comm_sfuncs={'scomapskdemod3','scomapskmod3','scomberlekamp',...
    'scominhshape','scominttobit','scomrsencoder',...
    'sdspmtrnsp2','sdsprandsrc2','sdsplms'};


    SFcnUnstubable={...
    'svip2dconv','svip2dfirfilter','svip2dsad','svipapplygeotform','svipblkprop',...
    'svipblob','svipblockmatch','svipblockprociter','svipchromresamp','svipcolorconv',...
    'svipcomposite','svipcontrastadjust','svipcornermetric','svipdeinterlace',...
    'svipdemosaic','svipdrawmarkers','svipdrawshapes','svipedge','svipesttform',...
    'svipfileread','svipfilewrite','svipfindlocalmax','svipgamma','svipgraythresh',...
    'sviphisteq','sviphough','sviphoughlines','svipimgcomplement','svipindexgenol',...
    'sviplabel','svipmdnfilter','svipmorphop','svipopticalflow','svipprojective',...
    'svippsnr','svippyramid','svipresize','sviproidisplay','sviprotate','svipscalenconvert',...
    'svipshear','sviptemplatematching','sviptextrender','sviptraceboundary',...
    'sviptranslate','svipvideofromwks','svipvideotowks','svipwvo2','sdspsigattrib',...
    'sdsppinv','sfun_user_fxp_const','sdspupfir2'};


    SFcnUnsupported=[SFcnUnsupported,dsp_comm_sfuncs];




    [modelObAcs,modelSrcCS]=sldvshareprivate('mdl_get_configset',modelH);
    modelSolverType=modelObAcs.getProp('SolverType');

    createdForSubsystemAnalysis=mdl_iscreated_for_subsystem_analysis(testcomp);





    if strcmp(modelSolverType,'Variable-step')&&...
        ~createdForSubsystemAnalysis
        msgId='Sldv:Compatibility:UnsupSolver';
        errMsg=getString(message(msgId));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end

    if strcmp(sldvopts.Mode,'TestGeneration')
        if(get(sldvopts,'RelativeTolerance')<0.0||get(sldvopts,'AbsoluteTolerance')<0.0)
            msgId='Sldv:Compatibility:NegativeTolerance';
            errMsg=getString(message(msgId));
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
            status='DV_COMPAT_INCOMPATIBLE';
            return;
        end
        if(get(sldvopts,'RelativeTolerance')==0.0&&get(sldvopts,'AbsoluteTolerance')==0.0)
            msgId='Sldv:Compatibility:ZeroRelZeroAbsTolerance';
            errMsg=getString(message(msgId));
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
            status='DV_COMPAT_INCOMPATIBLE';
            return;
        end

    end

    if nonzeroSimStartTime(modelH)


        msgId='Sldv:Compatibility:NonZeroSimStartTimeNotSupported';
        errMsg=getString(message(msgId));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv_warning',errMsg,msgId);
    end

    if strcmpi(get_param(modelSrcCS,'ConcurrentTasks'),'on')

        msgId='Sldv:Compatibility:UnsupConcurrentExecution';
        errMsg=getString(message(msgId));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end

    initState=get_param(modelH,'LoadInitialState');
    if strcmp(initState,'on')

        msgId='Sldv:Compatibility:UnsupInitialState';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end

    initFcn=get_param(modelH,'InitFcn');
    if~isempty(initFcn)&&~isnull(mtree(initFcn,'-nocom'))

        msgId='Sldv:Compatibility:ModelCallbackInitFcn';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end


    if strcmp(get_param(modelH,'ArrayLayout'),'Row-major')&&~slfeature('SldvRowMajor')
        msgId='Sldv:Compatibility:RowMajorArrayLayout';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end
    if strcmp(get_param(modelH,'UseRowMajorAlgorithm'),'on')&&~slfeature('SldvRowMajor')
        msgId='Sldv:Compatibility:UseRowMajorAlgorithm';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end


    if~slavteng('feature','BusElemPortSupport')&&sldvshareprivate('mdl_check_rootlvl_buselemport',modelH)
        msgId='Sldv:Compatibility:RootLvlBusElemPortNotSupported';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    elseif slavteng('feature','BusElemPortSupport')


        isIncompatible=mdlHasUnsupportedBusElems(modelH);
        if isIncompatible
            status='DV_COMPAT_INCOMPATIBLE';
            return;
        end
    end



    if~slavteng('feature','StartupVariantSLDV')&&modelHasStartupVariants(aBlks,aBlkTypes)
        msgId='Sldv:Compatibility:StartupVariantNotSupported';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end

    if~sldvprivate('isEliminateModRefInliningEnabled',modelH)


        [~,notInlinedMdlBlks]=find_mdlrefs(modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
        if~isempty(notInlinedMdlBlks)
            notReplacedBlockTable=testcomp.analysisInfo.replacementInfo.notReplacedBlksTable;

            for idx=1:length(notInlinedMdlBlks)
                if strcmp(get_param(notInlinedMdlBlks{idx},'ProtectedModel'),'on')
                    msgId='Sldv:Compatibility:ProtectedModel';
                    errMsgBlock=getString(message(msgId,get_param(notInlinedMdlBlks{idx},'ModelFile')));
                    sldvshareprivate('avtcgirunsupcollect','push',get_param(notInlinedMdlBlks{idx},'Handle'),'sldv',...
                    errMsgBlock,msgId);
                else
                    modelBlockH=get_param(notInlinedMdlBlks{idx},'Handle');
                    if notReplacedBlockTable.isKey(modelBlockH)
                        info=notReplacedBlockTable(modelBlockH);
                        msgs=info.IsReplaceableMsgs;
                        if~iscell(msgs)
                            msgs={msgs};
                        end
                        for jdx=1:length(msgs)
                            msg=msgs{jdx};
                            pattern='(?<msgid>\w+):=(?<msgtxt>(.)*)';
                            pairs=regexp(msg,pattern,'names');
                            sldvshareprivate('avtcgirunsupcollect','push',modelBlockH,'sldv',...
                            pairs.msgtxt,['Sldv:Compatibility:',pairs.msgid]);
                        end
                    else
                        msgId='Sldv:Compatibility:UnsupportedModelRefBlock';
                        errMsgGeneric=getString(message(msgId,get_param(modelH,'Name')));
                        sldvshareprivate('avtcgirunsupcollect','push',modelBlockH,'sldv',...
                        errMsgGeneric,msgId);
                    end
                end
            end
            status='DV_COMPAT_INCOMPATIBLE';
            return;
        end
    end



    if(1==(bitand(slfeature('IRTSupportInSLDV'),1)))&&(false==checkForReinitResetSubsystems(aBlks,aBlkTypes))
        msgId='Sldv:Compatibility:UnsupportedReinitResetFunction';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv',...
        errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;

    elseif(0==(bitand(slfeature('IRTSupportInSLDV'),1)))&&(false==checkForIRTSubsystems(modelH))
        msgId='Sldv:Compatibility:UnsupportedIRTFunction';
        errMsg=getString(message(msgId,get_param(modelH,'Name')));
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv',...
        errMsg,msgId);
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end


    errorExists=false;
    warningExists=false;

    if~sldvprivate('isEliminateModRefInliningEnabled',modelH)||any(strcmp('ObserverPort',aBlkTypes))



        AlwaysUnsupportedBlockTypes={'ModelReference'};
    else
        AlwaysUnsupportedBlockTypes=[];
    end
    PartiallyUnsupportedBlockTypes={'Fcn','FromFile'};
    if(slfeature('SLDV_SUPPORT_DYNAMIC_INDEXING_DATA_STORE')==0)
        PartiallyUnsupportedBlockTypes{end+1}='DataStoreWrite';
        PartiallyUnsupportedBlockTypes{end+1}='DataStoreRead';
    end
    AllPartiallyUnsupported=union(PartiallyUnsupportedBlockTypes,{'S-Function'});
    UnsupportedBlockTypes=union(AlwaysUnsupportedBlockTypes,AllPartiallyUnsupported);



    isFE=strcmp('ForEach',aBlkTypes);
    if any(isFE)
        hasFEPP=false;

        FEblocks=aBlks(isFE);
        for jdx=1:numel(FEblocks)
            hasPartitionedParams=get_param(FEblocks(jdx),'SubsysMaskParameterPartition');
            if~isempty(hasPartitionedParams)&&any(strcmp(hasPartitionedParams,'on'))
                msgId='Sldv:Compatibility:ForEachWithPartitionedParam';
                errMsg=getString(message(msgId));
                sldvshareprivate('avtcgirunsupcollect','push',FEblocks(jdx),'simulink',errMsg,msgId);
                hasFEPP=true;
            end
        end

        if hasFEPP
            status='DV_COMPAT_INCOMPATIBLE';
            return;
        end
    end


    if(~isempty(sldvopts)&&strcmp(sldvopts.AutomaticStubbing,'off'))
        isStubbingOff=true;
    else
        isStubbingOff=false;
    end

    foundAkimaSplineBlock=processLookupNdBlocks(aBlks,testcomp.activeSettings,modelH);
    errorExists=errorExists||foundAkimaSplineBlock;

    replaceMap=...
    Sldv.xform.BlkReplacer.getInstance().getBlockTypesAutoToBeReplacedMap;

    expectedToBeReplacedBlockTypes=replaceMap.keys;

    for idx=1:length(expectedToBeReplacedBlockTypes)
        checkSFun=false;
        currentMapKey=expectedToBeReplacedBlockTypes{idx};
        currentBlkType=currentMapKey;
        toReportBlkType=currentBlkType;
        if contains(currentBlkType,'S-Function(Lookup Table Dynamic)')
            toReportBlkType='Lookup Table Dynamic';
            currentBlkType='S-Function';
            checkSFun=true;
        end
        matchArray=strcmp(currentBlkType,aBlkTypes);
        if any(matchArray)
            blocks=aBlks(matchArray);
            for jdx=1:length(blocks)
                block=blocks(jdx);
                if checkSFun&&~strcmp(get_param(block,'MaskType'),toReportBlkType)
                    continue;
                end
                if any(strcmp(toReportBlkType,{'Lookup','Lookup2D'}))&&...
                    strcmp(get_param(block,'Mask'),'on')
                    msgId='Sldv:Compatibility:UnstubMaskedLookupTLCBlock';
                    errMsg=getString(message(msgId,toReportBlkType));
                    sldvshareprivate('avtcgirunsupcollect','push',block,'simulink',errMsg,msgId);
                    errorExists=true;
                else
                    [under,selfModifMaskSSH]=Sldv.xform.MdlRefBlkTreeNode.isMdlBlkUnderSelfModifMaskedSS(block);
                    if under
                        rules=replaceMap(currentMapKey);
                        for ruleIdx=1:numel(rules)
                            try





                                willReplace=rules(ruleIdx).IsReplaceableCallBack(block);
                            catch
                                willReplace=true;
                            end
                            if willReplace
                                selfModifMaskSSH=get_param(selfModifMaskSSH,'Handle');
                                selfModifMaskSSH=mapBlockHToOriginal(selfModifMaskSSH,testcomp);
                                msgId='Sldv:Compatibility:UnstubBlksSelfModif';
                                errMsg=getString(message(msgId,getfullname(selfModifMaskSSH),toReportBlkType));
                                sldvshareprivate('avtcgirunsupcollect','push',block,'simulink',errMsg,msgId);
                                errorExists=true;
                                break;
                            end
                        end
                    end
                end
            end
        end
    end

    for i=1:length(UnstubbableBlockTypes)
        matchArray=strcmp(UnstubbableBlockTypes{i},aBlkTypes);
        if any(matchArray)
            blocks=aBlks(matchArray);
            for jdx=1:length(blocks)
                block=blocks(jdx);

                if isStubbingOff
                    msgId='Sldv:Compatibility:BlockIsNotSupported';
                else
                    msgId='Sldv:Compatibility:BlockCannotBeStubbed';
                end
                errMsg=getString(message(msgId,UnstubbableBlockTypes{i}));
                sldvshareprivate('avtcgirunsupcollect','push',block,'simulink',errMsg,msgId);
                errorExists=true;
            end
        end
    end

    for i=1:length(UnsupportedBlockTypes)
        matchArray=strcmp(UnsupportedBlockTypes{i},aBlkTypes);
        if any(matchArray)
            blocks=aBlks(matchArray);
            for jdx=1:length(blocks)
                block=blocks(jdx);
                [errMsg,errID,stubable,allowSfcn]=generateErrorMsg(block,PartiallyUnsupportedBlockTypes,...
                FcnBlockUnsupportSet,SFcnUnsupported,SFcnUnstubable);
                if~isempty(errMsg)
                    if stubable
                        sldvshareprivate('avtcgirunsupcollect','push',block,'sldv_stubbed',errMsg,errID);
                        warningExists=true;
                    else
                        sldvshareprivate('avtcgirunsupcollect','push',block,'simulink',errMsg,errID);
                        errorExists=true;
                    end
                elseif~isempty(allowSfcn)
                    stubsfcns(end+1)=allowSfcn;%#ok<AGROW>
                end
            end
        end
    end

    if errorExists
        status='DV_COMPAT_INCOMPATIBLE';
        return;
    end

    errorExists=check_chart_update(modelH,errorExists);

    if errorExists
        status='DV_COMPAT_INCOMPATIBLE';
    elseif warningExists
        status='DV_COMPAT_PARTIALLY_SUPPORTED';
    end

    function[blocks,charts]=machine_linked_charts(machineId)
        blocks=sf('get',machineId,'.sfLinks');
        charts=zeros(size(blocks));

        for idx=1:length(blocks)
            charts(idx)=sf('Private','block2chart',blocks(idx));
        end

        function result=shouldThrowWarning(aLookupNdBlock,aActiveSettings)
            result=strcmp(aActiveSettings.BlockReplacement,'on');
            result=result&&contains(aActiveSettings.BlockReplacementRulesList,'<FactoryDefaultRules>');

            numTabDim=get_param(aLookupNdBlock,'NumberOfTableDimensions');
            result=result&&(strcmp(numTabDim,'1')||strcmp(numTabDim,'2'));

            result=result&&~strcmp(get_param(aLookupNdBlock,'DataSpecification'),'Table and breakpoints');

            function foundUnsupLUTBlock=processLookupNdBlocks(aBlks,aActiveSettings,aModelH)
                foundUnsupLUTBlock=false;
                threwWarning=false;

                for i=1:length(aBlks)
                    if~strcmp(get_param(aBlks(i),'blockType'),'Lookup_n-D')
                        continue;
                    end

                    if~threwWarning&&shouldThrowWarning(aBlks(i),aActiveSettings)
                        sldvshareprivate('avtcgirunsupcollect','push',aModelH,'sldv_warning',...
                        getString(message('Sldv:BLOCKREPLACEMENT:LUTnDNotReplaced')),...
                        'Sldv:BLOCKREPLACEMENT:LUTnDNotReplaced');
                        threwWarning=true;
                    end

                    if strcmp(get_param(aBlks(i),'InterpMethod'),'Akima spline')||...
                        strcmp(get_param(aBlks(i),'ExtrapMethod'),'Akima spline')
                        foundUnsupLUTBlock=true;
                        msgId='Sldv:Compatibility:LookupNdWithAkimaSpline';
                        errMsg=getString(message(msgId));
                        sldvshareprivate('avtcgirunsupcollect','push',aBlks(i),'simulink',errMsg,msgId);
                    elseif startsWith(get_param(aBlks(i),'InterpMethod'),'Linear')&&...
                        (str2double(get_param(aBlks(i),'NumberOfTableDimensions'))>5)&&...
                        strcmp(get_param(aBlks(i),'IndexSearchMethod'),'Evenly spaced points')
                        foundUnsupLUTBlock=true;
                        errId='Sldv:Compatibility:UnsupportedNDLookupTableWithLinearInterpolation';
                        numDimensions=get_param(aBlks(i),'NumberOfTableDimensions');
                        sldvshareprivate('avtcgirunsupcollect','push',aBlks(i),...
                        'simulink',getString(message(errId,numDimensions)),errId);
                    end

                end

                function status=checkForReinitResetSubsystems(blks,blkTypes)
                    status=true;


                    isEvListener=strcmp('EventListener',blkTypes);
                    if any(isEvListener)
                        evListenerBlks=blks(isEvListener);
                        for idx=1:numel(evListenerBlks)
                            if((strcmp(get_param(evListenerBlks(idx),'EventType'),'Reset'))...
                                ||strcmp(get_param(evListenerBlks(idx),'EventType'),'Reinitialize'))
                                status=false;
                                break;
                            end
                        end
                    end

                    function status=checkForIRTSubsystems(aModelH)
                        status=true;
                        if(strcmp(get_param(aModelH,'HasInitializeEvent'),'on')||...
                            strcmp(get_param(aModelH,'HasTerminateEvent'),'on')||...
                            ~isempty(get_param(aModelH,'EventIdentifiers')))
                            status=false;
                        end



                        function out=check_chart_update(modelH,errorExists)
                            out=errorExists;

                            machineIds=sf('find','all','machine.name',get_param(modelH,'Name'));
                            if~isempty(machineIds)
                                for machine=machineIds(:)
                                    chartIds=sf('get',machine,'.charts');
                                    [~,linkCharts]=machine_linked_charts(machine);
                                    linkCharts=unique(linkCharts);
                                    chartIds=[chartIds(:)',linkCharts(:)'];
                                    for chart=chartIds
                                        updateMethod=sf('get',chart,'.updateMethod');
                                        if(updateMethod==2)
                                            chartName=sf('get',chart,'.name');
                                            msgId='Sldv:Compatibility:SfContUpdate';
                                            errMsg=getString(message(msgId,chartName));
                                            sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',errMsg,msgId);
                                            out=true;
                                        end
                                    end
                                end
                            end


                            function startupVariantDetected=modelHasStartupVariants(aBlks,aBlkTypes)
                                startupVariantDetected=false;
                                if slfeature('StartupVariants')<1


                                    return;
                                end


                                isVariantSrc=strcmp('VariantSource',aBlkTypes);
                                if any(isVariantSrc)
                                    varSrcBlks=aBlks(isVariantSrc);
                                    for jdx=1:numel(varSrcBlks)
                                        if strcmp(get_param(varSrcBlks(jdx),'VariantControlMode'),'expression')&&...
                                            strcmp(get_param(varSrcBlks(jdx),'VariantActivationTime'),'startup')
                                            startupVariantDetected=true;
                                            return;
                                        end
                                    end
                                end


                                isVariantSink=strcmp('VariantSink',aBlkTypes);
                                if any(isVariantSink)
                                    varSinkBlks=aBlks(isVariantSink);
                                    for jdx=1:numel(varSinkBlks)
                                        if strcmp(get_param(varSinkBlks(jdx),'VariantControlMode'),'expression')&&...
                                            strcmp(get_param(varSinkBlks(jdx),'VariantActivationTime'),'startup')
                                            startupVariantDetected=true;
                                            return;
                                        end
                                    end
                                end


                                isSS=strcmp('SubSystem',aBlkTypes);
                                if any(isSS)
                                    SSblocks=aBlks(isSS);
                                    for jdx=1:numel(SSblocks)
                                        SSBlk=Simulink.SubsystemType(SSblocks(jdx));
                                        if SSBlk.isVariantSubsystem&&...
                                            strcmp(get_param(SSblocks(jdx),'VariantControlMode'),'expression')&&...
                                            strcmp(get_param(SSblocks(jdx),'VariantActivationTime'),'startup')
                                            startupVariantDetected=true;
                                            return;
                                        end
                                    end
                                end




                                function[errMsg,errID,stubable,allowSfcn]=generateErrorMsg(block,PartiallyUnsupportedBlockTypes,...
                                    FcnBlockUnsupportSet,SFcnUnsupported,SFcnUnstubable)

                                    stubable=true;

                                    btype=get_param(block,'BlockType');
                                    errMsg=[];
                                    errID='';
                                    allowSfcn=[];

                                    BlockTypeSet=union(PartiallyUnsupportedBlockTypes,'Trigonometry');

                                    if any(strcmp(btype,BlockTypeSet))
                                        if strcmp(btype,'FromFile')
                                            fileName=get_param(block,'FileName');
                                            stubable=false;
                                            try
                                                data=evalin('base',sprintf('load(''%s'')',fileName));
                                                fields=fieldnames(data);
                                                if length(fields)==1
                                                    fromData=data.(fields{1});
                                                    stubable=~isa(fromData,'timeseries');
                                                end
                                            catch Mex %#ok<NASGU>
                                            end
                                            if~stubable
                                                errID='Sldv:Compatibility:UnstubBlks';
                                                errMsg=getString(message(errID,btype));
                                            end
                                        elseif any(strcmp(btype,{'DataStoreWrite','DataStoreRead'}))
                                            if slfeature('DynamicIndexingDataStore')
                                                indexingEnabled=strcmp('on',get_param(block,'EnableIndexing'));
                                                if indexingEnabled
                                                    stubable=false;
                                                    errID='Sldv:Compatibility:UnstubBlksEnableIndexing';
                                                    errMsg=getString(message(errID,btype));
                                                end
                                            end
                                        else
                                            Operator=getOperator(block,FcnBlockUnsupportSet);
                                            if isempty(Operator)
                                                return;
                                            end
                                            errID='Sldv:Compatibility:UnsupOp';
                                            errMsg=getString(message(errID,btype,Operator));
                                        end
                                    elseif(strcmp(btype,'S-Function'))
                                        thisSFcn=get_param(block,'FunctionName');
                                        if ismember(thisSFcn,SFcnUnsupported)
                                            [errMsg,errID]=genSFcnErrMsg(thisSFcn,true);
                                        elseif ismember(thisSFcn,SFcnUnstubable)
                                            [errMsg,errID]=genSFcnErrMsg(thisSFcn,false);
                                            stubable=false;
                                            return;
                                        else
                                            if~is_sf_sfun(block)
                                                allowSfcn=block;
                                            end
                                        end
                                    else
                                        errID='Sldv:Compatibility:UnsupType';
                                        errMsg=getString(message(errID,btype));
                                    end



                                    function out=is_sf_sfun(block)
                                        try
                                            out=slprivate('is_stateflow_based_block',get_param(block,'Parent'));
                                        catch Mex %#ok<NASGU>
                                            out=false;
                                        end




                                        function operator=getOperator(block,FcnBlockUnsupportSet)

                                            btype=get_param(block,'BlockType');
                                            operator=[];

                                            switch btype
                                            case 'Fcn'
                                                expr=get_param(block,'Expression');
                                                for i=1:length(FcnBlockUnsupportSet)
                                                    s=strfind(expr,FcnBlockUnsupportSet{i});
                                                    if~isempty(s)
                                                        operator=FcnBlockUnsupportSet{i};
                                                        break;
                                                    end
                                                end
                                            case 'Trigonometry'
                                                operator=get_param(block,'Operator');
                                            otherwise
                                                error(message('Sldv:Setup:BlockType',blockType));
                                            end



                                            function[errMsg,errID]=genSFcnErrMsg(fcnName,stubbed)
                                                switch fcnName
                                                case 'fcgen'
                                                    errID='Sldv:Compatibility:UnsupFcnCallGen';
                                                    errMsg=getString(message(errID'));
                                                otherwise
                                                    if~stubbed
                                                        errID='Sldv:Compatibility:UnstubSFcn';
                                                        errMsg=getString(message(errID,fcnName));
                                                    else
                                                        errID='Sldv:Compatibility:StubbedSFcn';
                                                        errMsg=getString(message(errID,fcnName));
                                                    end
                                                end



                                                function blockH=mapBlockHToOriginal(blockH,testcomp)
                                                    blockReplacementApplied=testcomp.analysisInfo.replacementInfo.replacementsApplied;
                                                    atomicSubsystemAnalysis=mdl_iscreated_for_subsystem_analysis(testcomp);
                                                    if blockReplacementApplied||atomicSubsystemAnalysis
                                                        origModelH=testcomp.analysisInfo.designModelH;
                                                        if atomicSubsystemAnalysis
                                                            parent=get_param(testcomp.analysisInfo.analyzedSubsystemH,'parent');
                                                            parentH=get_param(parent,'Handle');
                                                        else
                                                            parentH=origModelH;
                                                        end
                                                        blockH=sldvshareprivate('util_resolve_obj',...
                                                        blockH,parentH,atomicSubsystemAnalysis,...
                                                        blockReplacementApplied,testcomp);
                                                    end

                                                    function support=supportingSystemObjects
                                                        supportSystemObjectsForRA=slfeature('SystemObjectRA')&&sldvshareprivate('util_is_analyzing_for_fixpt_tool');
                                                        supportSystemObjectsForDV=slfeature('SystemObjectDV')&&~sldvshareprivate('util_is_analyzing_for_fixpt_tool');
                                                        support=supportSystemObjectsForRA||supportSystemObjectsForDV;

                                                        function nonzeroStart=nonzeroSimStartTime(modelH)
                                                            startTime=get_param(modelH,'StartTime');
                                                            startTime=evalinGlobalScope(modelH,startTime);
                                                            if startTime~=0.0
                                                                nonzeroStart=true;
                                                            else
                                                                nonzeroStart=false;
                                                            end



