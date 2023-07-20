function funcSet=uReplaceBlockWithLink(h,block)










    funcSet={};

    replacementInfo=determineBrokenLinkReplacement(h,block);

    if isempty(replacementInfo.newRefBlock)
        return;
    end

    funcSet=uBlock2Link(h,block,replacementInfo.newRefBlock);

end
