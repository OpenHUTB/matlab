function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)







    if(strcmp(blkObj.dataType,'Fixed-point')||...
        strcmp(blkObj.dataType,'User-defined'))
        hasDTConstraints=false;
        DTConstraintsSet={};
    else
        hasDTConstraints=true;

        pathItems=getPathItems(h,blkObj);


        curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,-1,-1);

        DTConstraintsSet=cell(numel(curListPorts)+numel(pathItems),1);

        for idx=1:numel(pathItems)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItems{idx});
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx}={uniqueId,signedConstraint};
        end

        startingIdx=numel(pathItems);

        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
            signedConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);
            DTConstraintsSet{idx+startingIdx}={uniqueId,signedConstraint};
        end
    end
end