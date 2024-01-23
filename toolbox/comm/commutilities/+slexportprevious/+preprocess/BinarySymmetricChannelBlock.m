function BinarySymmetricChannelBlock(obj)

    if isR2018aOrEarlier(obj.ver)
        bscBlocks=obj.findBlocksWithMaskType('Binary Symmetric Channel');

        for i=1:length(bscBlocks)
            blk=bscBlocks{i};

            if strcmp(get_param(blk,'OutputDataTypeSL'),'single')
                set_param(blk,'OutputDataTypeSL','double')
            end
        end
    end

end
