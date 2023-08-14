function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;
    DTConstraintsSet={};



    curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,-1);

    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{1}.blkObj,curListPorts{1}.pathItem);
    signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
    signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
    DTConstraintsSet{1}={uniqueId,signedConstraint};


    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{2}.blkObj,curListPorts{2}.pathItem);
    signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
    signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
    DTConstraintsSet{2}={uniqueId,signedConstraint};
end