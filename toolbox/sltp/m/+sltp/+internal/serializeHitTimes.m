function serializedHitTimes=serializeHitTimes(hitTimesCellArray,bdhandle)



    mdlName=get_param(bdhandle,'Name');

    serializedHitTimes={};
    if isempty(hitTimesCellArray)
        return;
    end

    [m,n]=size(hitTimesCellArray);



    assert(iscell(hitTimesCellArray));
    assert(n==2);
    assert(numel(unique(hitTimesCellArray(:,1)))==m);

    iHitTimes=1;
    for i=1:m
        partitionName=hitTimesCellArray{i,1};
        partitionLink=message(...
        'SimulinkPartitioning:General:PartitionLink',...
        mdlName,partitionName).getString;
        try
            hitTimes=sltp.internal.evalStringWithWorkspaceResolution(bdhandle,...
            false,hitTimesCellArray{i,2});
        catch E
            throw(MSLException([],message(...
            'SimulinkPartitioning:General:InvalidHitTimesEval',...
            hitTimesCellArray{i,2},partitionLink)));
        end

        if(isempty(hitTimes))
            continue;
        end

        sltp.internal.verifyHitTimes(hitTimes,partitionLink);

        [time,nHits]=loc_convert_hit_times(hitTimes);
        serializedHitTimes{iHitTimes}.SignalName=partitionName;%#ok<AGROW>
        serializedHitTimes{iHitTimes}.Time=time;%#ok<AGROW>
        serializedHitTimes{iHitTimes}.Data=nHits;%#ok<AGROW>
        serializedHitTimes{iHitTimes}.SignalMode=2;%#ok<AGROW>
        iHitTimes=iHitTimes+1;
    end
end

function[time,nHits]=loc_convert_hit_times(hitTimes)
    assert(...
    ~isempty(hitTimes)&&...
    isa(hitTimes,'double')&&...
    (iscolumn(hitTimes)||isrow(hitTimes))&&...
    all(diff(hitTimes)>=0)...
    );
    time=hitTimes(1);
    nHits=1;
    for idx=2:length(hitTimes)
        if hitTimes(idx)==hitTimes(idx-1)
            nHits(end)=nHits(end)+1;
        else
            time=[time;hitTimes(idx)];%#ok<AGROW>
            nHits=[nHits;1];%#ok<AGROW>
        end
    end
end

