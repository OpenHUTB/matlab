function FlipBlocks(obj)





    if isR2006bOrEarlier(obj.ver)

        blockType='DSPFlip';
        maskType='Flip';
        fcnName='sdspflip';
        refRule='dspindex/Flip';
        setFcn=@setupBufferBlock;

        obj.appendRules(blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn));

    end

end


function maskVarNames=setupBufferBlock(sfcn)
    set_param(sfcn,...
    'Parameters','dim',...
    'MaskVariables','dim=@1');

    maskVarNames={'dim'};
end


