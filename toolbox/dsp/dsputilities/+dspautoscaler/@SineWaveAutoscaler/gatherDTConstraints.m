function[hasDTConstraints,DTConstraints]=gatherDTConstraints(h,blkObj)%#ok








    if strcmp(blkObj.SampleMode,'Discrete')&&strcmp(blkObj.CompMethod,'Table lookup')
        hasDTConstraints=false;
        DTConstraints={};
    else
        hasDTConstraints=true;
        DTConstraints={};


        uniqueId=SimulinkFixedPoint.AutoscalerUtils.getUniqueId(blkObj,'1');
        signedConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint('Signed',[],[]);
        DTConstraints{1}={uniqueId,signedConstraint};


        floatingpointConstraint=SimulinkFixedPoint.AutoscalerConstraints.SineWaveConstraint(...
        SimulinkFixedPoint.AutoscalerConstraints.FloatingPointOnlyConstraint);
        floatingpointConstraint.setSourceInfo(blkObj,[DAStudio.message('SimulinkFixedPoint:autoscaling:ConstraintFromOutport'),' 1']);
        DTConstraints{2}={uniqueId,floatingpointConstraint};

    end
