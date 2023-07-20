function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)





    inportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport');

    hasDTConstraints=true;
    DTConstraintsSet={};
    curInports=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);
    if numel(curInports)>=2
        DTConstraintsSet=cell(1,1);
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInports{2}.blkObj,curInports{2}.pathItem);
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
        constraint.setSourceInfo(blkObj,[inportStr,' ',int2str(2)]);
        DTConstraintsSet{1}={uniqueId,constraint};
    end

end
