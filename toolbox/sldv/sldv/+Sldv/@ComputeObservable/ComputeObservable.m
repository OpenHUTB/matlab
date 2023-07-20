




classdef ComputeObservable<handle




    properties

        ModelName='';





        StartBlocks={};









        ResetBlocks={};







        MaxDepth=0;























        CovDependency=[];

        Networks=[];

        forcedTurnOnRelationalBoundary=false;

        usePotentialDetectionSites=false;

        potentialDetSites=[];

        useTestPointsAsPotentialDetSites=false;
    end

    properties(Access=private)


        testcomp=[];


        customValues=struct(...
        'AllowPassThrough',true,...
        'SupportedBlocks','',...
        'InspectionBlocks',[],...
        'AllBlocksInspection',true);


        mMaxUnitDelayLength=0;


        mExpandAtomicSubsystems=false;


        mObservationBlocks={};




        BlkToSID=[];
        SIDToBlk=[];



        BlocksSeen=[];

        ModelQueue=[];
        MdlQueIndex=0;
        SubSysQueue=[];
        SubSysQueIndex=0;


        mCustomCondtions=[];
        mSubSysExpandedH=[];
        mModelExpandedH=[];

        mInlineAtomicSubsystem=false;
        mMaxPathsPerSrc=-1;
        mMaxPathLengthPerSrc=-1;

        blockReplacementApplied=false;
        atomicSubsystemAnalysis=false;
    end


    methods(Access=public)







        function status=constructDependencyMap(obj)

            Sldv.ComputeObservable.logDebugEvt("ComputeObservable","constructDependencyMap","Start");

            status=true;


            initialVal=feature('EngineInterface');
            feature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);

            oc=onCleanup(@()feature('EngineInterface',initialVal));



            obj.InitModelQueue();

            obj.createDependencyMap();

            obj.addDependenciesForTheCustomAuthoredTestObjectiveBlocks();


            Sldv.ComputeObservable.logDebugEvt("ComputeObservable","constructDependencyMap","End");
        end

    end

    methods(Access=protected)

        subsysExpandedH=getSubSyExpanded(obj)
        setSubSysExpanded(obj,subsystemH)
        statList=initializeStartListAndSubsystems(obj,subsysH)





        createDependencyMap(obj)









        function InitModelQueue(obj)

            obj.ModelQueue=[];
            obj.MdlQueIndex=1;

            if isempty(obj.StartBlocks)
                obj.ModelQueue{end+1}=obj.ModelName;

                Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","AddingToModelQueue",obj.ModelName);
            else
                for i=1:length(obj.StartBlocks)
                    fullNameParts=strsplit(getfullname(obj.StartBlocks{i}),'/');
                    obj.ModelQueue{end+1}=fullNameParts{1};

                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","AddingToModelQueue",obj.ModelName{end});
                end
            end
        end









        function status=initializeDependencyMap(obj,modelName)
            if~isempty(obj.CovDependency)&&...
                ~isempty(find(strcmp({obj.CovDependency.MdlName},modelName),1))
                status=false;
            else
                obj.CovDependency(end+1).MdlName=modelName;
                obj.CovDependency(end).Dependency=[];
                status=true;
                obj.mModelExpandedH=get_param(modelName,'handle');


                Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","initializeDependencyMap","Adding model to CovDependency--> "+modelName);
            end
        end
















        function startList=getModelStartList(obj,modelName)
            startList=[];



            for i=1:length(obj.StartBlocks)
                fullNameParts=strsplit(getfullname(obj.StartBlocks{i}),'/');
                if strcmp(modelName,fullNameParts{1})
                    startList{end+1}=obj.StartBlocks{i};%#ok<AGROW>
                end
            end



            if isempty(obj.StartBlocks)||...
                ~strcmp(modelName,obj.ModelName)
                startList=initializeStartListAndSubsystems(obj,modelName);


                try
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getModelStartList",...
                    "Getting starting points for Model::"+modelName);
                    for ind=1:numel(startList)
                        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getModelStartList",...
                        "startingBlock::"+getfullname(startList(ind)));
                    end
                catch Mex
                end
            end
        end







        function InitSubSysQueue(obj)
            obj.SubSysQueue=[];
            obj.SubSysQueue(1)=get_param(obj.ModelQueue{obj.MdlQueIndex},'Handle');
            obj.SubSysQueIndex=1;
            obj.setSubSysExpanded(obj.SubSysQueue(1));

            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","InitSubSysQueue",...
            "Added model to SubSysQueue::"+get_param(obj.SubSysQueue(1),"Name"));
        end














        getSubSystemDependency(obj,stList)











        doDFSAnalysis(obj,blockH,inportNo,srcBlockH,srcPortNo)













        isBlkAdded=addCovDependency(obj,blockH,inportNo,srcBlockH,srcPortNo)




        function addToModelQueue(obj,blockH)



            if strcmp(get_param(blockH,'BlockType'),'ModelReference')
                mdlName=get_param(blockH,'ModelName');
                if isempty(find(strcmp(obj.ModelQueue,mdlName),1))
                    obj.ModelQueue{end+1}=get_param(blockH,'ModelName');


                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","addToModelQueue",...
                    "Model ::"+obj.ModelQueue{end});
                end
            end
        end


        function yesNo=isObservationPoint(obj,blkSID)
            yesNo=false;
            try
                blkType=get_param(blkSID,'BlockType');
                isInObservationBlockList=any(strcmp(blkType,obj.mObservationBlocks));
                if isInObservationBlockList||...
                    (strcmp(blkType,'SubSystem')&&~obj.isSubSystemPenetrable(obj.getHandle(blkSID))&&...
                    ~obj.isActionSubsystemWithOutports(obj.getHandle(blkSID)))
                    yesNo=true;
                    return;
                end
            catch

            end
        end




        function addToSubSystemQueue(obj,blockH)




            if blockH==obj.mModelExpandedH
                return;
            end
            if strcmp(get_param(blockH,'BlockType'),'SubSystem')
                if isempty(find((obj.SubSysQueue==blockH),1))
                    obj.SubSysQueue(end+1)=blockH;


                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","addToSubSystemQueue",...
                    "Subsystem ::"+Sldv.ComputeObservable.getBlkName(obj.SubSysQueue(end)));
                end
            end
        end






        function isSeen=isBlockSeen(obj,blockH)
            if~isempty(find((obj.BlocksSeen==blockH),1))
                isSeen=true;
            else
                obj.BlocksSeen(end+1)=blockH;
                isSeen=false;
            end
        end
























        function yesNo=isSubSystemPenetrable(obj,SubSysH)
            yesNo=false;
            if SubSysH==obj.mModelExpandedH
                yesNo=false;
                return;
            end

            blkType=get_param(SubSysH,'BlockType');
            if~strcmp(blkType,'SubSystem')
                return;
            end

            if sldvprivate('isMaskAndEnabledForObservability',SubSysH)
                yesNo=true;
                return;
            end

            SS=Simulink.SubsystemType(SubSysH);
            SS_type=SS.getType();
            if strcmp(SS_type,'virtual')
                yesNo=true;
                return;
            end
            SS_rtw_mode=get_param(SubSysH,'RTWSystemCode');

            if strcmp(SS_type,'atomic')&&checkIfAtomicSSToInline(obj,...
                SubSysH,...
                SS_rtw_mode)
                yesNo=true;
                return;
            end
        end

        function toInline=checkIfAtomicSSToInline(obj,subsysH,SS_rtw_mode)
            toInline=false;
            if obj.mInlineAtomicSubsystem
                if strcmp(SS_rtw_mode,'Inline')==1
                    toInline=true;
                elseif strcmp(SS_rtw_mode,'Auto')==1
                    try
                        blockH=mapBlockHToOriginal(obj,subsysH);
                        blockType=get_param(blockH,'BlockType');
                        if strcmp(blockType,'ModelReference')==0
                            toInline=true;
                        end
                    catch
                        toInline=false;
                    end
                end
            end
        end

        function blockH=mapBlockHToOriginal(obj,blockH)

            if obj.blockReplacementApplied||obj.atomicSubsystemAnalysis
                origModelH=obj.testcomp.analysisInfo.designModelH;
                if obj.atomicSubsystemAnalysis
                    parent=get_param(obj.testcomp.analysisInfo.analyzedSubsystemH,'parent');
                    parentH=get_param(parent,'Handle');
                else
                    parentH=origModelH;
                end
                blockH=sldvshareprivate('util_resolve_obj',...
                blockH,parentH,obj.atomicSubsystemAnalysis,...
                obj.blockReplacementApplied,obj.testcomp);

            end
        end

        function out=isSubsystem(obj,blkH)%#ok<INUSL>
            out=false;
            if strcmp(get_param(blkH,'type'),'block')&&...
                strcmp(get_param(blkH,'BlockType'),'SubSystem')
                out=true;
            end
        end

        function out=isConditionalSubsystem(obj,blkH)
            out=false;
            if obj.isSubsystem(blkH)
                SS=Simulink.SubsystemType(blkH);
                if SS.isEnabledSubsystem()||SS.isTriggeredSubsystem()||...
                    SS.isEnabledAndTriggeredSubsystem()||SS.isFunctionCallSubsystem()||...
                    SS.isForIteratorSubsystem()||SS.isWhileIteratorSubsystem()
                    out=true;
                end
            end
        end

        function out=isActionSubsystemWithOutports(obj,SubSysH)
            out=false;
            if obj.isActionSubSystem(SubSysH)
                portHandles=get_param(SubSysH,'portHandles');
                if~isempty(portHandles.Outport)
                    out=true;
                end
            end
        end
        function out=stopPathAtInportsOfBlock(obj,blockH)%#ok<INUSL>
            out=false;
            if strcmp(get_param(blockH,'type'),'block')
                blockType=get_param(blockH,'blockType');
                if strcmp(blockType,'If')
                    out=true;
                end
            end
        end

        function out=portSpecificStop(obj,blockH,inport)
            out=false;
            if obj.isActionSubSystem(blockH)




                portHandles=get_param(blockH,'portHandles');
                if inport<=length(portHandles.Inport)
                    out=true;
                end
            end
            if obj.isConditionalSubsystem(blockH)


                out=true;
            end
        end

        function yesNo=isActionSubSystem(obj,SubSysH)%#ok<INUSL>
            yesNo=false;
            blkType=get_param(SubSysH,'BlockType');
            if~strcmp(blkType,'SubSystem')
                return;
            end

            portHandles=get_param(SubSysH,'portHandles');
            if~isempty(portHandles.Ifaction)
                yesNo=true;
            end
        end

        function isResetContinue=checkPortWidthMismatch(~,blockH,inportNo,srcBlockH,srcPortNo)
            isResetContinue=false;
            try
                if inportNo>0&&srcBlockH~=0
                    srcBlkType=get_param(srcBlockH,'blockType');
                    if strcmp(srcBlkType,'SwitchCase')||strcmp(srcBlkType,'If')
                        return;

                    end
                    blockHPh=get_param(blockH,'PortHandles');
                    if~isempty(blockHPh.Inport)
                        inportWidth=get_param(blockHPh.Inport(inportNo),'CompiledPortWidth');

                        srcBlockPh=get_param(srcBlockH,'PortHandles');
                        outportWidth=get_param(srcBlockPh.Outport(srcPortNo),'CompiledPortWidth');
                        if inportWidth~=outportWidth
                            isResetContinue=true;
                        end
                    end
                end
            catch Mex %#ok<NASGU>
                isResetContinue=true;


            end

        end

        function isConditionalSS=checkIfConditionalPort(obj,blockH,inportNo)
            isConditionalSS=false;
            try
                if strcmp(get_param(blockH,'BlockType'),'SubSystem')==1
                    ss=Simulink.SubsystemType(blockH);
                    if ss.isTriggeredSubsystem()||ss.isEnabledSubsystem()||...
                        ss.isEnabledAndTriggeredSubsystem()||ss.isFunctionCallSubsystem()
                        portH=get_param(blockH,'PortHandles');
                        if length(portH.Inport)<inportNo
                            isConditionalSS=true;
                        end
                    end
                end
            catch

            end

        end

        function toReset=isMultiportSwitchWithTwoInputs(obj,blockH)
            toReset=false;
            if strcmp(get_param(blockH,'BlockType'),'MultiPortSwitch')==1
                ph=get_param(blockH,'PortHandles');
                if length(ph.Inport)==2
                    toReset=true;
                end
            end
        end













        function[isResetBlk,resetContinue]=blockIsResetBlock(obj,blockH,inportNo,srcBlockH,outportNo)
            isResetBlk=false;
            resetContinue=false;

            origResetBlks=obj.ResetBlocks;


            ResetBlockSet={'ModelReference','BusCreator','DataStoreWrite','Outport','Selector','MATLABSystem'};








            if~isempty(find(strcmp(origResetBlks,getfullname(blockH)),1))
                isResetBlk=true;
            elseif checkRateTransition(obj,blockH,srcBlockH)
                isResetBlk=true;
                resetContinue=true;
            elseif checkPortWidthMismatch(obj,blockH,inportNo,srcBlockH,outportNo)
                isResetBlk=true;
                resetContinue=true;
            elseif checkIfConditionalPort(obj,blockH,inportNo)
                isResetBlk=true;
                resetContinue=true;
            elseif strcmp('SubSystem',get_param(blockH,'BlockType'))
                if~obj.isActionSubSystem(blockH)
                    isResetBlk=true;
                    return;
                end
            elseif~isempty(find(strcmp(ResetBlockSet,get_param(blockH,'BlockType')),1))
                isResetBlk=true;
            elseif strcmp(get_param(blockH,'BlockType'),'S-Function')&&...
                ~strcmp(get_param(blockH,'Name'),'customAVTBlockSFcn')
                isResetBlk=true;
            else
                isResetBlk=blockHasStates();
            end



            if isResetBlk&&...
                strcmp(get_param(blockH,'BlockType'),'UnitDelay')&&...
                obj.mMaxUnitDelayLength>0

                isResetBlk=false;
            end

            function yesNo=blockHasStates()




                try
                    blkObj=get_param(blockH,'Object');
                    blkRtObj=blkObj.RuntimeObject;
                catch Mex %#ok<NASGU>
                    yesNo=true;

                    return;
                end
                if isempty(blkRtObj)
                    numInPorts=0;
                else
                    numInPorts=blkRtObj.NumInputPorts;
                end

                yesNo=false;

                for i=1:numInPorts
                    try
                        if~blkRtObj.InputPort(i).DirectFeedthrough
                            yesNo=true;
                        end
                    catch



                        yesNo=true;







                    end

                    if yesNo
                        break;
                    end
                end
            end
        end

        function isRateTransition=checkRateTransition(obj,blockH,srcBlockH)
            isRateTransition=false;
            if(blockH~=0&&srcBlockH~=0)
                try
                    if strcmp(get_param(blockH,'BlockType'),'RateTransition')
                        isRateTransition=true;
                    else
                        blockHSampleTx=get_param(blockH,'CompiledSampleTime');
                        srcBlockHSampleTx=get_param(srcBlockH,'CompiledSampleTime');
                        if iscell(blockHSampleTx)
                            blockHSampleTx=blockHSampleTx{1};
                        end
                        if iscell(srcBlockHSampleTx)
                            srcBlockHSampleTx=srcBlockHSampleTx{1};
                        end
                        if~iscell(blockHSampleTx)&&~iscell(srcBlockHSampleTx)
                            if any(blockHSampleTx~=srcBlockHSampleTx)
                                isRateTransition=true;
                            end
                        end
                    end
                catch Msg
                    isRateTransition=true;
                end
            end
        end





        function addCustomAuthoredConditionsToList(obj,BlkH)

            if~sldvprivate('isMaskAndEnabledForObservability',BlkH)
                return;
            end

            if(isKey(obj.mCustomCondtions,BlkH))
                return;
            end


            testObjBlocks=find_system(BlkH,...
            'SearchDepth',1,...
            'LookUnderMasks','all',...
            'BlockType','SubSystem');

            idx=arrayfun(@(x)Sldv.ComputeObservable.isTestObjBlock(x),testObjBlocks);
            obj.mCustomCondtions(BlkH)=testObjBlocks(idx);
        end

        function addDependenciesForTheCustomAuthoredTestObjectiveBlocks(obj)
            tCustomMaskBlocks=keys(obj.mCustomCondtions);


            cellfun(@(x)addTestObjectivesInCovDependencyStruct(x),tCustomMaskBlocks);




            cellfun(@(x)addDependencyForTestObjectives(x),tCustomMaskBlocks);

            function addTestObjectivesInCovDependencyStruct(blkH)
                inportNo=1;
                srcBlockH=[];
                srcPortNo=0;
                arrayfun(@(x)obj.addCovDependency(x,inportNo,srcBlockH,srcPortNo),obj.mCustomCondtions(blkH));
            end

            function addDependencyForTestObjectives(blkH)
                origBlk=sldvprivate('observableBlockInsideMask',blkH);
                try

                    parentName=Simulink.ID.getFullName(blkH);
                    origBlkH=get_param([parentName,'/',origBlk],'Handle');
                catch
                    return;
                end

                dst=getDestination(obj,origBlkH);
                for ind=2:numel(dst)
                    destBlockH=dst(ind).destBlockH;
                    inportNo=dst(ind).inportNo;
                    srcPortNo=1;
                    arrayfun(@(x)obj.addCovDependency(destBlockH,inportNo,x,srcPortNo),obj.mCustomCondtions(blkH));
                end
            end

            function dst=getDestination(obj,blockH)
                PortHs=get_param(blockH,'PortHandles');
                dst=struct('destBlockH',[],'inportNo',[]);
                blkhExpansionCtx=getExpansionContext(obj,blockH);






                for PIdx=1:length(PortHs.Outport)
                    PhObj=get_param(PortHs.Outport(PIdx),'Object');

                    PortBoundedDst=PhObj.getBoundedDst;
                    numOutLinesBD=size(PortBoundedDst);
                    allBoundedDests=[];
                    for i=1:numOutLinesBD(1)
                        bd=PortBoundedDst(i,1);
                        BDestBlkH=get_param(bd,'ParentHandle');
                        allBoundedDests(end+1)=BDestBlkH;%#ok<AGROW>
                    end

                    PortActualDst=PhObj.getActualDst;
                    NumOutLines=size(PortActualDst);
                    for LIdx=1:NumOutLines(1)
                        ActualDest=PortActualDst(LIdx,1);
                        DestBlkH=get_param(ActualDest,'ParentHandle');
                        DestPort=get_param(ActualDest,'PortNumber');
                        destExpansionCtx=getExpansionContext(obj,DestBlkH);

                        if blkhExpansionCtx==destExpansionCtx&&...
                            isempty(intersect(DestBlkH,allBoundedDests))
                            if length(obj.CovDependency(end).Dependency)>0 %#ok<ISMT>
                                found=find(strcmp({obj.CovDependency(end).Dependency.BlkName},...
                                obj.getSID(DestBlkH)));
                                if found
                                    dst(end+1).destBlockH=DestBlkH;%#ok<AGROW>
                                    dst(end).inportNo=DestPort;
                                end
                            end
                        end
                    end
                end
            end
        end

        function subsystemH=getImmediateNonPenetratableAncestor(obj,subsysH)
            if obj.isSubSystemPenetrable(subsysH)

                parentSubsys=get_param(subsysH,'Parent');
                parentH=get_param(parentSubsys,'handle');
                subsystemH=getImmediateNonPenetratableAncestor(obj,parentH);
            else
                subsystemH=subsysH;
            end
        end

        function subsystemH=getExpansionContext(obj,blkH)


            parentSubsys=get_param(blkH,'Parent');
            parentH=get_param(parentSubsys,'handle');
            subsystemH=getImmediateNonPenetratableAncestor(obj,parentH);
        end

        function outports=getPotDetSitesForBlk(obj,block)
            outports=[];

            if~obj.useTestPointsAsPotentialDetSites



                sid=Simulink.ID.getSID(obj.mapBlockHToOriginal(block));
            else



                sid=Simulink.ID.getSID(block);
            end

            if obj.potentialDetSites.isKey(sid)
                outports=obj.potentialDetSites(sid);
            end
        end
    end


    methods(Access=public)
        composeSpec=generateCompSpec(obj)
    end

    methods(Access=protected)
        composeSpec=generateModelCompSpec(obj,idx)






















        yesNo=checkBlkOutputSpecNeedsUpdate(obj,MdlIdx,BlkIdx)





        function sid=getSID(obj,blockH)






            if~isempty(obj.BlkToSID)&&...
                isKey(obj.BlkToSID,blockH)
                sid=obj.BlkToSID(blockH);
                return;
            end

            sid=Simulink.ID.getSID(blockH);


            k=strfind(sid,':0');
            if~isempty(k)&&...
                (k==length(sid)-1)


                l=length(obj.BlkToSID);
                sid=[sid(1:(k-1)),':_unique_:',num2str(l+1)];
                obj.BlkToSID(blockH)=sid;
                obj.SIDToBlk(sid)=blockH;
            end
        end





        function blkH=getHandle(obj,sid)





            if~isempty(obj.SIDToBlk)&&...
                isKey(obj.SIDToBlk,sid)
                blkH=obj.SIDToBlk(sid);
            else
                blkH=Simulink.ID.getHandle(sid);
            end
        end



        function val=isGeneratedSID(obj,sid)
            if isKey(obj.SIDToBlk,sid)
                val=true;
            else
                val=false;
            end
        end








        objList=getObjectiveList(obj,MdlIdx,BlkIdx,InportNo)
        composeSpec=getPathObjectiveListToPass(obj,MdlIdx,BlkIdx,i)









        function[status,composeSpec]=getBlkOutputSpec(obj,MdlIdx,blkName,portNo)
            status=true;
            if strcmp(blkName,'DefaultBlockDiagram')
                composeSpec=[];
                return;
            end

            [BlkFound,BlkIdx]=find(strcmp({obj.CovDependency(MdlIdx).Dependency.BlkName},blkName));
            if isempty(BlkFound)||~BlkFound
                status=false;
                composeSpec=[];
                return;
            end
            composeSpec=obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).OutputObjectives;
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).UsedInCompose=true;

            if length(obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).DestBlks)>1
                obj.CovDependency(MdlIdx).Dependency(BlkIdx).num_paths=...
                obj.CovDependency(MdlIdx).Dependency(BlkIdx).num_paths+1;
            end


            blkH=obj.getHandle(blkName);
            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getBlkOutputSpec",...
            "UsedInCompose:: "+Sldv.ComputeObservable.getBlkName(blkH)+" port:: "+portNo);
        end

        function[status,composeSpec]=getBlkOutputSpecWithPathLimit(obj,MdlIdx,blkName,portNo,destBlkName)

            status=true;
            if strcmp(blkName,'DefaultBlockDiagram')
                composeSpec=[];
                return;
            end

            [BlkFound,BlkIdx]=find(strcmp({obj.CovDependency(MdlIdx).Dependency.BlkName},blkName));
            if isempty(BlkFound)||~BlkFound
                status=false;
                composeSpec=[];
                return;
            end

            blkOutputSpec=obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec;
            default_prop_dest=obj.CovDependency(MdlIdx).Dependency(BlkIdx).default_propagation_dest;

            composeSpec=obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).OutputObjectives;
            outcomposeSpec=[];
            pathSrcBlkUpdated=[];
            for i=1:length(composeSpec)

                stmt=composeSpec(i);
                path=stmt.pathList;
                pathSrcBlk=path(1).sid;

                [~,srcBlkIdx]=find(strcmp({obj.CovDependency(MdlIdx).Dependency.BlkName},pathSrcBlk));




                if obj.mMaxPathLengthPerSrc>=0&&(length(path)-1)>=obj.mMaxPathLengthPerSrc
                    obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).ObjectiveObsPoint(i)=true;
                else
                    if obj.mMaxPathsPerSrc==0
                        toAdd=false;
                    elseif(length(blkOutputSpec(portNo).DestBlks)==1||...
                        isempty(default_prop_dest))
                        toAdd=true;
                    elseif obj.mMaxPathsPerSrc>0&&...
                        obj.CovDependency(MdlIdx).Dependency(srcBlkIdx).num_paths>=obj.mMaxPathsPerSrc
                        toAdd=false;
                    else
                        toAdd=true;
                    end
                    if toAdd
                        pathSrcBlkUpdated=[pathSrcBlkUpdated,srcBlkIdx];%#ok<AGROW>
                        outcomposeSpec=[outcomposeSpec,stmt];%#ok<AGROW>
                    end
                    obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).ObjectiveObsPoint(i)=false;
                end

            end
            blkPathUpdateIndices=unique(pathSrcBlkUpdated);
            if isempty(default_prop_dest)&&~isempty(blkPathUpdateIndices)
                obj.CovDependency(MdlIdx).Dependency(BlkIdx).default_propagation_dest=destBlkName;
            else
                for i=1:length(blkPathUpdateIndices)
                    blkId=blkPathUpdateIndices(i);
                    obj.CovDependency(MdlIdx).Dependency(blkId).num_paths=...
                    obj.CovDependency(MdlIdx).Dependency(blkId).num_paths+1;
                end
            end
            if~isempty(blkPathUpdateIndices)
                obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(portNo).UsedInCompose=true;
            end
            composeSpec=outcomposeSpec;
        end



        function resetBlkEffectsOnSpec(obj,MdlIdx,BlkIdx,inPort)
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkEffectsOnSpec(inPort).blkList...
            =[];

            blkSID=obj.CovDependency(MdlIdx).Dependency(BlkIdx).BlkName;
            blkH=obj.getHandle(blkSID);
            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","resetBlkEffectsOnSpec",...
            "Resetting the blkEffectsOnSpec for:: "+Sldv.ComputeObservable.getBlkName(blkH)+" inPort:: "+inPort);
        end




        function resetBlkOutputSpec(obj,MdlIdx,BlkIdx,outPortNo)
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(outPortNo).OutputObjectives...
            =[];


            blkSID=obj.CovDependency(MdlIdx).Dependency(BlkIdx).BlkName;
            blkH=obj.getHandle(blkSID);
            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","resetBlkOutputSpec",...
            "Resetting the resetBlkOutputSpec for:: "+Sldv.ComputeObservable.getBlkName(blkH)+" outPortNo:: "+outPortNo);
        end



        function addBlkOutputSpec(obj,MdlIdx,BlkIdx,outPortNo,composeStmts)
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(outPortNo).OutputObjectives...
            =[obj.CovDependency(MdlIdx).Dependency(BlkIdx).blkOutputSpec(outPortNo).OutputObjectives,composeStmts];

            blkSID=obj.CovDependency(MdlIdx).Dependency(BlkIdx).BlkName;
            blkH=obj.getHandle(blkSID);
            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","addBlkOutputSpec",...
            "Appending the blkOutputSpec for:: "+Sldv.ComputeObservable.getBlkName(blkH)+" outPortNo:: "+outPortNo);
        end

        getGenericObjs(obj,MdlIdx,BlkIdx)

        getCustomAuthoredObjs(obj,MdlIdx,BlkIdx)

        updated=getPassThroughObjs(obj,MdlIdx,BlkIdx)

        srcEffects=getSrcBlkSpecEffects(obj,MdlIdx,BlkIdx,inPort)

        status=addDelayToPath(obj,MdlIdx,BlkIdx)

        status=generateNetworkInfo(obj)
    end


    methods(Access=public)
        function allowPassThroughBlocks(obj)


            obj.customValues.AllowPassThrough=true;
        end

        function stopPassThroughBlocks(obj)


            obj.customValues.AllowPassThrough=false;
        end

        function setOutportConnectionToStopBlock(obj,block,outportNo)
            blkName=obj.getSID(block);
            len=length(obj.CovDependency(end).Dependency);
            if len>0
                [found,idx]=find(strcmp({obj.CovDependency(end).Dependency.BlkName},...
                blkName));
                if found
                    obj.CovDependency(end).Dependency(idx).outportConnectedToStopBlock{outportNo}=true;
                end
            end
        end

        function setBlockOutportAsPotDetSite(obj,block,outportNo)
            blkName=obj.getSID(block);
            len=length(obj.CovDependency(end).Dependency);
            if len>0
                [found,idx]=find(strcmp({obj.CovDependency(end).Dependency.BlkName},...
                blkName));
                if found
                    obj.CovDependency(end).Dependency(idx).outportPotDetSite{outportNo}=true;
                end
            end
        end

        function allowPassThrough=isPassThroughAllowed(obj,blockH)


            allowPassThrough=obj.customValues.AllowPassThrough;







            if~allowPassThrough
                try
                    passThroughBlocks={'UnitDelay','Outport'};
                    blockType=get_param(blockH,'BlockType');
                    allowPassThrough=any(strcmp(blockType,passThroughBlocks));
                catch

                end
            end

            if obj.isActionSubSystem(blockH)

                return;
            end


            phs=get_param(blockH,'PortHandles');
            numInports=length(phs.Inport);
            numOutports=length(phs.Outport);

            if numInports>0&&numOutports>0
                if numInports==1&&numOutports==1
                    inPortWidth=get_param(phs.Inport,'CompiledPortWidth');
                    outPortWidth=get_param(phs.Outport,'CompiledPortWidth');
                    if inPortWidth~=outPortWidth
                        allowPassThrough=false;
                    end
                else
                    allowPassThrough=false;
                end
            end

        end

        function setBlocksToAnalyze(obj,blkTypeList)







            obj.customValues.SupportedBlocks={};




            if ischar(blkTypeList)
                obj.customValues.SupportedBlocks{1}=blkTypeList;
            elseif iscell(blkTypeList)
                obj.customValues.SupportedBlocks=blkTypeList;
            end
        end




        function addInspectionBlock(obj,blkList)

            if ischar(blkList)
                blocks={blkList};
            else
                blocks=blkList;
            end
            for i=1:length(blocks)
                if iscell(blocks)
                    block=blocks{i};
                else
                    block=blocks(i);
                end
                if ischar(block)
                    blockH=get_param(block,'Handle');
                else
                    blockH=block;
                end
                blockSid=obj.getSID(blockH);
                if isempty(obj.customValues.InspectionBlocks)
                    obj.customValues.InspectionBlocks={blockSid};
                else
                    obj.customValues.InspectionBlocks=[obj.customValues.InspectionBlocks,blockSid];
                end
            end
        end



        function setAllInspectionBlocks(obj)
            obj.customValues.AllBlocksInspection=true;
        end



        function resetAllInspectionBlocks(obj)
            obj.customValues.AllBlocksInspection=false;
        end
    end

    methods(Access=protected)
        function needBaseObj=isBaseObjectiveBlock(obj,MdlIdx,BlkIdx)



            needBaseObj=true;
            blkStruct=obj.CovDependency(MdlIdx).Dependency(BlkIdx);
            for i=1:length(blkStruct.blkInputDependency)
                if~isempty(blkStruct.blkInputDependency(i).SrcBlk)
                    if(length(blkStruct.blkInputDependency(i).SrcBlk)>1)||...
                        ~strcmp(blkStruct.blkInputDependency(i).SrcBlk(1),...
                        'DefaultBlockDiagram')
                        needBaseObj=false;
                    end
                end
            end
        end

        function addBlkControlSpec(obj,MdlIdx,BlkIdx,composeStmts)
            obj.CovDependency(MdlIdx).Dependency(BlkIdx).controlObjective=composeStmts;
        end

        status=addInspectionObjectivesToOutport(obj,MdlIdx,BlkIdx)

    end


    methods(Static)
        function[isCovBlock,testcomp]=blockHasSLDVCoverage(blockH,testcomp,customValues)



            if(nargin<3)
                customValues=[];
            end

            [numObsvFunc,~,~,~,testcomp]=sldvprivate('getBlockCustomizationFunctions',...
            blockH,testcomp);
            isCovBlock=(numObsvFunc>0);




            if~isempty(customValues)&&~isempty(customValues.SupportedBlocks)
                if isempty(find(strcmp(customValues.SupportedBlocks,...
                    get_param(blockH,'BlockType')),1))
                    isCovBlock=false;
                end
            end
        end

        function val=logicNonMaskingValue(blkH)


            nonMaskVal=containers.Map(...
            {'AND','NAND','OR','NOR','XOR','NXOR','NOT'},...
            {1,1,0,0,0,0,1});

            op=get_param(blkH,'Operator');
            val=nonMaskVal(op);
        end

        function val=computeLogicOutputValue(in,blkH)
            op=get_param(blkH,'operator');

            switch(op)
            case 'NOT'
                val=~in;
            case{'AND','OR','XOR'}
                val=in;
            case{'NAND','NOR','NXOR'}
                val=~in;
            end
        end

        function blkName=getBlkName(blkH)
            blkName='Invalid BlkH';
            try
                blkName=get_param(blkH,'Name');
            catch
            end
        end

        function logDebugMsgs(fname,msgIdentifier,msg)
            LoggerId='sldv::path_specification';
            logStr=sprintf('%s::%s::%s',fname,msgIdentifier,msg);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
        end

        function logDebugEvt(fname,msgIdentifier,evt)
            LoggerId='sldv::path_specification';
            markers=sprintf('%s::%s::%s',fname,msgIdentifier,...
            "********************************************");
            logStr=sprintf('%s::%s::%s',fname,msgIdentifier,evt);

            sldvprivate('SLDV_LOG_DEBUG',LoggerId,markers);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,markers);
        end

        function yesNo=isTestObjBlock(blkH)
            tMask=Simulink.Mask.get(blkH);
            yesNo=~isempty(tMask)&&strcmpi('design verifier test objective',tMask.Type);
        end

        function yesNo=isVerificationSubSystem(blkH)
            tMask=Simulink.Mask.get(blkH);
            yesNo=~isempty(tMask)&&strcmp('VerificationSubsystem',tMask.Type);
        end



        function yesNo=isBlockUnderTheCustomAuthoredMask(blkH,tModelName)
            parentName=get_param(blkH,'Parent');
            parentH=get_param(parentName,'Handle');
            yesNo=sldvprivate('isMaskAndEnabledForObservability',parentH);
            if yesNo||isequal(get_param(tModelName,'Handle'),parentH)
                return;
            else
                yesNo=Sldv.ComputeObservable.isBlockUnderTheCustomAuthoredMask(parentH,tModelName);
            end
        end

        function yesNo=isOriginalBlockUnderCustomAuthoredMask(blkH)

            parentName=get_param(blkH,'Parent');
            parentH=get_param(parentName,'Handle');
            origBlk=sldvprivate('observableBlockInsideMask',parentH);
            yesNo=strcmp(origBlk,get_param(blkH,'Name'));
        end

        function[yesNo,isOriginalBlockUnderMask]=isCustomAuthoredUtilityBlocksOrOriginalBlock(blkH,tModelName)
            yesNo=Sldv.ComputeObservable.isBlockUnderTheCustomAuthoredMask(blkH,tModelName);
            isOriginalBlockUnderMask=Sldv.ComputeObservable.isOriginalBlockUnderCustomAuthoredMask(blkH);
        end

        function customTestObjective=isCustomAuthoredTestObjective(blockH,modelName)
            customTestObjective=false;
            isCustomAuthored=Sldv.ComputeObservable.isBlockUnderTheCustomAuthoredMask(blockH,modelName);
            if isCustomAuthored
                if Sldv.ComputeObservable.isTestObjBlock(blockH)
                    customTestObjective=true;
                end
            end
        end
    end


    methods











        function obj=ComputeObservable(testcomp,modelName,customOptions,...
            customEnhancedMCDCOpts,depth,...
            startBlks,resetBlks)
            obj.testcomp=testcomp;

            obj.ModelName=modelName;

            obj.blockReplacementApplied=testcomp.analysisInfo.replacementInfo.replacementsApplied;
            obj.atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',testcomp);

            if nargin<3
                customOptions=[];
            end

            if nargin<4
                customEnhancedMCDCOpts=[];
            end

            if(nargin<5)
                obj.MaxDepth=0;
            else
                obj.MaxDepth=depth;
            end

            if(nargin<6)
                obj.StartBlocks={};
            else
                obj.StartBlocks=startBlks;
            end

            if(nargin<7)
                obj.ResetBlocks={};
            else
                obj.ResetBlocks=resetBlks;
            end

            obj.CovDependency=[];
            obj.BlocksSeen=[];


            configOpts=sldvprivate('sldvEnhancedMCDCOpts','all');
            obj.init(configOpts);


            try

                configOpts=feval(customOptions);
                obj.init(configOpts);
            catch


            end

            obj.mCustomCondtions=containers.Map('KeyType','double','ValueType','any');

            obj.BlkToSID=containers.Map('KeyType','double','ValueType','char');
            obj.SIDToBlk=containers.Map('KeyType','char','ValueType','double');




            if strcmp(obj.testcomp.activeSettings.StrictEnhancedMCDC,'on')&&...
                strcmp(obj.testcomp.activeSettings.IncludeRelationalBoundary,'off')



                find_systems_opts={'FollowLinks','on','LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','RelationalOperator'};

                relOpBlks=find_system(obj.ModelName,find_systems_opts{:});
                if~isempty(relOpBlks)
                    obj.forcedTurnOnRelationalBoundary=true;
                end
            end


            obj.potentialDetSites=containers.Map('KeyType','char','ValueType','any');

            if~isempty(customEnhancedMCDCOpts)&&isstruct(customEnhancedMCDCOpts)&&...
                isfield(customEnhancedMCDCOpts,'potentialDetectionSites')


                obj.usePotentialDetectionSites=true;
                potentialDetectionSites=customEnhancedMCDCOpts.potentialDetectionSites;

                for i=1:length(potentialDetectionSites)
                    if~obj.potentialDetSites.isKey(potentialDetectionSites(i).block)
                        obj.potentialDetSites(potentialDetectionSites(i).block)=...
                        potentialDetectionSites(i).outport;
                    else
                        currentOutports=obj.potentialDetSites(potentialDetectionSites(i).block);
                        obj.potentialDetSites(potentialDetectionSites(i).block)=...
                        [currentOutports,potentialDetectionSites(i).outport];
                    end
                end
            else

                obj.usePotentialDetectionSites=true;
                obj.useTestPointsAsPotentialDetSites=true;











                testPoints=find_system(obj.ModelName,'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'findall','on','type','port','portType','outport',...
                'DataLogging','on','TestPoint','on');

                if~isempty(testPoints)
                    testPointedBlks=get_param(testPoints,'Parent');
                    testPointedPorts=get_param(testPoints,'PortNumber');


                    for i=1:length(testPoints)
                        if iscell(testPointedBlks)
                            loggedBlk=Simulink.ID.getSID(testPointedBlks{i});
                            loggedOutport=testPointedPorts{i};
                        else
                            loggedBlk=Simulink.ID.getSID(testPointedBlks);
                            loggedOutport=testPointedPorts;
                        end

                        if~obj.potentialDetSites.isKey(loggedBlk)
                            obj.potentialDetSites(loggedBlk)=loggedOutport;
                        else
                            currentOutports=obj.potentialDetSites(loggedBlk);
                            obj.potentialDetSites(loggedBlk)=[currentOutports,loggedOutport];
                        end
                    end
                end
            end

        end













        function init(obj,configOpts)

            Sldv.ComputeObservable.logDebugEvt("ComputeObservable","InitializingOptions","Start");


            if isfield(configOpts,'AllBlocksInspection')
                obj.customValues.AllBlocksInspection=configOpts.AllBlocksInspection;

                if configOpts.AllBlocksInspection
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","AllBlocksInspection = true");
                else
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","AllBlocksInspection = false");
                end
            end


            if isfield(configOpts,'InspectionBlkList')
                obj.addInspectionBlock(configOpts.InspectionBlkList);
            end


            if isfield(configOpts,'AllowPassThrough')
                obj.customValues.AllowPassThrough=configOpts.AllowPassThrough;

                if configOpts.AllowPassThrough
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","AllowPassThrough = true");
                else
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","AllowPassThrough = false");
                end
            end


            if isfield(configOpts,'StartBlocks')
                obj.StartBlocks=configOpts.StartBlocks;
            end


            if isfield(configOpts,'ResetBlocks')
                obj.ResetBlocks=configOpts.ResetBlocks;
            end


            if isfield(configOpts,'MaxUnitDelayLength')
                obj.mMaxUnitDelayLength=configOpts.MaxUnitDelayLength;

                str=sprintf("MaxUnitDelayLength = %d",configOpts.MaxUnitDelayLength);
                Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                "InitializingOptions",str);
            end



            if isfield(configOpts,'ExpandAtomicSubsystems')
                obj.mExpandAtomicSubsystems=configOpts.ExpandAtomicSubsystems;

                if configOpts.ExpandAtomicSubsystems
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","ExpandAtomicSubsystems = true");
                else
                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable",...
                    "InitializingOptions","ExpandAtomicSubsystems = false");
                end
            end


            if isfield(configOpts,'BlocksToAnalyze')&&~isempty(configOpts.BlocksToAnalyze)
                obj.setBlocksToAnalyze(configOpts.BlocksToAnalyze);
            end


            if isfield(configOpts,'ObservableBlocks')
                obj.mObservationBlocks=configOpts.ObservableBlocks;
            end

            if isfield(configOpts,'MaxPathLengthPerSrc')
                obj.mMaxPathLengthPerSrc=configOpts.MaxPathLengthPerSrc;
            end

            if isfield(configOpts,'MaxPathsPerSrc')
                obj.mMaxPathsPerSrc=configOpts.MaxPathsPerSrc;
            end

            obj.mInlineAtomicSubsystem=sldvprivate('getAdvancedParamForEnhancedMCDC');


            Sldv.ComputeObservable.logDebugEvt("ComputeObservable","InitializingOptions","End");
        end

        function delete(obj)
            obj.mCustomCondtions=[];
        end
    end


    methods(Access=protected)
        status=getSwitchObjs(obj,MdlIdx,BlkIdx)
        status=getLogicObjs(obj,MdlIdx,BlkIdx)
        status=getMinMaxObjs(obj,MdlIdx,BlkIdx)
        status=getRelOpObjs(obj,MdlIdx,BlkIdx)
    end
end
