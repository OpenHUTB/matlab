function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;


    pathItems=getPathItems(h,blkObj);


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);


    LUOutput=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],1);


    permuteIdxOutput=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],2);


    singularityOutput=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],3);

    DTConstraintsSet=cell(numel(curInputPorts)+numel(pathItems)+numel(LUOutput)+numel(permuteIdxOutput)+numel(singularityOutput),1);

    for idx=1:numel(pathItems)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{idx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(pathItems);
    for idx=1:numel(curInputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(pathItems)+numel(curInputPorts);
    for idx=1:numel(LUOutput)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(LUOutput{idx}.blkObj,LUOutput{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(pathItems)+numel(curInputPorts)+numel(LUOutput);
    for idx=1:numel(permuteIdxOutput)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(permuteIdxOutput{idx}.blkObj,permuteIdxOutput{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Unsigned',[32],0);%#ok
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 2']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
    end

    startingIdx=numel(pathItems)+numel(curInputPorts)+numel(LUOutput)+numel(permuteIdxOutput);
    for idx=1:numel(singularityOutput)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(singularityOutput{idx}.blkObj,singularityOutput{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.BooleanOnlyConstraint;
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 3']);
        DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
    end

end
