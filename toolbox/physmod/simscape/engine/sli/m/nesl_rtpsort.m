function[rtpList,rtpWidths,rtpIndices]=nesl_rtpsort(paramInfo)






































    rtpList={};
    rtpWidths=[];
    rtpIndices=struct;


    [ids,wdths]=lRtpIds(paramInfo.logicals);
    rtpIndices.logicals=numel(rtpList)+(0:numel(ids)-1);
    rtpList=[rtpList,ids];
    rtpWidths=[rtpWidths,wdths];


    [ids,wdths]=lRtpIds(paramInfo.integers);
    rtpIndices.integers=numel(rtpList)+(0:numel(ids)-1);
    rtpList=[rtpList,ids];
    rtpWidths=[rtpWidths,wdths];


    [ids,wdths]=lRtpIds(paramInfo.indices);
    rtpIndices.indices=numel(rtpList)+(0:numel(ids)-1);
    rtpList=[rtpList,ids];
    rtpWidths=[rtpWidths,wdths];


    [ids,wdths]=lRtpIds(paramInfo.reals);
    rtpIndices.reals=numel(rtpList)+(0:numel(ids)-1);
    rtpList=[rtpList,ids];
    rtpWidths=[rtpWidths,wdths];


    pm_assert(numel(unique(rtpList))==numel(rtpList),...
    'RTP spans multiple types');

end



function[rtpIds,rtpWidths]=lRtpIds(paramInfo)



    if isempty(paramInfo)
        rtpIds={};
        rtpWidths=[];
        return
    end
    rtpIds=unique({paramInfo.path},'stable');
    rtpWidths=zeros(1,numel(rtpIds));


    infoPaths={paramInfo.path};
    infoIndices=[paramInfo.index];

    for i=1:numel(rtpIds)
        id=rtpIds{i};


        pick=strcmp(id,infoPaths);




        diffidx=diff([0,pick,0]);
        pm_assert((sum(diffidx==-1)==1)&&(sum(diffidx==1)==1),...
        'RTP elements interleaved');

        dim=paramInfo(find(pick,1)).dimension;


        pm_assert(isequal(infoIndices(pick),[0:prod(dim)-1]),...
        'RTP elements missing or not in order');%#ok

        for idx=find(pick)
            pm_assert(isequal(paramInfo(idx).dimension,dim),...
            'RTP listing inconsistent dimensions');
        end

        rtpWidths(i)=prod(dim);
    end
end
