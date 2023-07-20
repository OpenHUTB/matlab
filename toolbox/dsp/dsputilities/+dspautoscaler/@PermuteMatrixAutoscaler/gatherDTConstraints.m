function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=false;
    DTConstraintsSet={};


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,2,[]);

    if~isempty(curInputPorts)
        DTConstraintsSet=cell(1,1);
        hasDTConstraints=true;

        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{1}.blkObj,curInputPorts{1}.pathItem);
        noFixptConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        noFixptConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 2']);
        DTConstraintsSet{1}={uniqueId,noFixptConstraint};
    end

end