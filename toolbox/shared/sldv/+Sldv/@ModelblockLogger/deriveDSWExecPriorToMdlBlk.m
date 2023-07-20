function globalDsmData=deriveDSWExecPriorToMdlBlk(mdlBlkH,rootMdlH,refMdlToMdlBlk,globalRefSig)






    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


    dsmMap=containers.Map('KeyType','char','ValueType','any');
    globalDsmData=struct('varsUsage',[],'dsmMap',dsmMap);

    referencedModelName=get_param(mdlBlkH,'ModelName');
    refmodelH=get_param(referencedModelName,'Handle');


    globalVars=Sldv.xform.RepMdlRefBlkTreeNode.genReferencedVars(rootMdlH,...
    'global',true,false,false,'on');


    refMdlVars=Sldv.xform.RepMdlRefBlkTreeNode.genReferencedVars(refmodelH,...
    'global',true,false,false,'on');



    globalVars=intersect(globalVars,refMdlVars);
    globalVars=removeNonDsmSigs(globalVars,globalRefSig);

    if isempty(globalVars)
        return;
    end

    ssVal=getSortedValue(mdlBlkH,refMdlToMdlBlk,rootMdlH);

    for n=1:length(globalVars)



        dswBlkH=find_system(globalVars(n).Users,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreWrite');
        dswBlkH=cellfun(@(c)get_param(c,'handle'),dswBlkH);
        priorWriters=[];
        pWSortVal=[];
        idx=1;
        for m=1:length(dswBlkH)
            thisSortVal=getSortedValue(dswBlkH(m),refMdlToMdlBlk,rootMdlH);
            if thisSortVal<ssVal
                priorWriters(idx)=dswBlkH(m);%#ok<AGROW>
                pWSortVal(idx)=thisSortVal;%#ok<AGROW>
                idx=idx+1;
            end
        end

        [~,sidx]=sort(pWSortVal,'descend');
        dsmMap(globalVars(n).Name)=priorWriters(sidx);
    end
    globalDsmData.varsUsage=globalVars;
    globalDsmData.dsmMap=dsmMap;

    function globalVars=removeNonDsmSigs(globalVars,globalRefSig)
        remIdx=[];
        for i=1:length(globalVars)
            if~ismember(globalVars(i).Name,globalRefSig)
                remIdx=[remIdx,i];
            end
        end
        globalVars(remIdx)=[];
    end
end

function sVal=getSortedValue(blkH,refMdlToMdlBlk,rootMdlH)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    thisObj=get_param(blkH,'Object');
    idx=1;
    while thisObj.Handle~=rootMdlH






        thisHdl=thisObj.Handle;
        if isa(thisObj,'Simulink.BlockDiagram')
            thisHdl=refMdlToMdlBlk(thisHdl);
            thisObj=get_param(thisHdl,'Object');
        end
        parentObj=get_param(thisObj.getCompiledParent,'Object');
        if isa(parentObj,'Simulink.SubSystem')...
            &&strcmp(parentObj.IsSubsystemVirtual,'on')
            parentObj=get_param(parentObj.getCompiledParent,'Object');
        end
        if thisObj.isSynthesized
            thisObj=parentObj;
            continue;
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
