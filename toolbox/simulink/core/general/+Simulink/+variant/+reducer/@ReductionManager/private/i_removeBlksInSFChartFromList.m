



function blks=i_removeBlksInSFChartFromList(blks)



    if iscell(blks)
        func=@cellfun;
    else
        func=@arrayfun;
    end

    function status=isStateflowBlock(x)
        status=false;
        p=get_param(x,'Parent');
        if isempty(p)
            return;
        end
        status=slprivate('is_stateflow_based_block',get_param(p,'Handle'));
    end

    listSFBasedBlks=func(@(x)isStateflowBlock(x),blks);
    blks=blks(~listSFBasedBlks);
end


