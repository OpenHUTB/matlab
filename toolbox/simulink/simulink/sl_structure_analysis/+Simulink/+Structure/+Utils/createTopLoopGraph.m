




function[DE,ports,nI,nO,startNodeIdx,hAlgLoopBlocks]=...
    createTopLoopGraph(hAlgLoopSub,passD)

    import Simulink.Structure.Utils.*

    algLoopObj=get(hAlgLoopSub,'Object');
    hAlgLoopBlocks=algLoopObj.getSortedList;
    hAlgLoopBlocks=getGGTopoBlocks(hAlgLoopBlocks);
    VirtualBlocks=getVirtualBlockInParent(algLoopObj);

    hAlgLoopBlocks=[hAlgLoopBlocks;VirtualBlocks];

    n=length(hAlgLoopBlocks);

    blockInSynthesizedSub=[];
    indexToRemove=[];

    for i=1:n
        if isSynthesizedSubSystem(hAlgLoopBlocks(i))
            blocksIn=expandLoopBlocksInSynthesizedSub(HalgLoopBlocks(i));
            blockInSynthesizedSub=[blockInSynthesizedSub;blocksIn];
            indexToRemove=[indexToRemove;i];
        end
    end


    hAlgLoopBlocks(indexToRemove)=[];


    hAlgLoopBlocks=[hAlgLoopBlocks;blockInSynthesizedSub];


    nBlks=length(hAlgLoopBlocks);
    indexToRemove=[];
    for i=1:nBlks
        if isHiddenBlockOrVirtualSubsystem(hAlgLoopBlocks(i))
            indexToRemove=[indexToRemove;i];
        end
    end
    hAlgLoopBlocks(indexToRemove)=[];

    nBlks=length(hAlgLoopBlocks);


    hInports=[];
    hOutPorts=[];


    D=sparse(0,0);

    for i=1:nBlks
        hBlock=hAlgLoopBlocks(i);
        [d,inportHandles,outportHandles]=CreateBlockDMatrix(hBlock,passD);
        D=blkdiag(D,d);
        hInports=[hInports,inportHandles];
        hOutPorts=[hOutPorts,outportHandles];
    end


    E=CreateLoopEMatrix(hInports,hOutPorts);

    nI=length(hInports);
    nO=length(hOutPorts);

    ports=[hInports,hOutPorts];
    startNodeIdx=length(hInports)+1;

    DE=[sparse(nI,nI),D;E,sparse(nO,nO)];

end