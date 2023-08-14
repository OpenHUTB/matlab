function[sharedLists]=gatherSharedDT(h,blkObj)





    sharedLists={};


    sharedSamePortSrc=hShareSrcAtSamePort(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSamePortSrc);


    outputPathItem=h.getPortMapping([],[],1);

    if strcmp(blkObj.OutDataTypeStr,'Inherit: Same as first input')

        recordToShareWith=h.hShareDTSpecifiedPorts(blkObj,1,[]);
        recordForOutput=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,outputPathItem{1},[]);
        sharedList=[recordToShareWith,{recordForOutput}];
        sharedLists=h.hAppendToSharedLists(sharedLists,sharedList);
    end

    if ismember('Intermediate Results',getPathItems(h,blkObj))&&strcmp(blkObj.IntermediateResultsDataTypeStr,'Inherit: Same as output')

        recordForOutput=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,outputPathItem{1},[]);
        recordForIntermediateResults=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,'Intermediate Results',[]);
        sharedList={recordForOutput,recordForIntermediateResults};
        sharedLists=h.hAppendToSharedLists(sharedLists,sharedList);
    end


    useOneInput=strcmp(blkObj.UseOneInputPortForAllInputData,'on');
    if~useOneInput&&strcmp(blkObj.InputSameDT,'on')

        sharedList=h.hShareDTSpecifiedPorts(blkObj,-1,[]);
        sharedLists=h.hAppendToSharedLists(sharedLists,sharedList);
    end

    allPathItems=getPathItems(h,blkObj);

    if strcmp(blkObj.DataSpecification,'Table and breakpoints')

        if ismember('Table',allPathItems)
            if strcmp(blkObj.TableDataTypeStr,'Inherit: Same as output')

                recordForOutput=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,outputPathItem{1},[]);
                recordForTable=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,'Table',[]);
                sharedList={recordForOutput,recordForTable};
                sharedLists=h.hAppendToSharedLists(sharedLists,sharedList);
            end
        end

        nBreakPointDimensions=slResolve(blkObj.NumberOfTableDimensions,blkObj.Handle);

        for iBreakPoint=1:nBreakPointDimensions
            breakPointString=['BreakpointsForDimension',num2str(iBreakPoint)];
            if ismember(breakPointString,allPathItems)
                if strcmp(blkObj.([breakPointString,'DataTypeStr']),'Inherit: Same as corresponding input')...
                    ||strcmp(blkObj.InterpMethod,'Nearest')





                    if useOneInput

                        inputNumber=1;
                    else
                        inputNumber=iBreakPoint;
                    end
                    recordToShareWith=h.hShareDTSpecifiedPorts(blkObj,inputNumber,[]);
                    recordForBreakPoint=SimulinkFixedPoint.EntityAutoscalerUtils.createSharedRecord(blkObj,breakPointString,[]);
                    sharedLists=h.hAppendToSharedLists(sharedLists,[recordToShareWith,recordForBreakPoint]);
                end
            end
        end
    end
end
