function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};
    blkParentObj=blkObj.getParent;
    curListPorts={};

    blkList=find(blkParentObj,'-isa','Simulink.SFunction');
    sharedPathItem={'Accumulator','Product output','Output','FirstCoeff'};

    if~isempty(blkList)
        for i=1:length(sharedPathItem)
            for idx=1:length(blkList)
                sFunSignal.blkObj=blkList(idx);
                sFunSignal.pathItem=sharedPathItem{i};
                curListPorts=[curListPorts,sFunSignal];%#ok<AGROW>
            end
            sharedLists{end+1}=curListPorts;%#ok<AGROW>
            curListPorts={};
        end
    end
