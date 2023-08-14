function[srcBlk,srcType]=getEventSourceBlockForTask(hBlk,taskName)




    import soc.internal.connectivity.*

    srcBlk=[];
    srcType=[];

    if~ishandle(hBlk)
        hBlk=get_param(hBlk,'Handle');
    end
    blks=find_system(hBlk,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'BlockType','Inport');
    expectedTskEvtPortName=[taskName,'Event'];
    idx=arrayfun(@(x)locIsBlockNameMatching(x,expectedTskEvtPortName),blks);
    evtPortBlk=blks(idx);
    srcBlk=findEventSourceBlockForTask(evtPortBlk);
    if~isempty(srcBlk)
        srcType=locGetBlockType(srcBlk);
    end
end


function res=locIsBlockNameMatching(blk,nameToMatch)
    res=isequal(get_param(blk,'Name'),nameToMatch);
end


function type=locGetBlockType(blk)
    refBlock=get_param(blk,'ReferenceBlock');
    switch(refBlock)
    case{'socmemlib/Memory Channel','socmemlib/AXI4-Stream to Software','socmemlib/Software to AXI4-Stream'}
        type='Stream';
    case{'prociodatalib/IO Data Source','prociodatalib/IO Data Sink'}
        type=get_param(blk,'DeviceType');
    otherwise
        type=get_param(blk,'MaskType');
    end
end
