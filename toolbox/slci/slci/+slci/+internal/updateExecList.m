
function out=updateExecList(sys,execList)
    execMap=populateExecMapFromExecList(execList);


    mdl=Simulink.ID.getModel(Simulink.ID.getSID(sys));
    isCEC=get_param(mdl,'ConditionallyExecuteInputs');
    if strcmpi(isCEC,'on')
        execMap=insertConditionallyExecutedContext(execMap,mdl);
    end

    outMap=execMap;

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    ssKeys=execMap.keys;
    for iSys=1:numel(ssKeys)
        values=execMap(ssKeys{iSys});
        stKeys=values.keys;

        fcnSubs=getSLFcnSubs(ssKeys{iSys});
        for iSt=1:numel(stKeys)
            aExecList=values(stKeys{iSt});
            period=stKeys{iSt};
            blk_list=getList(sys,aExecList,period);
            for i=1:numel(blk_list)

                blk_list(i)=slci.internal.getOrigRootIOPort(blk_list(i),'Outport');
            end
            for idx=1:numel(fcnSubs)

                if getTID(fcnSubs{idx})==period
                    blk_list(end+1)=fcnSubs{idx};
                end
            end
            recurse=true;
            while(recurse)
                recurse=false;
                new_list=[];
                for i=1:numel(blk_list)
                    obj=get_param(blk_list(i),'Object');

                    isExcluded=needToExclude(obj);
                    if~isExcluded
                        synthesizedInlinedSubystem=...
                        strcmpi(get_param(blk_list(i),'Type'),'Block')&&...
                        strcmpi(get_param(blk_list(i),'BlockType'),'SubSystem')&&...
                        obj.isSynthesized&&...
                        strcmpi(slci.internal.getSubsystemType(obj),'atomic');
                        if synthesizedInlinedSubystem...
                            &&~isForEachCoreSubsys(sys,blk_list(i))


                            ssExecList=execMap(blk_list(i));
                            ssTids=ssExecList.keys;
                            if any(period==cell2mat(ssTids))
                                ssExecList=ssExecList(period);
                                blks=getList(blk_list(i),ssExecList,period);
                                new_list=[new_list,blks];%#ok
                            end
                            recurse=true;
                        else
                            new_list=[new_list,blk_list(i)];%#ok
                        end
                    end
                end
                blk_list=new_list;
            end
            outMap=updateList(ssKeys{iSys},stKeys{iSt},execMap,blk_list);
        end
    end

    out=map2cell(outMap);
end


function out=isForEachCoreSubsys(parentSys,sys)
    out=false;
    if strcmpi(get_param(sys,'Name'),'CoreSubsys')
        if strcmpi(get_param(parentSys,'Type'),'Block')&&...
            strcmpi(get_param(parentSys,'BlockType'),'SubSystem')
            parentSysOb=get_param(parentSys,'Object');
            out=strcmpi(slci.internal.getSubsystemType(parentSysOb),'ForEach');
        end
    end
end


function flag=needToExclude(obj)
    flag=false;
    if strcmpi(obj.Type,'block')




        if~any(strcmpi(obj.IOType,{'none','siggen'}))
            flag=true;
            return;
        end




        if obj.isSynthesized&&...
            any(strcmpi(obj.BlockType,{'ToAsyncQueueBlock','ToWorkspace'}))
            flag=true;
            return;
        end


        if obj.isSynthesized&&...
            strcmpi(slci.internal.getSubsystemType(obj),'Function-call')&&...
            isempty(obj.PortHandles.Trigger)
            flag=true;
            return;
        end

        blkHandle=obj.Handle;
        if isRootInport(blkHandle)
            flag=true;
            return;
        end




        if~isempty(strfind(obj.Name,'sfcn_inserted_server'))
            flag=true;
            return;
        end

    end

end

