













function doDFSAnalysis(obj,blockH,inportNo,srcBlockH,srcPortNo)


    if nargin<4
        inportNo=0;
        srcBlockH=0;
        srcPortNo=0;
    end

    if ischar(blockH)
        blockH=get_param(blockH,'Handle');
    end







    [isCustAuthoredUtilityBlkOrOrigBlk,isOrigBlk]=...
    Sldv.ComputeObservable.isCustomAuthoredUtilityBlocksOrOriginalBlock(blockH,obj.ModelName);
    if isCustAuthoredUtilityBlkOrOrigBlk




        parentH=get_param(get_param(blockH,'Parent'),'Handle');
        obj.addCustomAuthoredConditionsToList(parentH);
        if~isOrigBlk
            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
            "Ignoring Custom Authored Synthesized Block::"+get_param(blockH,"Name"));
            return;
        end
    end


    [isreset,~]=obj.blockIsResetBlock(blockH,inportNo,srcBlockH,srcPortNo);
    if isreset
        [isCovered,~]=...
        Sldv.ComputeObservable.blockHasSLDVCoverage(blockH,obj.testcomp,obj.customValues);


        if isCovered
            nextSrcBlockH=blockH;
            obj.addCovDependency(blockH,inportNo,0,0);
        else
            nextSrcBlockH=0;
            obj.setOutportConnectionToStopBlock(srcBlockH,srcPortNo);
        end
    else
        [isCovered,obj.testcomp]=...
        Sldv.ComputeObservable.blockHasSLDVCoverage(blockH,obj.testcomp,...
        obj.customValues);



        if isCovered

            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
            "Block has SLDV coverage::"+get_param(blockH,"Name"));

            isBlkAdded=obj.addCovDependency(blockH,inportNo,srcBlockH,srcPortNo);
            if~isBlkAdded

                Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
                "Block not added for dependency::"+get_param(blockH,"Name"));
                return;
            end
            nextSrcBlockH=blockH;
        else

            if obj.isPassThroughAllowed(blockH)&&~obj.portSpecificStop(blockH,inportNo)
                isBlkAdded=obj.addCovDependency(blockH,inportNo,srcBlockH,srcPortNo);
                if~isBlkAdded

                    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
                    "Block not added for dependency::"+get_param(blockH,"Name"));
                    return;
                end
                nextSrcBlockH=blockH;
            else
                nextSrcBlockH=0;
                obj.setOutportConnectionToStopBlock(srcBlockH,srcPortNo);
            end
        end
    end



    if obj.isBlockSeen(blockH)


        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
        "Block already seen, stopping further DFS::"+get_param(blockH,"Name"));
        return;
    end

    stopPathAtOutportOfBlockH=false;
    if obj.usePotentialDetectionSites
        blkOutportsPotDet=obj.getPotDetSitesForBlk(blockH);
        if~isempty(blkOutportsPotDet)
            for i=1:length(blkOutportsPotDet)
                obj.setBlockOutportAsPotDetSite(blockH,blkOutportsPotDet(i));
            end
            stopPathAtOutportOfBlockH=true;

        end
    end

    PortHs=get_param(blockH,'PortHandles');
    dfsQ=struct('DestBlkH',[],'DestPort',[],'nextSrcPortNo',[]);
    subsysExpanded=obj.getSubSysExpanded();

    for PortId=1:length(PortHs.Outport)
        nextSrcPortNo=PortId;
        PhObj=get_param(PortHs.Outport(PortId),'Object');

        PortGraphicalDst=PhObj.getGraphicalDst;
        for graphicalLIdx=1:size(PortGraphicalDst,1)
            GraphicalDestBlkH=get_param(PortGraphicalDst(graphicalLIdx),'ParentHandle');
            blkTypeGraphicalDestBlkH=get_param(GraphicalDestBlkH,'blockType');


            if strcmp(blkTypeGraphicalDestBlkH,'Demux')||...
                strcmp(blkTypeGraphicalDestBlkH,'Mux')||...
                strcmp(blkTypeGraphicalDestBlkH,'Selector')
                nextSrcBlockH=0;
                break;
            end
        end

        PortActualDst=PhObj.getActualDst;
        NumOutLines=size(PortActualDst);
        resetNeeded=false;

        allActualDestBlkHs=[];
        for LIdx=1:NumOutLines(1)
            ActualDest=PortActualDst(LIdx,1);
            DestBlkH=get_param(ActualDest,'ParentHandle');
            DestPort=get_param(ActualDest,'PortNumber');
            SubsystemCtxDest=getExpansionContext(obj,DestBlkH);
            targetSubsystem=[];

            allActualDestBlkHs(end+1)=DestBlkH;%#ok<AGROW>

            if obj.usePotentialDetectionSites&&...
                strcmp(get_param(DestBlkH,'blockType'),'Outport')
                if strcmp(get_param(DestBlkH,'Parent'),obj.ModelName)
                    obj.setBlockOutportAsPotDetSite(blockH,PortId);
                end
            end

            if subsysExpanded==SubsystemCtxDest
                dfsQ(end+1).DestBlkH=DestBlkH;%#ok<AGROW>
                dfsQ(end).DestPort=DestPort;
                dfsQ(end).nextSrcPortNo=nextSrcPortNo;
                if strcmp(get_param(DestBlkH,'BlockType'),'SubSystem')
                    targetSubsystem=DestBlkH;
                end
            else
                targetSubsystem=SubsystemCtxDest;
                resetNeeded=true;
            end



            if~isempty(targetSubsystem)
                toExpandForPaths=checkSubsystemForInternalPaths(targetSubsystem);
                if toExpandForPaths
                    obj.addToSubSystemQueue(targetSubsystem);
                end
            end
        end
        if resetNeeded
            PortBoundedDst=PhObj.getBoundedDst;
            numberOfLines=size(PortBoundedDst);
            for i=1:numberOfLines(1)
                bd=PortBoundedDst(i,1);
                DestBlkH=get_param(bd,'ParentHandle');
                if isempty(intersect(DestBlkH,allActualDestBlkHs))
                    DestPort=get_param(bd,'PortNumber');
                    dfsQ(end+1).DestBlkH=DestBlkH;%#ok<AGROW>
                    dfsQ(end).DestPort=DestPort;
                    dfsQ(end).nextSrcPortNo=nextSrcPortNo;
                end
            end
        end
    end





    for idx=2:numel(dfsQ)
        DestBlkH=dfsQ(idx).DestBlkH;



        if Sldv.ComputeObservable.isVerificationSubSystem(DestBlkH)
            continue;
        end

        DestPort=dfsQ(idx).DestPort;
        nextSrcPortNo=dfsQ(idx).nextSrcPortNo;
        if strcmp(get_param(DestBlkH,'Type'),'block')

            Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","doDFSAnalysis",...
            "Starting DFS(blockH, inportNo, srcBlockH, srcPortNo)::("+get_param(DestBlkH,"Name")+","...
            +DestPort+","...
            +get_param(nextSrcBlockH,"Name")+","...
            +nextSrcPortNo...
            +")");
            if stopPathAtOutportOfBlockH
                nextSrcBlockH=0;
            end
            obj.doDFSAnalysis(DestBlkH,DestPort,nextSrcBlockH,nextSrcPortNo);
        end
    end
end

function toExpand=checkSubsystemForInternalPaths(subsysH)
    toExpand=false;
    ss=Simulink.SubsystemType(subsysH);

    if ss.isVirtualSubsystem()||...
        ss.isActionSubsystem()||...
        ss.isEnabledAndTriggeredSubsystem()||...
        ss.isEnabledSubsystem()||...
        ss.isForIteratorSubsystem()||...
        ss.isFunctionCallSubsystem()||...
        ss.isTriggeredSubsystem()||...
        ss.isWhileIteratorSubsystem()||...
        ss.isResettableSubsystem()||...
        (ss.isAtomicSubsystem()&&...
        ~ss.isStateflowSubsystem()&&...
        ~ss.isInitTermOrResetSubsystem()&&...
        ~ss.isPhysmodSubsystem()&&...
        ~ss.isVariantSubsystem()&&...
        ~ss.isIteratorSubsystem()&&...
        ~Sldv.ComputeObservable.isVerificationSubSystem(subsysH)...
        )

        toExpand=true;
    end


end
