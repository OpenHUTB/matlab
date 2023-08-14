function blocksAddedInR2022a(obj)











    if obj.ver.isReleaseOrEarlier('R2021b')
        blocks=addedBlocks;
        for k=1:length(blocks)
            block=obj.findLibraryLinksTo(blocks(k));
            obj.replaceWithEmptySubsystem(block);
        end
    end

end

function blocks=addedBlocks









    blocks="embschedlib/QR Scheduling/Burst QR Save and select R matrix column";
end
