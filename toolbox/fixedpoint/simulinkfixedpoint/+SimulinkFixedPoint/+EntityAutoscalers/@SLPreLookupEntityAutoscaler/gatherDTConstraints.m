function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)











    hasDTConstraints=true;
    DTConstraintsSet={};

    ph=blkObj.PortHandles;

    busObjectUsed=false;
    if h.hIsNonVirtualBus(ph.Outport(1))
        busObjectUsed=true;

        sigH=get_param(ph.Outport(1),'SignalHierarchy');
        busObjectName=h.hCleanDTOPrefix(sigH.BusObject);



        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,1,blkObj);
    else

        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
    end



    constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
    outportStr=[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' ','1'];
    constraint.setSourceInfo(blkObj,outportStr);
    DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];

    if h.hasFloatingPointConstraint(blkObj)



        if~strcmp(blkObj.OutputSelection,'Index only')
            if busObjectUsed


                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,2,blkObj);
            else


                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'2');
            end


            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            outportStr=[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' ','2'];
            constraint.setSourceInfo(blkObj,outportStr);
            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];
        end


        curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);
        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ','1']);
            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
        end
    else
        if ismember(blkObj.BreakpointsSpecification,{'Explicit values','Even spacing'})...
            &&strcmp(blkObj.BreakpointsDataSource,'Dialog')

            pathItem='Breakpoint';


            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItem);


            dataTypeCreator=h.getDataTypeCreator(blkObj);

            registerMonotonicityConstraint=true;
            if strcmp(blkObj.BreakpointsSpecification,'Explicit values')...
                &&strcmp(blkObj.IndexSearchMethod,'Evenly spaced points')
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
end


