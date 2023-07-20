














function isBlkAdded=addCovDependency(obj,destBlockH,inportNo,srcBlockH,srcPortNo)




    isBlkAdded=false;



    destBlkName=obj.getSID(destBlockH);
    len=length(obj.CovDependency(end).Dependency);
    if len
        [found,idx]=find(strcmp({obj.CovDependency(end).Dependency.BlkName},...
        destBlkName));
    end


    if~len||isempty(found)
        idx=createNewDependency(obj,destBlockH,destBlkName);
        isBlkAdded=true;

        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","addCovDependency",...
        "Added dependency for ::"+get_param(destBlockH,"Name"));
    end




    if srcPortNo==0
        return
    end



    srcName=obj.getSID(srcBlockH);
    currSrcBlks={obj.CovDependency(end).Dependency(idx).blkInputDependency(inportNo).SrcBlk};
    currPortBlks=obj.CovDependency(end).Dependency(idx).blkInputDependency(inportNo).SrcPort;
    [found,srcIdx]=find(strcmp(currSrcBlks{1:end},srcName));

    if isempty(found)||...
        isempty(find(currPortBlks{srcIdx},srcPortNo))

        obj.CovDependency(end).Dependency(idx).blkInputDependency(inportNo).SrcBlk{end+1}=srcName;
        obj.CovDependency(end).Dependency(idx).blkInputDependency(inportNo).SrcPort{end+1}=srcPortNo;

        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","addCovDependency",...
        "SourceInfo::SrcName::"+get_param(srcBlockH,"Name")+"::SrcPortNo::"+srcPortNo);
    end
    srcBlkName=obj.getSID(srcBlockH);
    [found,srcIdx]=find(strcmp({obj.CovDependency(end).Dependency.BlkName},srcBlkName));

    if found
        destInfo=obj.CovDependency(end).Dependency(srcIdx).OutportInfo{srcPortNo,1};

        if isempty(destInfo)
            destInfo=struct('Id',idx,'inport',inportNo);
        else
            entryExists=false;
            for i=1:length(destInfo)
                if destInfo(i).Id==idx&&destInfo(i).inport==inportNo
                    entryExists=true;
                end
            end
            if entryExists==false
                destInfo(end+1)=struct('Id',idx,'inport',inportNo);
            end
        end
        obj.CovDependency(end).Dependency(srcIdx).OutportInfo{srcPortNo,1}=destInfo;

    end

end

function idx=createNewDependency(obj,destBlockH,destBlkName)


    obj.CovDependency(end).Dependency(end+1).BlkName=destBlkName;
    idx=length(obj.CovDependency(end).Dependency);

    portHs=get_param(destBlockH,'PortHandles');
    inlen=length(portHs.Inport)+...
    length(portHs.Enable)+...
    length(portHs.Trigger)+...
    length(portHs.State)+...
    length(portHs.Ifaction)+...
    length(portHs.Reset);
    outlen=length(portHs.Outport);
    if outlen==0





        customTestObjective=Sldv.ComputeObservable.isCustomAuthoredTestObjective(destBlockH,obj.ModelName);
        if customTestObjective
            outlen=1;
        end
    end

    if inlen>0
        obj.CovDependency(end).Dependency(idx).blkInputDependency(1:inlen)=...
        struct('SrcBlk',[],'SrcPort',[]);
    else
        if strcmp(get_param(destBlockH,'BlockType'),'DataStoreRead')
            obj.CovDependency(end).Dependency(idx).blkInputDependency(1)=...
            struct('SrcBlk',[],'SrcPort',[]);
        end
    end



    if inlen>0
        obj.CovDependency(end).Dependency(idx).blkEffectsOnSpec(1:inlen)=...
        struct('blkList',[]);
    else
        if strcmp(get_param(destBlockH,'BlockType'),'DataStoreRead')
            obj.CovDependency(end).Dependency(idx).blkEffectsOnSpec(1)=...
            struct('blkList',[]);
        end
    end

    obj.CovDependency(end).Dependency(idx).blkOutputSpec(1:outlen)=...
    struct('OutputObjectives',[],'UsedInCompose',false,'DestBlks',[],'ObjectiveObsPoint',[]);
    obj.CovDependency(end).Dependency(idx).controlObjective=[];
    obj.CovDependency(end).Dependency(idx).default_propagation_dest=[];
    obj.CovDependency(end).Dependency(idx).num_paths=0;
    obj.CovDependency(end).Dependency(idx).numInports=inlen;

    obj.CovDependency(end).Dependency(idx).networkSpec=struct('nwCompSpecId',-1,'nwCompSpec',[]);
    obj.CovDependency(end).Dependency(idx).nonMaskSpec(1:inlen)=struct('nonMaskSpecId',-1,'nonMaskSpec',[],'Used',false);
    if~obj.isGeneratedSID(destBlkName)
        obj.CovDependency(end).Dependency(idx).detectionSites=struct('detectionPoint',destBlkName,'Port',[]);
    else
        obj.CovDependency(end).Dependency(idx).detectionSites=struct([]);
    end
    obj.CovDependency(end).Dependency(idx).numOutports=outlen;
    obj.CovDependency(end).Dependency(idx).OutportInfo=cell(outlen,1);
    obj.CovDependency(end).Dependency(idx).outportConnectedToStopBlock=cell(outlen,1);
    obj.CovDependency(end).Dependency(idx).outportPotDetSite=cell(outlen,1);
    isSrcConditionInputDependent=checkIfSourceConditionOnInputOrOutputPorts(destBlockH);
    if isSrcConditionInputDependent
        srcSpecLen=inlen;
    else
        srcSpecLen=outlen;
    end
    obj.CovDependency(end).Dependency(idx).sourceSpec(1:srcSpecLen)=struct('sourceSpecId',[],'sourceSpec',[]);
end

function isSrcConditionInputDependent=checkIfSourceConditionOnInputOrOutputPorts(blkH)

    [~,~,callPerPort]=sldvprivate('getAccessInfoForObserveFunction',blkH);
    if callPerPort==1||callPerPort==0
        isSrcConditionInputDependent=true;
    else
        isSrcConditionInputDependent=false;
    end
end


