function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;


    curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);

    DTConstraintsSet=cell(numel(curListPorts),1);

    for idx=1:numel(curListPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx}={uniqueId,signedConstraint};
    end
end
