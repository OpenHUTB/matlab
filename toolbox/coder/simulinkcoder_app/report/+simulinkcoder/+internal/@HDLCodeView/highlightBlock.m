function highlightBlock(sids)




    slhdlcoder.checkLicense();

    if~isempty(sids)
        coder.internal.highlightBlocks(sids);
    end
end

