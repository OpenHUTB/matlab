function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)%#ok





    hasDTConstraints=true;

    curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,1,[]);
    DTConstraintsSet=cell(numel(curListPorts),1);
    for idx=1:numel(curListPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
        constraint=SimulinkFixedPoint.AutoscalerConstraints.BooleanOnlyConstraint;
        constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),'1']);
        DTConstraintsSet{idx}={uniqueId,constraint};
    end



