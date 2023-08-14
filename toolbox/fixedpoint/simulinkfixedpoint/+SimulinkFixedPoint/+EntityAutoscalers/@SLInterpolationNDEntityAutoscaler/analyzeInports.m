function[indexPortsNums,fracPortNums,busPortNums,selectPortNums]=analyzeInports(h,blkObj)






    if blkObj.isSynthesized


        numOfDim=eval(blkObj.NumberOfTableDimensions);
        numOfSelDim=eval(blkObj.NumSelectionDims);
    else

        blkUsedForEvaluation=blkObj.getFullName;

        numOfDim=slResolve(blkObj.NumberOfTableDimensions,blkUsedForEvaluation);
        numOfSelDim=slResolve(blkObj.NumSelectionDims,blkUsedForEvaluation);
    end




    ph=blkObj.PortHandles;

    indexPortsNums=[];
    fracPortNums=[];
    busPortNums=[];

    if h.hIsNonVirtualBus(ph.Inport(1))||h.hIsVirtualBus(ph.Inport(1))




        busPortNums=1:numOfDim-numOfSelDim;




        selectPortNums=length(busPortNums)+1:length(busPortNums)+numOfSelDim;

    else



        numbOfPairPorts=2*(numOfDim-numOfSelDim);
        indexPortsNums=1:2:numbOfPairPorts;
        fracPortNums=2:2:numbOfPairPorts;


        selectPortNums=numbOfPairPorts+1:numbOfPairPorts+numOfSelDim;

    end

end

