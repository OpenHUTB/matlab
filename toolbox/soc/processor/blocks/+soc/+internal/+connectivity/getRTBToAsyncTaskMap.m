function theMap=getRTBToAsyncTaskMap(topMdl,tskMgrBlk)




    import soc.internal.connectivity.*

    theMap=containers.Map('KeyType','char',...
    'ValueType','double');
    connectedBlock=getModelConnectedToTaskManager(tskMgrBlk);

    if isequal(get_param(connectedBlock,'BlockType'),'ModelReference')
        refMdlName=get_param(connectedBlock,'ModelName');


        rtbs=find_system(refMdlName,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on',...
        'BlockType','RateTransition');
        for idx=1:numel(rtbs)
            pc=get_param(rtbs{idx},'PortConnectivity');
            for j=1:numel(pc)
                blk=[];
                if~isempty(pc(j).DstBlock)
                    blk=pc(j).DstBlock;
                    break;
                end
            end
            assert(~isempty(blk),'Unconnected Rate Transition block');
            if isequal(get_param(blk,'BlockType'),'Terminator')
                continue;
            end
            st=get_param(blk,'CompiledSampleTime');
            if~iscell(st)
                if st(1)>0,continue;end
            else
                if st{1}(1)>0,continue;end
            end
            taskName=getTaskNameDrivingFcnCallSubs(topMdl,blk);
            theMap(taskName)=get_param(rtbs{idx},'Handle');
        end
    end
end
