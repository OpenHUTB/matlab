function ReplaceSFunMem(block,h)







    if askToReplace(h,block)
        funcSet=uReplaceBlock(h,block,'built-in/Memory',...
        'X0','0.0');
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
