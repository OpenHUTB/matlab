function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;

    isResetPortOn=get_param(blkObj.handle,'clr');
    if strcmpi(isResetPortOn,'on')
        isResetPortOn=true;
    else
        isResetPortOn=false;
    end


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,2:3+isResetPortOn,[]);


    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);
    DTConstraintsSet=cell(numel(curInputPorts)+numel(curOutputPorts),1);

    for idx=1:numel(curInputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
        DTConstraintsSet{idx}={uniqueId,constraint};
    end

    startingIdx=numel(curInputPorts);
    uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{1}.blkObj,curOutputPorts{1}.pathItem);
    signedOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
    signedOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
    DTConstraintsSet{1+startingIdx}={uniqueId,signedOnlyConstraint};

    startingIdx=numel(curInputPorts)+1;
    for idx=2:numel(curOutputPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{idx}.blkObj,curOutputPorts{idx}.pathItem);
        noFixptConstraint=SimulinkFixedPoint.AutoscalerConstraints.LimitedNonFxpOnlyConstraint;
        noFixptConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' ',num2str(idx)]);
        DTConstraintsSet{idx+startingIdx-1}={uniqueId,noFixptConstraint};
    end
end