


function VirtualBlocks=getVirtualBlockInParent(algLoopObj)

    import Simulink.Structure.Utils.*

    parent=algLoopObj.Parent;

    parentO=get_param(parent,'Object');

    while~strcmp(parentO.Type,'block_diagram')&&isSynthesizedSubSystem(parent)
        parent=parentO.parent;
        parentO=get_param(parent,'Object');
    end

    cb=parentO.getCompiledBlockList;

    n=length(cb);
    IndexToRemove=[];
    for i=1:n
        ho=get_param(cb(i),'Object');
        if ho.isPostCompileVirtual

            Ports=get_param(cb(i),'Ports');

            nIp=Ports(2);
            nOp=Ports(1);

            if(nIp==1)&&(nOp==1)
                IndexToRemove=[IndexToRemove;i];
            end
        end
    end

    cb(IndexToRemove)=[];





    sb=parentO.getSortedList;

    VirtualBlocks=setdiff(cb,sb);



    nBlks=length(VirtualBlocks);
    indexToRemove=[];
    for i=1:nBlks
        if isHiddenBlockOrVirtualSubsystem(VirtualBlocks(i))
            indexToRemove=[indexToRemove;i];
        end
    end
    VirtualBlocks(indexToRemove)=[];



    nBlks=length(VirtualBlocks);
    VirtualBlockInSub=[];

    for i=1:nBlks
        if isVirtualSubSystem(VirtualBlocks(i))
            blocksIn=findVirtualBlocksinVirtualSub(VirtualBlocks(i));
            VirtualBlockInSub=[VirtualBlockInSub;blocksIn];
        end
    end

    VirtualBlocks=[VirtualBlocks;VirtualBlockInSub];

end