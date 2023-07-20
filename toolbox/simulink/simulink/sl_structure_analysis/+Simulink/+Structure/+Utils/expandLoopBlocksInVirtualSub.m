



function blockInVirtualSub=expandLoopBlocksInVirtualSub(hBlk)


    import Simulink.Structure.Utils.*

    blockInVirtualSub=hBlk;

    oBlk=get_param(hBlk,'Object');

    if isVirtualSubSystem(hBlk)

        blist=getGraphicalBlocks(oBlk);

        n=length(blist);

        blockInVirtualSub=[];
        indexToRemove=[];
        for j=1:n
            if isVirtualSubSystem(blist(j))
                blocksIn=expandLoopBlocksInVirtualSub(blist(j));
                if~isempty(blocksIn)
                    blockInVirtualSub=[blockInVirtualSub;blocksIn];
                end
                indexToRemove=[indexToRemove;j];
            end
        end

        blist(indexToRemove)=[];
    end


    if~isempty(blist)
        blockInVirtualSub=[blist;blockInVirtualSub];
    end

end