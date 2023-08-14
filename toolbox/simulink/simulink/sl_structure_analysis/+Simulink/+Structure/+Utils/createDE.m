



function[DE,ports,nI,nO,pathBlocks]=createDE(boundary,passD)

    import Simulink.Structure.Utils.*


    pathObj=get_param(boundary,'Object');

    if strcmp(pathObj.BlockType,'SubSystem')
        pathBlocks1=pathObj.getSortedList;
    else
        mdlName=pathObj.ModelName;
        mo=get_param(mdlName,'Object');
        pathBlocks1=mo.getSortedList;
    end

    pathBlocks2=getGraphicalBlocks(pathObj);


    pathBlocks=union(pathBlocks1,pathBlocks2);

    nBlks=length(pathBlocks);

    blockInSynthesizedSub=[];
    indexToRemove=[];

    for i=1:nBlks
        if isSynthesizedSubSystem(pathBlocks(i))
            blocksIn=expandLoopBlocksInSynthesizedSub(pathBlocks(i));
            blockInSynthesizedSub=[blockInSynthesizedSub;blocksIn];
            indexToRemove=[indexToRemove;i];
        end
    end


    pathBlocks(indexToRemove)=[];


    pathBlocks=union(pathBlocks,blockInSynthesizedSub);


    nBlks=length(pathBlocks);
    indexToRemove=[];
    for i=1:nBlks
        if isHiddenBlockOrVirtualSubsystem(pathBlocks(i))
            indexToRemove=[indexToRemove;i];
        end
    end
    pathBlocks(indexToRemove)=[];


    blockInVirtualSub=[];
    indexToRemove=[];
    nBlks=length(pathBlocks);

    for i=1:nBlks
        if isVirtualSubSystem(pathBlocks(i))
            blocksIn=expandLoopBlocksInVirtualSub(pathBlocks(i));
            blockInVirtualSub=[blockInVirtualSub;blocksIn];
            indexToRemove=[indexToRemove;i];
        end
    end


    pathBlocks(indexToRemove)=[];


    pathBlocks=union(pathBlocks,blockInVirtualSub);


    nBlks=length(pathBlocks);

    HInports=[];
    HOutPorts=[];

    D=sparse(0,0);
    for i=1:nBlks
        HBlock=pathBlocks(i);
        [d,inportHandles,outportHandles]=CreateBlockDMatrix(HBlock,passD);
        D=blkdiag(D,d);
        HInports=[HInports,inportHandles];
        HOutPorts=[HOutPorts,outportHandles];
    end

    E=CreateLoopEMatrix(HInports,HOutPorts);

    nI=length(HInports);
    nO=length(HOutPorts);

    ports=[HInports,HOutPorts];

    DE=[sparse(nI,nI),D;E,sparse(nO,nO)];

end


