function markBustoVectorConversion(this,hsig,dstBlk,portNum,hC)








    if isempty(hC)
        return;
    end
    if portNum>hC.NumberOfPirInputPorts
        return;
    end

    for ii=1:numel(this.BustoVectorBlocks)
        bustoVectorBlk=this.BustoVectorBlocks(ii);
        dstBlkPath=getfullname(dstBlk);
        isCandidate=isBustoVectorConvCandidate(bustoVectorBlk,portNum,dstBlkPath,hC);
        if isCandidate
            hsig.setBustoVectorFlag(true);
            hC.PirInputPorts(portNum).setBustoVectorFlag(true);
        end
    end
end


function isCand=isBustoVectorConvCandidate(bustoVectorBlk,portNum,dstBlkPath,hC)
    isCand=false;
    bustoVectorBlkPath=bustoVectorBlk.BlockPath;
    bustoVectorBlkInPortNum=bustoVectorBlk.InputPort;



    dstBlkPath=regexprep(dstBlkPath,newline,' ');


    if(strcmpi(bustoVectorBlkPath,dstBlkPath)&&...
        bustoVectorBlkInPortNum==portNum)
        isCand=true;
        return;
    end




    slbh=hC.SimulinkHandle;



    if(slbh~=-1&&isprop(slbh,'BlockType')&&...
        strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
        ~hC.isAbstractNetworkReference)

        sfblkMatch=contains(bustoVectorBlkPath,dstBlkPath);
        if(sfblkMatch&&...
            bustoVectorBlkInPortNum==portNum)
            isCand=true;
        end
    end
end
