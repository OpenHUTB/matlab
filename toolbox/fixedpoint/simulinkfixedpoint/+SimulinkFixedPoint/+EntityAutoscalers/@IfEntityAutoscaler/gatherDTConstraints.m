function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)





    hasDTConstraints=false;
    DTConstraintsSet={};

    curListPorts=h.hShareDTSpecifiedPorts(blkObj,1,[]);


    if~isempty(curListPorts)
        hasDTConstraints=true;

        DTConstraintsSet=cell(numel(curListPorts),1);
        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],[8,16,32],0);
            constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),int2str(idx)]);
            DTConstraintsSet{idx}={uniqueId,constraint};
        end
    end




