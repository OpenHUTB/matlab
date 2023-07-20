function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;
    DTConstraintsSet={};

    outportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport');

    actualSrcIDs=getActualSrcIDs(h,blkObj);
    hasFloatingPointConstraints=false;
    blockHasExplicitValuesAndEvenSpacingSearch=false;


    if~isempty(actualSrcIDs)
        for iID=1:numel(actualSrcIDs)
            currentID=actualSrcIDs{iID};
            sourceBlock=currentID.getObject;
            if SimulinkFixedPoint.EntityAutoscalers.SLLookupTableEntityAutoscaler.hasFloatingPointConstraint(sourceBlock)



                hasFloatingPointConstraints=true;
                break;
            end
        end

        if~hasFloatingPointConstraints
            for iID=1:numel(actualSrcIDs)
                currentID=actualSrcIDs{iID};
                sourceBlock=currentID.getObject;
                if isa(sourceBlock,'Simulink.Lookup_nD')...
                    &&strcmp(sourceBlock.IndexSearchMethod,'Evenly spaced points')
                    blockHasExplicitValuesAndEvenSpacingSearch=true;
                    break;
                end
            end
        end
    end

    if hasFloatingPointConstraints
        pathItems=h.getPathItems(blkObj);
        nPathItems=numel(pathItems);
        DTConstraintsSet=cell(1,nPathItems);
        for iPathItem=1:nPathItems

            data=struct('Object',blkObj,'ElementName',pathItems{iPathItem});
            dHandler=fxptds.SimulinkDataArrayHandler;
            uniqueId=dHandler.getUniqueIdentifier(data);


            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;


            constraint.setSourceInfo(sourceBlock,[outportStr,' ','1']);


            DTConstraintsSet{iPathItem}={uniqueId,constraint};
        end
    else

        pathItems=getPathItems(h,blkObj);
        constraintCount=1;
        for iPathItem=1:numel(pathItems)
            pathItem=pathItems{iPathItem};

            if isPathItemForBlockParam(h,blkObj,pathItem)
                if~strcmp(pathItem,'Table')




                    data=struct('Object',blkObj,'ElementName',pathItems{iPathItem});
                    dHandler=fxptds.SimulinkDataArrayHandler;
                    uniqueId=dHandler.getUniqueIdentifier(data);



                    index=h.getIndexFromBreakpointPathitem(pathItem);
                    dataTypeCreator=h.getDataTypeCreator(blkObj.Object,index);

                    registerMonotonicityConstraint=true;




                    if blockHasExplicitValuesAndEvenSpacingSearch
                        registerMonotonicityConstraint=SimulinkFixedPoint.isSpacingPerfectlyEven(dataTypeCreator.Values{1});
                    end

                    if registerMonotonicityConstraint

                        constraint=SimulinkFixedPoint.AutoscalerConstraints.MonotonicityConstraint(dataTypeCreator);
                    else


                        constraint=SimulinkFixedPoint.AutoscalerConstraints.ValuesNotPerfectlyEvenlySpacedConstraint(...
                        SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
                    end


                    constraint.setSourceInfo(blkObj,pathItem);


                    DTConstraintsSet{constraintCount}={uniqueId,constraint};%#ok<AGROW>

                    constraintCount=constraintCount+1;
                end
            end
        end
    end
end

