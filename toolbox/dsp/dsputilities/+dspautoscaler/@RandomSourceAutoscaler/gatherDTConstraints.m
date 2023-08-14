function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(~,blkObj)




    hasDTConstraints=true;


    outportStr=message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport').getString();
    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
    floatingPointOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
    floatingPointOnlyConstraint.setSourceInfo(blkObj,outportStr);
    DTConstraintsSet{1}={uniqueId,floatingPointOnlyConstraint};
end


