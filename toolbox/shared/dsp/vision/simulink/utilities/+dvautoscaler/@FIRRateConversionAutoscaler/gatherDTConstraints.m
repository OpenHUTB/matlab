function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;
    outportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport');

    pathItems=getPathItems(h,blkObj);
    DTConstraintsSet=cell(numel(pathItems),1);
    for iPathItem=1:numel(pathItems)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{iPathItem});
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint("Signed",[],[]);
        constraint.setSourceInfo(blkObj,[outportStr,' 1']);
        DTConstraintsSet{iPathItem}={uniqueId,constraint};
    end
end


