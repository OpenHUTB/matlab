function replaceBlockWithLink(block,h)









    name=h.cleanLocationName(block);
    if askToReplace(h,name)
        funcSet=uReplaceBlockWithLink(h,block);
        appendTransaction(h,name,h.ConvertToLinkReasonStr,{funcSet});
    end

end
