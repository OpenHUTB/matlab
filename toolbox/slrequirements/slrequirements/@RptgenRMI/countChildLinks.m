function info=countChildLinks(system)





    blkLoop=RptgenRMI.CBlockLoop;
    adSL=rptgen_sl.appdata_sl;
    adSL.Context='System';
    set(adSL,'CurrentSystem',system)
    childList=blkLoop.loop_getLoopObjects('include_all');
    if isempty(childList)
        info='None';
    else
        blkAll=rptgen_sl.csl_blk_loop;
        childAll=blkAll.loop_getLoopObjects();
        info=sprintf('%d out of %d',length(childList),length(childAll));
    end


