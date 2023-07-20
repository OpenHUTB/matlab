function[newRefsBlk,allRefsBlk]=accumulateRefsForBlkIteratively(rMgr,newRefsBlk,allRefsBlk)

















    tempRefsBlk=newRefsBlk;
    newRefsBlk=cellfun(@(x)i_getLibRefsIfKey(rMgr,x),tempRefsBlk,'UniformOutput',false);
    newRefsBlk=vertcat(newRefsBlk{:});

    newRefsBlk=setdiff(newRefsBlk,allRefsBlk);
    allRefsBlk=[allRefsBlk;newRefsBlk];


    function subBlks=i_getLibRefsIfKey(rMgr,blk)
        subBlks={};
        if isKey(rMgr.AllLibBlksMap,blk)
            subBlks=i_replaceCarriageReturnWithSpace(rMgr.AllLibBlksMap(blk));
        end
    end
end
