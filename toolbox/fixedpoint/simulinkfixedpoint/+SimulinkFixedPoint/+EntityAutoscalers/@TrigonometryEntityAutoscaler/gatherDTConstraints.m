function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)




    hasDTConstraints=false;
    DTConstraintsSet={};

    blkOperation=blkObj.Operator;
    approxMethod=blkObj.ApproximationMethod;
    if~(strcmp(approxMethod,'CORDIC')...
        &&any(strcmp(blkOperation,{'sin','cos','sincos','atan2','cos + jsin'})))




        hasDTConstraints=true;
        outportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport');

        constraint=...
        SimulinkFixedPoint.AutoscalerConstraints.TrigonometryBlockConstraint(...
        SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
        constraint.setSourceInfo(blkObj,[outportStr,' 1']);


        pathItemForOutport1=getPortMapping(h,blkObj,[],1);
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItemForOutport1{1});
        DTConstraintsSet{1}={uniqueId,constraint};

        if strcmp(blkOperation,'sincos')

            pathItemForOutport2=getPortMapping(h,blkObj,[],2);
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItemForOutport2{1});
            constraint=...
            SimulinkFixedPoint.AutoscalerConstraints.TrigonometryBlockConstraint(...
            SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
            constraint.setSourceInfo(blkObj,[outportStr,' 2']);
            DTConstraintsSet{2}={uniqueId,constraint};
        end


        constraint=...
        SimulinkFixedPoint.AutoscalerConstraints.TrigonometryBlockConstraint(...
        SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
        constraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport'),' 1']);

        inputSrc=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(...
        h,blkObj,1,[]);



        for idx=1:numel(inputSrc)
            uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(inputSrc{idx}.blkObj,inputSrc{idx}.pathItem);

            DTConstraintsSet{end+1}={uniqueId,constraint};%#ok<AGROW>
        end
    elseif(strcmp(approxMethod,'CORDIC')...
        &&any(strcmp(blkOperation,{'atan2'})))
        hasDTConstraints=true;
        inportStr=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromInport');

        pathItemForInport=getPortMapping(h,blkObj,1,[]);
        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,pathItemForInport{1});
        constraint=...
        SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],1:125,[]);
        constraint.setSourceInfo(blkObj,[inportStr,' 1']);
        DTConstraintsSet{1}={uniqueId,constraint};
    end
end


