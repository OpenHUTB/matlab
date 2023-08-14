function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;
    DTConstraintsSet={};

    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);
    curOutputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],-1);

    methodTypeSupportsFixpt=true;


    methodValOnDialog=get_param(blkObj.handle,'method');

    dialogParameters=get_param(blkObj.handle,'DialogParameters');
    methodStruct=dialogParameters.method;
    if strcmpi(methodStruct.Enum{4},methodValOnDialog)
        methodTypeSupportsFixpt=false;
    end

    isEdgeOutputPresent=false;
    outputValOnDialog=get_param(blkObj.handle,'outputType');

    outputStruct=dialogParameters.outputType;
    if strcmpi(outputStruct.Enum{1},outputValOnDialog)||strcmpi(outputStruct.Enum{3},outputValOnDialog)
        isEdgeOutputPresent=true;
    end

    if~methodTypeSupportsFixpt
        DTConstraintsSet=cell(numel(curInputPorts)+1,1);
        if isEdgeOutputPresent
            DTConstraintsSet=cell(1,1);
        end
    end

    if isEdgeOutputPresent
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curOutputPorts{1}.blkObj,curOutputPorts{1}.pathItem);
        booleanOnlyConstraint=SimulinkFixedPoint.AutoscalerConstraints.BooleanOnlyConstraint;
        booleanOnlyConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraintsSet{1}={uniqueId,booleanOnlyConstraint};
    end
    if~methodTypeSupportsFixpt
        for idx=1:numel(curInputPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
            noFixptConstraint=SimulinkFixedPoint.AutoscalerConstraints.LimitedNonFxpOnlyConstraint;
            noFixptConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
            DTConstraintsSet{idx+isEdgeOutputPresent}={uniqueId,noFixptConstraint};%#ok
        end
    end
end