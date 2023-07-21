
function blk_list=getBlockList(sys)
    mgrsess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    blk_list=getList(sys);
    for i=1:numel(blk_list)

        blk_list(i)=slci.internal.getOrigRootIOPort(blk_list(i),'Outport');
    end
    recurse=true;
    while(recurse)
        recurse=false;
        new_list=[];
        paramSampleTime_outport_list=[];
        implicit_input_list=[];
        for i=1:numel(blk_list)
            obj=get_param(blk_list(i),'Object');

            isExcluded=needToExclude(obj);
            if~isExcluded
                synthesizedInlinedSubystem=...
                strcmpi(get_param(blk_list(i),'Type'),'Block')&&...
                strcmpi(get_param(blk_list(i),'BlockType'),'SubSystem')&&...
                obj.isSynthesized&&...
                strcmpi(slci.internal.getSubsystemType(obj),'atomic');
                if synthesizedInlinedSubystem&&...
                    ~isForEachCoreSubsys(sys,blk_list(i))


                    blks=getList(blk_list(i));
                    new_list=[new_list;blks];%#ok
                    recurse=true;
                elseif isOutportWithParamSampleTime(blk_list(i))
                    paramSampleTime_outport_list=[paramSampleTime_outport_list;blk_list(i)];
                elseif strcmpi(get_param(blk_list(i),'BlockType'),'ForEachSliceSelector')
                    implicit_input_list=[implicit_input_list;blk_list(i)];
                else
                    new_list=[new_list;blk_list(i)];%#ok
                end
            end
        end
        blk_list=[implicit_input_list;new_list;paramSampleTime_outport_list];
    end


    rootOutportHandles=slci.internal.getRootOutportList(sys);

    for i=1:numel(rootOutportHandles)
        if isempty(find(blk_list==rootOutportHandles(i)))
            blk_list=[blk_list;rootOutportHandles(i)];
        end
    end

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

function blk_list=getList(sys)
    obj=get_param(sys,'Object');
    blk_list=obj.SortedList;


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
            blk_list=[blk_list;outports];
        end
    end

    grounds=getGrounds(obj,sys);
    blk_list=[grounds;blk_list];
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


                ssSortedList=obj.getSortedList;
                hasValidOutport=any(ssSortedList==srcOfOutport(1));
            end

            if~connectedToMerge&&hasValidOutport
                out_list=[out_list;allBlocks(i)];%#ok
            end
        end
    end
end


function in_list=getInports(obj)
    in_list=[];
    allBlocks=obj.getCompiledBlockList;
    for i=1:numel(allBlocks)
        blk_type=get_param(allBlocks(i),'BlockType');
        switch blk_type
        case 'Inport'
            in_list=[in_list;allBlocks(i)];%#ok
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


function ground_list=getGrounds(obj,NvSS)
    ground_list=[];
    allBlocks=obj.getCompiledBlockList;
    for i=1:numel(allBlocks)
        blk=allBlocks(i);
        blk_type=get_param(blk,'BlockType');
        bObj=get_param(blk,'Object');
        switch blk_type
        case 'SubSystem'
            if isVirtualSS(blk)
                sub_ground_list=getGrounds(bObj,NvSS);
                ground_list=[ground_list;sub_ground_list];%#ok
            end
        case 'Ground'
            if~isViewerGround(bObj)
                ground_list=[ground_list;blk];%#ok
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


function result=isOutportWithParamSampleTime(blk)
    result=false;
    if strcmpi(get_param(blk,'BlockType'),'Outport')
        sample_time=slci.internal.SampleTime(get_param(blk,'CompiledSampleTime'));
        if sample_time.isParameter||sample_time.isConstant
            result=true;
        end
    end
end

