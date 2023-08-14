function ReplaceSFcnPolyval(block,h)







    if askToReplace(h,block)

        funcSet=uReplaceBlock(h,block,'built-in/Polyval');

        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
