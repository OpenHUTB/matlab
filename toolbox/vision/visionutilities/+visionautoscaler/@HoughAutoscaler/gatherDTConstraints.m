function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;


    pathItems=getPathItems(h,blkObj);


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);



    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);

    DTConstraintsSet=cell(numel(curInputPorts)+numel(curOutputPorts)+numel(pathItems),1);

    for idx=1:numel(curInputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.BooleanOnlyConstraint;
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(curInputPorts);
    for idx=1:numel(curOutputPorts)
        if strcmpi(curOutputPorts{idx}.pathItem,'1')
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Unsigned',[],0);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
            DTConstraintsSet{startingIdx+idx}={uniqueId,signedConstraint};
        else
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' ',num2str(idx)]);
            DTConstraintsSet{startingIdx+idx}={uniqueId,signedConstraint};
        end
    end

    startingIdx=numel(curInputPorts)+numel(curOutputPorts);
    for idx=1:numel(pathItems)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraintsSet{startingIdx+idx}={uniqueId,signedConstraint};
    end
end