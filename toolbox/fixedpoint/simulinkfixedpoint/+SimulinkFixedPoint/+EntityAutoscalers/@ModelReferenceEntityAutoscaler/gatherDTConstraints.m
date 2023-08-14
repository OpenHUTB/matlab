function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)






    hasDTConstraints=false;
    DTConstraintsSet={};


    if strcmpi(blkObj.ProtectedModel,'off')
        return;
    end

    curListPorts=h.hShareDTSpecifiedPorts(blkObj,-1,-1);

    if~isempty(curListPorts)
        hasDTConstraints=true;
        DTConstraintsSet=cell(numel(curListPorts),1);

        for idx=1:numel(curListPorts)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(curListPorts{idx}.blkObj,curListPorts{idx}.pathItem);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.MdlRefBoundaryConstraint;
            constraint.setSourceInfo(blkObj,['port',int2str(idx)]);
            DTConstraintsSet{idx}={uniqueId,constraint};
        end
    end


