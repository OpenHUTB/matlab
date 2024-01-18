function[offset,cnt,groupReqCnt]=sigbuilder_group_reqs(obj,groupIdx)

    offset=1;
    cnt=0;
    groupReqCnt=[];

    if rmisl.is_signal_builder_block(obj)
        blkInfo=rmisl.sigb_get_info(obj);
        if(isfield(blkInfo,'groupCnt')&&~isempty(blkInfo.groupCnt)&&...
            isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt))

            groupReqCnt=blkInfo.groupReqCnt;

            reqOffset=[1,1+cumsum(groupReqCnt(1:(end-1)))];
            offset=reqOffset(groupIdx);
            cnt=groupReqCnt(groupIdx);
        else
            if nargout==3
                [~,sbD]=signalbuilder(obj);
                if~iscell(sbD)
                    sbD={sbD};
                end
                groupCnt=size(sbD,2);
                groupReqCnt=zeros(1,groupCnt);
            end
        end
    end

