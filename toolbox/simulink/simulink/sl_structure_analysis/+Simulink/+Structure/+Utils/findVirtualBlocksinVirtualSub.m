



function virtualBlocks=findVirtualBlocksinVirtualSub(hBlk)



    import Simulink.Structure.Utils.*

    virtualBlocks=hBlk;
    blist=[];

    if isVirtualSubSystem(hBlk)
        Oblk=get_param(hBlk,'Object');
        blist=getGraphicalBlocks(Oblk);



        n=length(blist);
        indexToRemove=[];

        for i=1:n
            Ob=get_param(blist(i),'Object');
            if~strcmp(Ob.Virtual,'on')
                indexToRemove=[indexToRemove;i];
            end
        end

        blist(indexToRemove)=[];



        n=length(blist);

        virtualBlocks=[];
        indexToRemove=[];
        for i=1:n
            if isVirtualSubSystem(blist(i))
                blocksIn=findVirtualBlocksinVirtualSub(blist(i));
                virtualBlocks=[virtualBlocks;blocksIn];
                if length(blocksIn)>1
                    indexToRemove=[indexToRemove;i];
                end
            end
        end

        blist(indexToRemove)=[];
    end


    virtualBlocks=[blist;virtualBlocks];

end