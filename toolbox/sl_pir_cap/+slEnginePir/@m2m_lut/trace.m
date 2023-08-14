function blocks=trace(m2mObj,aBlk)



    clear_all_hilite;











    try
        aBlkName=getfullname(aBlk);
    catch
        aBlkName=aBlk;
    end

    linkstatus=get_param(aBlkName,'linkstatus');
    if strcmpi(linkstatus,'implicit')||strcmpi(linkstatus,'resolved')
        aBlkName=get_param(aBlkName,'ReferenceBlock');
    end

    if isKey(m2mObj.fTraceabilityMap,aBlkName)
        blocks=m2mObj.fTraceabilityMap(aBlkName);
        hilite_system(blocks);
    else
        blocks=[];
    end
end

function clear_all_hilite
    systems=find_system('type','block_diagram');
    for i=1:length(systems)
        set_param(systems{i},'HiliteAncestors','off');
    end
end
