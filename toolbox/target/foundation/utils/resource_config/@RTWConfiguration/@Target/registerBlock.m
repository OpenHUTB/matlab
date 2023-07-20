function registerBlock(target,block)











    if~ischar(block)
        TargetCommon.ProductInfo.error('common','InputArgNInvalid','Block','string');
    end

    if~target.isBlockRegistered(block)
        r_blocks=target.registered_blocks;
        target.registered_blocks={r_blocks{:},block};
    else
        TargetCommon.ProductInfo.error('resourceConfiguration','ResourceConfigurationBlockAlreadyRegistered',block);
    end
