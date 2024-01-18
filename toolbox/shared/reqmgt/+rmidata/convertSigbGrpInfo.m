function groups=convertSigbGrpInfo(varargin)

    if isstruct(varargin{1})

        blkInfo=varargin{1};
        expectedReqCnt=varargin{2};
        if isfield(blkInfo,'groupCnt')&&~isempty(blkInfo.groupCnt)&&...
            isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt)
            groups=groupReqCntToGroupIndex(blkInfo.groupReqCnt,expectedReqCnt);
            if any(groups==0)
                warning(message('Slvnv:reqmgt:convertSigbGrpInfo:UnmatchedGroupsInfo',get_param(blkInfo.blockH,'Name')));
            end
        else
            groups=[];
        end

    else

        if nargin==1

            groupReqCnt=varargin{1};

            expectedReqCnt=sum(groupReqCnt);

            groups=groupReqCntToGroupIndex(groupReqCnt,expectedReqCnt);
            if any(groups==0)&&rmisl.is_signal_builder_block(gcb)
                warning(message('Slvnv:reqmgt:convertSigbGrpInfo:UnmatchedGroupsInfo',get_param(gcb,'Name')));
            end
        else
            total_groups=varargin{1};
            groupsIdx=varargin{2};
            groups=zeros(1,total_groups);
            for j=1:total_groups
                groups(j)=sum(groupsIdx==j);
            end
        end
    end
end


function groups=groupReqCntToGroupIndex(groupReqCnt,expectedReqCnt)
    nonEmpty=find(groupReqCnt);
    groups=zeros(expectedReqCnt,1);
    offset=1;
    for j=1:length(nonEmpty)
        pos=nonEmpty(j);
        cnt=groupReqCnt(pos);
        groups(offset:offset+cnt-1)=pos;
        offset=offset+cnt;
    end
end


