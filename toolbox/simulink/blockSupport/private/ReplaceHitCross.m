function ReplaceHitCross(block,h)










    if askToReplace(h,block)
        oldEntries=GetMaskEntries(block);
        CheckEntries(block,oldEntries,2);

        CrossingVal=oldEntries{1};


        HitCrossingOffset=CrossingVal;


        funcSet=uReplaceBlock(h,block,'built-in/HitCross',...
        'HitCrossingOffset',HitCrossingOffset,...
        'HitCrossingDirection','falling',...
        'ShowOutputPort','off');

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
