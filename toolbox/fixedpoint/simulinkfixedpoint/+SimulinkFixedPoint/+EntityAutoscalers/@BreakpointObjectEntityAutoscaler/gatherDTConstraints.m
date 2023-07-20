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





            entityAutoscalerInterface=...
            SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
            sourceBlockAutoscaler=getAutoscaler(entityAutoscalerInterface,sourceBlock);
            sourceHasFloatingPointConstraint=...
            sourceBlockAutoscaler.hasFloatingPointConstraint(sourceBlock);
            if sourceHasFloatingPointConstraint
                hasFloatingPointConstraints=true;
                break;
            end
        end

        if~hasFloatingPointConstraints
            for iID=1:numel(actualSrcIDs)
                currentID=actualSrcIDs{iID};
                sourceBlock=currentID.getObject;
                if isa(sourceBlock,'Simulink.PreLookup')...
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
        for iPathItem=1:nPathItems

            data=struct('Object',blkObj,'ElementName',pathItems{iPathItem});
            dHandler=fxptds.SimulinkDataArrayHandler;
            uniqueId=dHandler.getUniqueIdentifier(data);


            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;




            constraint.setSourceInfo(sourceBlock,[outportStr,' ',num2str(sourceBlock.Ports(2))]);


            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
        end
    else

        pathItems=getPathItems(h,blkObj);
        pathItem=pathItems{1};


        data=struct('Object',blkObj,'ElementName',pathItem);
        dHandler=fxptds.SimulinkDataArrayHandler;
        uniqueId=dHandler.getUniqueIdentifier(data);


        dataTypeCreator=h.getDataTypeCreator(blkObj.Object);

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

        DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];
    end
end


