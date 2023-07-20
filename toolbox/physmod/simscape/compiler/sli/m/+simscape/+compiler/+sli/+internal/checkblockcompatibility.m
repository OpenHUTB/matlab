function[badBlocks,badBlockMsgs]=checkblockcompatibility(blocks)














    badBlocks={};
    badBlockMsgs={};


    dispatch.SimscapeBlock={
    @simscape.compiler.sli.internal.findnonupdatedacsources;
    @simscape.compiler.sli.internal.findnonconvertibleunits};

    blockTypes=get_param(blocks,'BlockType');


    bt=fieldnames(dispatch);
    for btidx=1:numel(bt)
        matchingBlocks=blocks(strcmp(blockTypes,bt{btidx}));
        fcns=dispatch.(bt{btidx});
        for fidx=1:numel(fcns)
            [badMatchingBlocks,badMatchingBlockMsgs]=fcns{fidx}(matchingBlocks);
            badBlocks=[badBlocks(:);badMatchingBlocks(:)];
            badBlockMsgs=[badBlockMsgs(:);badMatchingBlockMsgs(:)];
        end
    end

end

