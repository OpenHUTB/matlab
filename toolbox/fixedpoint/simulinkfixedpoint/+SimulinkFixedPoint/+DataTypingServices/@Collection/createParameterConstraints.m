function createParameterConstraints(this,parameterObjectWrapper,result,runObj)



    pObjEA=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler;

    [hasDTConstraints,DTConstraintsSet]=pObjEA.gatherDTConstraints(parameterObjectWrapper);

    if hasDTConstraints
        L=length(DTConstraintsSet);
        for conIdx=1:L
            oneConstraintPair=DTConstraintsSet{conIdx};
            if isempty(oneConstraintPair{1})


                oneConstraintPair{1}=result.UniqueIdentifier;
                DTConstraintsSet{conIdx}=oneConstraintPair;
            end
        end

        this.getDTConstraintRecords(runObj,DTConstraintsSet);
    end
end