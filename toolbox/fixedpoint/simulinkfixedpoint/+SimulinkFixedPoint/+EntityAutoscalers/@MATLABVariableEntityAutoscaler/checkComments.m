function comments=checkComments(~,variableIdentifier,~)




    comments={};

    mlBlk=variableIdentifier.getMATLABFunctionBlock;
    if isempty(mlBlk)||variableIdentifier.isStruct
        return;
    end

    isUnderReadOnlySystem=SimulinkFixedPoint.TracingUtils.IsUnderReadOnlySystem(mlBlk);
    if isUnderReadOnlySystem
        comments{end+1}=message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale').getString();

    end
end


