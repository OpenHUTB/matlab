function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;

    pathItems=getPathItems(h,blkObj);


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);
    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);

    DTConstraintsSet=cell(numel(curInputPorts)+numel(curOutputPorts)+numel(pathItems),1);

    for idx=1:numel(pathItems)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(pathItems);

    for idx=1:numel(curOutputPorts)
        if strcmp(curOutputPorts{idx}.pathItem,'1')
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
            builtInOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
            builtInOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx+startingIdx}={uniqueId,builtInOnlyConstraint};
        else
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
        end
    end

    startingIdx=numel(pathItems)+numel(curOutputPorts);

    for idx=1:numel(curInputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};

    end

end
