function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(this,blockObject)



    hasDTConstraints=false;
    DTConstraintsSet={};


    if contains(blockObject.Inputs,'/')&&any(blockObject.CompiledPortComplexSignals.Inport)







        hasDTConstraints=true;
        curListPorts=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(this,blockObject,-1,[]);
        nListItems=numel(curListPorts);
        DTConstraintsSet=cell(nListItems,1);

        for iListItem=1:nListItems
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{iListItem}.blkObj,curListPorts{iListItem}.pathItem);
            signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
            signedConstraint.setSourceInfo(blockObject,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' ',num2str(iListItem)]);
            DTConstraintsSet{iListItem}={uniqueId,signedConstraint};
        end

        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blockObject,'1');
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint;
        signedConstraint.setSourceInfo(blockObject,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' ','1']);
        DTConstraintsSet{nListItems+1}={uniqueId,signedConstraint};
    end
end


