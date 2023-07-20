


function blockInSynthesizedSub=expandLoopBlocksInSynthesizedSub(hBlk)


    import Simulink.Structure.Utils.*

    blockInSynthesizedSub=hBlk;

    Oblk=get_param(hBlk,'Object');

    if strcmp(Oblk.BlockType,'SubSystem')
        isVirtual=(strcmp(Oblk.IsSubsystemVirtual,'on'));
    end

    if isSynthesizedSubSystem(hBlk)
        if isVirtual
            blist=getGraphicalBlocks(Oblk);
        else
            blist=Oblk.getCompiledBlockList;
        end

        n=length(blist);

        blockInSynthesizedSub=[];
        indexToRemove=[];
        for j=1:n
            if isSynthesizedSubSystem(blist(j))
                blocksIn=expandLoopBlocksInSynthesizedSub(blist(j));
                blockInSynthesizedSub=[blockInSynthesizedSub;blocksIn];
                indexToRemove=[indexToRemove;j];
            end
        end

        blist(indexToRemove)=[];
    end


    blockInSynthesizedSub=[blist;blockInSynthesizedSub];

end