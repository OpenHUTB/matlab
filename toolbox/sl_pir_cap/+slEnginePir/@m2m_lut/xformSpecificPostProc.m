function errmsg=xformSpecificPostProc(m2mObj)



    errmsg=[];

    for lIdx=1:length(m2mObj.fBrokenLinks)
        set_param(m2mObj.fBrokenLinks{lIdx},'linkstatus','propagatehierarchy');
    end


    blks=keys(m2mObj.fTraceabilityMap);
    for bIdx=1:length(blks)
        linkstatus=get_param(blks{bIdx},'linkstatus');
        if strcmpi(linkstatus,'implicit')||strcmpi(linkstatus,'resolved')
            refBlk=get_param(blks{bIdx},'ReferenceBlock');
            m2mObj.fTraceabilityMap(refBlk)=[];
            mappedBlks=m2mObj.fTraceabilityMap(blks{bIdx});
            for bIdx2=1:length(mappedBlks)
                m2mObj.fTraceabilityMap(refBlk)=[m2mObj.fTraceabilityMap(refBlk)...
                ,{get_param(mappedBlks{bIdx2},'ReferenceBlock')}];
            end
            m2mObj.fTraceabilityMap.remove(blks{bIdx});
        end
    end
end

