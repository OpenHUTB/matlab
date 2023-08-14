function dsmMap=deriveDSWExecPriorToSubsystem(sysH)











    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


    dsmMap=containers.Map('KeyType','char','ValueType','any');

    blkObj=get_param(sysH,'Object');
    dsmInfo=blkObj.getNeededDSMemBlks();
    if isempty(dsmInfo)
        return;
    end
    ssVal=getSortedValue(sysH);

    for n=1:length(dsmInfo)

        dsmBlkObj=get_param(dsmInfo(n).Handle,'Object');
        dsRW=dsmBlkObj.DSReadWriteBlocks;


        dswBlkH=find_system([dsRW.handle],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreWrite');
        priorWriters=[];
        pWSortVal=[];
        idx=1;
        for m=1:length(dswBlkH)
            thisSortVal=getSortedValue(dswBlkH(m));
            if thisSortVal<ssVal
                priorWriters(idx)=dswBlkH(m);%#ok<AGROW>
                pWSortVal(idx)=thisSortVal;%#ok<AGROW>
                idx=idx+1;
            end
        end

        [~,sidx]=sort(pWSortVal,'descend');

        DataStoreName=get_param(dsmInfo(n).Handle,'DataStoreName');
        dsmMap(DataStoreName)=priorWriters(sidx);
    end
end

function sVal=getSortedValue(blkH)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    thisObj=get_param(blkH,'Object');
    idx=1;
    while~isa(thisObj,'Simulink.BlockDiagram')






        thisHdl=thisObj.Handle;
        parentObj=get_param(thisObj.getCompiledParent,'Object');
        if isa(parentObj,'Simulink.SubSystem')...
            &&strcmp(parentObj.IsSubsystemVirtual,'on')
            parentObj=get_param(parentObj.getCompiledParent,'Object');
        end
        sList=parentObj.getSortedList;
        thisRank=find(sList==thisHdl);
        assert(~isempty(thisRank))
        rankVec(idx)=thisRank;%#ok<AGROW>
        numList(idx)=length(sList);%#ok<AGROW>
        idx=idx+1;
        thisObj=parentObj;
    end


    rankVec=rankVec-1;
    coef=1;
    s=0;
    for n=length(rankVec):-1:1
        s(n)=coef*rankVec(n)/(numList(n));
        coef=coef/(numList(n));
    end
    sVal=sum(s);
end
