function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=true;

    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);

    isROIPort=false;
    if numel(curInputPorts)>2
        ROIValOnDialog=get_param(blkObj.handle,'viewport');

        dialogParameters=get_param(blkObj.handle,'DialogParameters');
        viewPortStruct=dialogParameters.viewport;
        if strcmpi(viewPortStruct.Enum{2},ROIValOnDialog)
            isROIPort=true;
        end
    end

    DTConstraintsSet=cell(1+isROIPort,1);
    startingIdx=2;
    for idx=startingIdx:startingIdx+isROIPort
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{idx}.blkObj,curInputPorts{idx}.pathItem);
        constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(idx)]);
        DTConstraintsSet{idx-startingIdx+1}={uniqueId,constraint};
    end
end