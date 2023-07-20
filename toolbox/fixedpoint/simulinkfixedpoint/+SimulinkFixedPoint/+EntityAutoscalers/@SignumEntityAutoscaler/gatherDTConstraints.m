function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(~,blkObj)




    hasDTConstraints=true;


    outportStr=message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport').getString();
    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
    constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint("Signed",[],0);
    constraint.setSourceInfo(blkObj,[outportStr,' ','1']);
    DTConstraintsSet{1}={uniqueId,constraint};
end


