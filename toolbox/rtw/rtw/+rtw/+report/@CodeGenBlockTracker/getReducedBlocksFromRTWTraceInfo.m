function reducedBlocks=getReducedBlocksFromRTWTraceInfo(~,rtwTraceInfo)



    tmp_registry=rtwTraceInfo.getRegistry;
    len=length(tmp_registry);

    emptySIDs=cell(len,1);
    reducedBlocks=struct('sid',emptySIDs,'comment','');
    n=0;
    reasonMap=rtwTraceInfo.getBlockReductionReasons;
    for k=1:len
        if~isempty(tmp_registry(k).location)
            continue
        end
        n=n+1;
        reducedBlocks(n).sid=tmp_registry(k).sid;
        [~,reducedBlocks(n).comment]=rtwTraceInfo.getReason(reasonMap,tmp_registry(k));
    end

    reducedBlocks=reducedBlocks(1:n);
end


