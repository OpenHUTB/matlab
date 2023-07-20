function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blockObject)





    DTConstraintsSet={};



    if strcmp(blockObject.PMode,'Port')

        hasDTConstraints=true;%#ok<NASGU>


        outportStr=message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport').getString();
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blockObject,'1');
        constraint=SimulinkFixedPoint.AutoscalerConstraints.DoubleOnlyConstraint;
        constraint.setSourceInfo(blockObject,[outportStr,' ','1']);
        DTConstraintsSet{1}={uniqueId,constraint};
    end




    if strcmp(blockObject.cp_mode,'Select samples from port')

        records=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blockObject,3,[]);

        for idx=1:numel(records)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(records{idx}.blkObj,records{idx}.pathItem);



            constraint=SimulinkFixedPoint.AutoscalerConstraints.DoubleOnlyConstraint;
            constraint.setSourceInfo(blockObject,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 3']);
            DTConstraintsSet=[DTConstraintsSet,{{uniqueId,constraint}}];%#ok<AGROW>
        end
    end

    hasDTConstraints=~isempty(DTConstraintsSet);
end


