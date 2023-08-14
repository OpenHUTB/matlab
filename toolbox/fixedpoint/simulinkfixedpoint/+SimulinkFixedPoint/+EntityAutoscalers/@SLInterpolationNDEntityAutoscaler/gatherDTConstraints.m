function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)











    DTConstraintsSet={};

    inportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport');

    hasFloatingPointConstraints=h.hasFloatingPointConstraint(blkObj);

    [indexPortsNums,fracPortNums,busPortNums,selectPortNums]=h.analyzeInports(blkObj);

    integerInports=[indexPortsNums,selectPortNums];
    if~isempty(integerInports)
        curSrcPortID=h.hShareDTSpecifiedPorts(blkObj,integerInports,[]);
        for idx=1:numel(curSrcPortID)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curSrcPortID{idx}.blkObj,curSrcPortID{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
            constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(integerInports(idx))]);
            DTConstraintsSet{idx}={uniqueId,constraint};%#ok<AGROW>
        end
    end

    if~isempty(fracPortNums)&&hasFloatingPointConstraints
        curSrcPortID=h.hShareDTSpecifiedPorts(blkObj,fracPortNums,[]);
        for idx=1:numel(curSrcPortID)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curSrcPortID{idx}.blkObj,curSrcPortID{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(fracPortNums(idx))]);
            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
        end
    end

    if~isempty(busPortNums)


        for idx=1:numel(busPortNums)
            portHandles=blkObj.PortHandles;
            busInportHandle=portHandles.Inport(busPortNums(idx));

            if h.hIsNonVirtualBus(busInportHandle)
                sigH=get_param(busInportHandle,'SignalHierarchy');
                busObjectName=h.hCleanDTOPrefix(sigH.BusObject);


                uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,1,blkObj);
                constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
                constraint.setSourceInfo(blkObj,[inportStr,int2str(busPortNums(idx))]);
                DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>

                if hasFloatingPointConstraints
                    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,2,blkObj);
                    constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
                    constraint.setSourceInfo(blkObj,[inportStr,int2str(busPortNums(idx))]);
                    DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
                end
            end
        end
    end

    if hasFloatingPointConstraints
        pathItems=getPathItems(h,blkObj);
        for ii=1:numel(pathItems)

            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{ii});
            constraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
        end
    end

    hasDTConstraints=~isempty(DTConstraintsSet);
end


