function[associateRecords]=gatherAssociatedParam(h,blkObj)



    associateRecords=[];

    outputPathItem=h.getPortMapping([],[],1);
    allPathItems=getPathItems(h,blkObj);
    blockPathItems={outputPathItem{1}};%#ok<CCAT1>
    if any(ismember(allPathItems,'Intermediate Results'))
        blockPathItems=[blockPathItems,{'Intermediate Results'}];
    end

    if~strcmp(blkObj.DataSpecification,'Lookup table object')

        if any(ismember(allPathItems,'Table'))

            tableString=blkObj.Table;
            [~,minVal,maxVal,pObjTable]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,tableString);



            blockPathItems=[blockPathItems,{'Table'}];
            for bpi=1:length(blockPathItems)
                associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,blockPathItems{bpi},[],minVal,maxVal,pObjTable);
                associateRecords=[associateRecords,associateRecord];%#ok<AGROW>
            end


            tableValues=double(slResolve(tableString,blkObj.Handle));
        else

            tableValues=[];
        end

        numberOfDimensions=slResolve(blkObj.NumberOfTableDimensions,blkObj.Handle);
        if numberOfDimensions>1
            numberOfPoints=size(tableValues);

        else


            numberOfPoints=numel(tableValues);
        end

        for iBreakPoint=1:numberOfDimensions
            parameterName=['BreakpointsForDimension',int2str(iBreakPoint)];

            if any(ismember(allPathItems,parameterName))
                if strcmp(blkObj.BreakpointsSpecification,'Explicit values')


                    stringValue=get_param(blkObj.Handle,parameterName);
                    [~,minVal,maxVal,pObjBreakPoint]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,stringValue);
                    associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,parameterName,[],minVal,maxVal,pObjBreakPoint);
                    associateRecords=[associateRecords,associateRecord];%#ok<AGROW>
                else


                    parameterName=['BreakpointsForDimension',int2str(iBreakPoint)];
                    breakPointParameter=[parameterName,'FirstPoint'];
                    spacingParameter=[parameterName,'Spacing'];



                    [~,minimumValue,~,pObjFirstPoint]=...
                    SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,get_param(blkObj.Handle,breakPointParameter));
                    if~isempty(pObjFirstPoint)
                        minimumValue=pObjFirstPoint.Value;
                    end


                    [~,spacing,~,pObjSpacing]=...
                    SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,get_param(blkObj.Handle,spacingParameter));
                    if~isempty(pObjSpacing)
                        spacing=pObjSpacing.Value;
                    end


                    breakPointValues=minimumValue+[0,spacing*(1:numberOfPoints(iBreakPoint)-1)];
                    [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(breakPointValues);


                    associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,parameterName,[],minVal,maxVal,pObjFirstPoint);
                    associateRecords=[associateRecords,associateRecord];%#ok<AGROW>

                    if~isempty(pObjSpacing)




                        associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,parameterName,[],minVal,maxVal,pObjSpacing);
                        associateRecords=[associateRecords,associateRecord];%#ok<AGROW>
                    end
                end
            end
        end
    else

        lUTObject=slResolve(blkObj.LookupTableObject,blkObj.Handle,'variable','startUnderMask');
        rangeVec=SimulinkFixedPoint.safeConcat(lUTObject.Table.Min,lUTObject.Table.Max,lUTObject.Table.Value);
        [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(rangeVec);

        for bpi=1:length(blockPathItems)
            associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,blockPathItems{bpi},[],minVal,maxVal,[]);
            associateRecords=[associateRecords,associateRecord];%#ok<AGROW>
        end
    end

    if any(ismember(allPathItems,'Fraction'))
        associateRecord=...
        SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
        blkObj,'Fraction',[],0,1,[]);
        associateRecords=[associateRecords,associateRecord];
    end
end
