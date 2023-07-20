function[sharedLists]=gatherSharedDT(h,dataObjectWrapper)





    sharedLists={};

    actualSrcIDs=getActualSrcIDs(h,dataObjectWrapper);



    listOfSourceBlocks={};
    if~isempty(actualSrcIDs)
        for iID=1:numel(actualSrcIDs)
            currentID=actualSrcIDs{iID};
            sourceBlock=currentID.getObject;
            if isa(sourceBlock,'Simulink.Lookup_nD')...
                &&strcmp(sourceBlock.InterpMethod,'Nearest')




                listOfSourceBlocks{end+1}=sourceBlock;%#ok<AGROW>
            end
        end
    end

    nBreakPointDimensions=numel(dataObjectWrapper.Object.Breakpoints);
    for iSource=1:numel(listOfSourceBlocks)
        sourceBlock=listOfSourceBlocks{iSource};
        useOneInput=strcmp(sourceBlock.UseOneInputPortForAllInputData,'on');
        for iBreakPoint=1:nBreakPointDimensions
            breakPointString=['Breakpoint',num2str(iBreakPoint)];
            if useOneInput

                inputNumber=1;
            else
                inputNumber=iBreakPoint;
            end
            recordToShareWith=hShareDTSpecifiedPorts(SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler,sourceBlock,inputNumber,[]);
            recordForBreakPoint=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(dataObjectWrapper,breakPointString,[]);
            sharedLists=h.hAppendToSharedLists(sharedLists,[recordToShareWith,recordForBreakPoint]);
        end
    end
end