function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=false;
    DTConstraintsSet={};


    curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,[]);

    doesShearPortExist=(numel(curListPorts)>=2);

    if doesShearPortExist
        hasDTConstraints=true;
        DTConstraintsSet=cell(doesShearPortExist,1);
        shearPortIdx=2;
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{shearPortIdx}.blkObj,curListPorts{shearPortIdx}.pathItem);
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
        DTConstraintsSet{1}={uniqueId,signedConstraint};
    end
end