function blk_list=getList(sys,execList,period)
    blk_list=execList;

    obj=get_param(sys,'Object');


    if strcmpi(get_param(sys,'type'),'block')&&...
        ~obj.isSynthesized&&...
        strcmpi(get_param(sys,'type'),'block')
        ssType=slci.internal.getSubsystemType(obj);
        if strcmpi(ssType,'enable')||...
            strcmpi(ssType,'Function-call')||...
            strcmpi(ssType,'Trigger')||...
            strcmpi(ssType,'Action')||...
            strcmpi(ssType,'ForEach')||...
            strcmpi(ssType,'Iterator')||...
            strcmpi(ssType,'While')||...
            strcmpi(ssType,'For')
            outports=getOutports(obj);
            for i=1:numel(outports)
                tid=getTID(outports(i));
                if(tid==period)
                    blk_list=[blk_list,outports(i)];%#ok
                end
            end
        end
    end

    grounds=getGrounds(obj,sys,period);
    blk_list=[grounds,blk_list];
end

function out_list=getOutports(obj)
    out_list=[];
    allBlocks=obj.getCompiledBlockList;
    for i=1:numel(allBlocks)
        blk_type=get_param(allBlocks(i),'BlockType');
        switch blk_type
        case 'Outport'
            connectedToMerge=false;
            parentSS=get_param(allBlocks(i),'Parent');
            parentPortNumber=str2double(get_param(allBlocks(i),'Port'));
            dsts=slci.internal.getActualDst(parentSS,parentPortNumber-1);
            for dstIdx=1:size(dsts,1)
                dstBlk=dsts(dstIdx,1);
                if strcmpi(get_param(dstBlk,'BlockType'),'merge')
                    connectedToMerge=true;
                end
            end







            srcOfOutport=slci.internal.getActualSrc(allBlocks(i),0);

            hasValidOutport=1;
            if isempty(dsts)


                ssSortedList=obj.SortedList;
                hasValidOutport=any(ssSortedList==srcOfOutport(1));
            end

            if~connectedToMerge&&hasValidOutport
                out_list=[out_list;allBlocks(i)];%#ok
            end
        end
    end
end


function ss=nearestNvSS(blk)
    blkObj=get_param(blk,'Object');
    blk=blkObj.getCompiledParent;
    while strcmpi(get_param(blk,'type'),'Block')&&isVirtualSS(blk)
        blkObj=get_param(blk,'Object');
        blk=blkObj.getCompiledParent;
    end
    ss=blk;
end


function ground_list=getGrounds(obj,NvSS,period)
    ground_list=[];
    allBlocks=obj.getCompiledBlockList;
    for i=1:numel(allBlocks)
        blk=allBlocks(i);
        blk_type=get_param(blk,'BlockType');
        bObj=get_param(blk,'Object');
        switch blk_type
        case 'SubSystem'
            if isVirtualSS(blk)
                sub_ground_list=getGrounds(bObj,NvSS,period);
                ground_list=[ground_list;sub_ground_list];%#ok
            end
        case 'Ground'
            if(nearestNvSS(blk)==NvSS)&&~isViewerGround(bObj)
                tid=getTID(blk);
                if any(tid==period)
                    ground_list=[ground_list,blk];%#ok
                end
            end
        end
    end
end




function result=isViewerGround(bObj)
    result=false;
    if strcmp(bObj.BlockType,'Ground')&&bObj.isSynthesized
        origBlkHdl=bObj.getTrueOriginalBlock();
        result=...
        strcmp(get_param(origBlkHdl,'Type'),'block')...
        &&~strcmp(get_param(origBlkHdl,'IOType'),'none');
    end
end


function result=isVirtualSS(blk)
    if strcmpi(get_param(blk,'BlockType'),'SubSystem')
        ssType=slci.internal.getSubsystemType(get_param(blk,'Object'));
        result=strcmpi(ssType,'virtual')...
        ||strcmpi(get_param(blk,'virtual'),'on');
    else
        result=false;
    end
end

function result=isRootInport(blk)
    result=strcmpi(get_param(blk,'BlockType'),'Inport')&&...
    strcmpi(get_param(get_param(blk,'Parent'),'Type'),'block_diagram');
end

function out=populateExecMapFromExecList(aList)
    out=containers.Map('KeyType','double','ValueType','any');
    for i=1:numel(aList)
        key=aList{i}{1};
        value=containers.Map('KeyType','double','ValueType','any');
        for j=1:numel(aList{i}{2})
            stKey=aList{i}{2}{j}{1};
            value(stKey)=aList{i}{2}{j}{2};
        end
        out(key)=value;
    end
end

function out=updateList(ss,st,aMap,blklist)
    out=aMap;
    value=out(ss);
    value(st)=blklist;
end

