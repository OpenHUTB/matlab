function BufferBlock(obj)





    if isR2011aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|Buffer><HasFrameUpgradeWarning:remove>>');

    end



    if isR2010aOrEarlier(obj.ver)

        blockType='Buffer';
        maskType='Buffer';
        fcnName='sdsprebuff2';
        refRule='dspbuff3/Buffer';
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
    'Parameters','N,V,ic',...
    'MaskVariables','N=@1;V=@2;ic=@3;');

    maskVarNames={'N','V','ic'};
end
