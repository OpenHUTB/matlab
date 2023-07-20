function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)





    hasDTConstraints=true;


    bitShiftNumberSource=get_param(blkObj.getFullName,'BitShiftNumberSource');
    if strcmpi(bitShiftNumberSource,'Dialog')

        hasDTConstraints=false;
        DTConstraintsSet={};
        return;
    end


    curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,2,[]);

    DTConstraintsSet=cell(numel(curListPorts),1);


    for idx=1:numel(curListPorts)
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[],0);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 2']);
        DTConstraintsSet{idx}={uniqueId,signedConstraint};
    end
end