function out=map2cell(aMap)
    ssKeys=aMap.keys;
    ssCells=cell(numel(ssKeys),1);
    for i=1:numel(ssKeys)
        ssCell=cell(1,2);
        ssCell{1}=ssKeys{i};
        values=aMap(ssKeys{i});
        stKeys=values.keys;
        stCell=cell(numel(stKeys),1);
        for j=1:numel(stKeys)
            aStCell=cell(1,2);
            aStCell{1}=stKeys{j};
            aStCell{2}=values(stKeys{j});
            stCell{j}=aStCell;
        end
        ssCell{2}=stCell;
        ssCells{i}{1}=ssCell;
    end
    out=ssCells;
end


function out=getTID(blk)
    out=[];
    compiledSampleTime=slci.internal.deriveSampleTime(blk);

    if(numel(compiledSampleTime)==1)
        s=slci.internal.SampleTime(compiledSampleTime{1});
        if~s.isDiscrete()
            out=0;
            return;
        end
    end
    mdlH=Simulink.ID.getModel(Simulink.ID.getSID(blk));

    tsTable=slci.internal.getModelSampleTimes(mdlH);

    for i=1:numel(compiledSampleTime)
        sampleTimeObj=slci.internal.SampleTime(compiledSampleTime{i});
        tid=slci.internal.tsToTid(sampleTimeObj,tsTable);
        out=[out,tid];%#ok
    end
end



function out=insertConditionallyExecutedContext(execMap,mdl)
    out=execMap;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    mdlObj=get_param(mdl,'Object');
    cecInputTree=mdlObj.getCondInputTree;
    if~isempty(cecInputTree)
        for i=1:numel(cecInputTree)
            c=cecInputTree(i);

            cecHandle=c.cecHandle;
            if(cecHandle==-1)||(c.nCondExecBlks==0)


                continue;
            else

                out=insertCECBlockInExecMap(execMap,c);
            end
        end
    end
end

function out=insertCECBlockInExecMap(execMap,ceContext)
    out=execMap;
    tid=getTID(ceContext.owner);
    if numel(tid)==1
        movedBlocks=[];
        if~isempty(ceContext.blocksMovedToCECInputSide)
            movedBlocks=get_param(ceContext.cecHandle,'sortedlist');
            movedBlocks=movedBlocks';
        elseif~isempty(ceContext.blocksMovedToCECOutputSide)
            movedBlocks=ceContext.blocksMovedToCECOutputSide;
        end


        tmpMap=containers.Map('KeyType','double','ValueType','any');
        tmpMap(tid)=movedBlocks;
        out(ceContext.cecHandle)=tmpMap;


        parentSID=Simulink.ID.getSimulinkParent(...
        Simulink.ID.getSID(ceContext.owner));
        parentHandle=Simulink.ID.getHandle(parentSID);
        while(~out.isKey(parentHandle))
            parentSID=Simulink.ID.getSimulinkParent(parentSID);
            parentHandle=Simulink.ID.getHandle(parentSID);
        end
        sysMap=out(parentHandle);
        blkList=sysMap(tid);
        insertIndex=-1;
        for i=1:numel(blkList)

            if isequal(blkList(i),ceContext.owner)
                if~isempty(ceContext.blocksMovedToCECInputSide)
                    insertIndex=i-1;
                elseif~isempty(ceContext.blocksMovedToCECOutputSide)
                    insertIndex=i+1;
                end
                break;
            end
        end


        if insertIndex==0
            blkList=[ceContext.cecHandle,blkList];
        elseif insertIndex==(numel(blkList)+1)
            blkList=[blkList,ceContext.cecHandle];
        elseif insertIndex>1
            blkList=[blkList(1:insertIndex)...
            ,ceContext.cecHandle...
            ,blkList(insertIndex+1:end)];
        end

        sysMap(tid)=blkList;
        out(parentHandle)=sysMap;
    end
end


function out=getSLFcnSubs(sys)
    out={};


    subs=find_system(sys,'SearchDepth',1,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','SubSystem');
    for i=1:numel(subs)
        subObj=get_param(subs(i),'Object');
        if strcmpi(slci.internal.getSubsystemType(subObj),'simulinkfunction')&&...
            subs(i)~=sys
            out{end+1}=subs(i);%#ok
        end
    end
end
