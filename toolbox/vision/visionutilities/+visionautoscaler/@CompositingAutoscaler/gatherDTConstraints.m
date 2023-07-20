function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;

    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);




    locationPortFound=false;
    maskHasConstraint=false;

    if numel(curInputPorts)>2
        locationPortFound=true;

        operationValOnDialog=get_param(blkObj.handle,'operation');

        dialogParameters=get_param(blkObj.handle,'DialogParameters');
        operationStruct=dialogParameters.operation;
        if strcmpi(operationStruct.Enum{3},operationValOnDialog)
            maskHasConstraint=true;
        end
    end

    DTConstraintsSet=cell(maskHasConstraint+locationPortFound,1);

    if maskHasConstraint
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{2}.blkObj,curInputPorts{2}.pathItem);
        booleanOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.BooleanOnlyConstraint;
        booleanOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 2']);
        DTConstraintsSet{maskHasConstraint}={uniqueId,booleanOnlyConstraint};
    end
    if locationPortFound
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{3}.blkObj,curInputPorts{3}.pathItem);
        noFixptConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        noFixptConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 3']);
        DTConstraintsSet{locationPortFound+maskHasConstraint}={uniqueId,noFixptConstraint};
    end

end