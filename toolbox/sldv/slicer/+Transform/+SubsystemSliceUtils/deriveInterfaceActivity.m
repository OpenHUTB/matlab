function[ssIOActivity,deadBlocks]=deriveInterfaceActivity(msObj,toRemove,deadBlocks)






    sliceSubSystemH=msObj.sliceSubSystemH;

    ph=get_param(sliceSubSystemH,'PortHandles');
    isMdlBlk=Simulink.SubsystemType.isModelBlock(sliceSubSystemH);
    useNewBackend=slfeature('NewSlicerBackend');
    if isMdlBlk
        sysH=get_param(get_param(sliceSubSystemH,'ModelName'),'Handle');
    else
        sysH=sliceSubSystemH;
    end

    Inport=true(1,length(ph.Inport));
    inBlkH=find_system(sysH,'FindAll','on',...
    'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
    'BlockType','Inport');
    inBlkShadowH=find_system(sysH,'FindAll','on',...
    'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
    'BlockType','InportShadow');
    inBlkH=[inBlkH;inBlkShadowH];

    for i=1:length(ph.Inport)
        thisInBlkH=inBlkH(strcmp(get(inBlkH,'Port'),num2str(i)));
        for j=1:length(thisInBlkH)
            Inport(i)=shouldRetainInBlk(thisInBlkH(j));
        end
    end

    if~any(Inport)


        Inport(1)=true;
    end
    thisSSIsStartingPoint=ismember(sliceSubSystemH,msObj.designInterests.blocks);

    Outport=true(1,length(ph.Outport));
    outBlkH=find_system(sysH,'FindAll','on',...
    'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
    'BlockType','Outport');
    for i=1:length(ph.Outport)
        Outport(i)=shouldRetainOutBlk(outBlkH(i),ph.Outport(i));
    end

    bobj=get_param(sliceSubSystemH,'Object');
    if isa(bobj,'Simulink.SubSystem')
        allDSMNamesOfSys=get_param([bobj.getNeededDSMemBlks.Handle],'DataStoreName');
        if ischar(allDSMNamesOfSys)
            allDSMNamesOfSys={allDSMNamesOfSys};
        end
        dsmIdx=strcmp(get(toRemove,'BlockType'),'DataStoreMemory');
        inactiveDSMName=get_param(toRemove(dsmIdx),'DataStoreName');
        activeDSMName=setdiff(allDSMNamesOfSys,inactiveDSMName);
    else
        inactiveDSMName=[];
        if isfield(msObj.globalDsmData,'dsmMap')
            dsmMap=msObj.globalDsmData.dsmMap;
            activeDSMName=dsmMap.keys;
        else
            activeDSMName=[];
        end
    end

    ssIOActivity.Outport=Outport;
    ssIOActivity.Inport=Inport;
    ssIOActivity.DataStoreName.Active=activeDSMName;
    ssIOActivity.DataStoreName.Inactive=inactiveDSMName;


    function yesno=shouldRetainInBlk(inBlkH)
        yesno=true;
        if useNewBackend
            yesno=~ismember(inBlkH,deadBlocks);
        else
            bobj=get(inBlkH,'Object');
            aDstIn=bobj.getActualDst;
            if~isempty(aDstIn)
                aDstInBH=get(aDstIn(:,1),'ParentHandle');
                if iscell(aDstInBH)
                    aDstInBH=cell2mat(aDstInBH);
                end
                if all(ismember(aDstInBH,toRemove))
                    yesno=false;
                end
            end
        end
    end

    function yesno=shouldRetainOutBlk(outBlkH,op)
        yesno=true;

        if useNewBackend
            yesno=~ismember(outBlkH,deadBlocks);
        else
            bobj=get(op,'Object');
            aDstOut=bobj.getActualDst;
            if~isempty(aDstOut)
                aDstOutBH=get(aDstOut(:,1),'ParentHandle');
                if iscell(aDstOutBH)
                    aDstOutBH=cell2mat(aDstOutBH);
                end
                if~thisSSIsStartingPoint&&~ismember(op,msObj.designInterests.signals)
                    if all(ismember(aDstOutBH,toRemove))
                        yesno=false;
                    end
                else





                    [~,delIdx]=ismember(aDstOutBH,deadBlocks);
                    if delIdx~=0
                        deadBlocks(delIdx)=[];
                    end
                end
            else
                if~thisSSIsStartingPoint

                    yesno=false;
                end
            end
            if isMdlBlk


                yesno=yesno||...
                msObj.shouldRetainMdlBlockOutport(outBlkH,deadBlocks);
            end
        end
    end
end