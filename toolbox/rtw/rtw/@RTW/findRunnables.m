function hdls=findRunnables(ctxt)




    hdls=[];

    blockList=find_system(ctxt,'SearchDepth',...
    1,'LookUnderMasks','all','FollowLinks','on');
    for i=1:length(blockList)
        ssBlkH=blockList(i);
        if ssBlkH~=ctxt&&strcmp(get_param(ssBlkH,'BlockType'),'SubSystem')
            if strcmpi(l_checkTriggerType(ssBlkH),'function-call')
                hdls=[hdls,ssBlkH];
            elseif strcmpi(get_param(ssBlkH,'Virtual'),'on')
                ssHdls=RTW.findRunnables(ssBlkH);
                hdls=[hdls,ssHdls];
            end
        end
    end

    function triggerType=l_checkTriggerType(ssBlkH)
        triggerType='Unknown';
        blockList=find_system(ssBlkH,'SearchDepth',1,'LookUnderMasks','all',...
        'FollowLinks','on');
        for i=1:length(blockList)
            blkH=blockList(i);
            if strcmp(get_param(blkH,'BlockType'),'TriggerPort')
                triggerType=get_param(blkH,'TriggerType');
                return;
            end
        end

