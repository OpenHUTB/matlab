function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=false;
    DTConstraintsSet={};


    curInputPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);

    if numel(curInputPorts)>1
        hasDTConstraints=true;
        DTConstraintsSet=cell(1,1);
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curInputPorts{2}.blkObj,curInputPorts{2}.pathItem);
        noFixptConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
        noFixptConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 2']);
        DTConstraintsSet{1}={uniqueId,noFixptConstraint};
    end
end