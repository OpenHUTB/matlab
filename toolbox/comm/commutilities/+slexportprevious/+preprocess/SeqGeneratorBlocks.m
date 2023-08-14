function SeqGeneratorBlocks(obj)






    if isR2015aOrEarlier(obj.ver)


        seqGenBlocks=findSeqGenblocks(obj);


        for i=1:length(seqGenBlocks)
            thisSet=seqGenBlocks{i};

            for j=1:length(thisSet)
                blk=thisSet{j};





                if i==1
                    hConvertStringPolysToNum(blk,'genPoly','descending');
                elseif i==2
                    hConvertStringPolysToNum(blk,'poly','descending');
                elseif i==3
                    hConvertStringPolysToNum(blk,'genPoly1','descending');
                    hConvertStringPolysToNum(blk,'genPoly2','descending');
                end
            end
        end
    end

end




function seqGenBlocks=findSeqGenblocks(obj)


    kasamiGenerators=obj.findBlocksWithMaskType('Kasami Sequence Generator');

    pnGenerators=obj.findBlocksWithMaskType('PN Sequence Generator');

    goldGenerators=obj.findBlocksWithMaskType('Gold Sequence Generator');

    seqGenBlocks={kasamiGenerators;pnGenerators;goldGenerators};
end
