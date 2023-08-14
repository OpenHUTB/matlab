function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;



    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);
    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);

    DTConstraintsSet=cell(numel(curInputPorts)+numel(curOutputPorts),1);

    for idx=1:numel(curInputPorts)
        if mod(idx,2)==1
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
            signedOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
            DTConstraintsSet{idx}={uniqueId,signedOnlyConstraint};
        else
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
            DTConstraintsSet{idx}={uniqueId,constraint};
        end
    end

    startingIdx=numel(curInputPorts);
    for idx=1:numel(curOutputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
        signedOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedOnlyConstraint};
    end
end