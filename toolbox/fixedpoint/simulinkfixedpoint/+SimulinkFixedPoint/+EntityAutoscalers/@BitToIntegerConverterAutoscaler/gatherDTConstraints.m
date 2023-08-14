function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;



    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);


    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);

    DTConstraintsSet=cell(numel(curInputPorts)+numel(curOutputPorts),1);


    for idx=1:numel(curInputPorts)


        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx}={uniqueId,constraint};
    end
    startingIdx=numel(curInputPorts);
    for idx=1:numel(curOutputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
    end

end