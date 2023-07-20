function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(~,expressionIdentifier)




    hasDTConstraints=true;

    mlfbExprConstraint=SimulinkFixedPoint.AutoscalerConstraints.MLFBExprOnlyConstraint();
    mlfbExprConstraint.setSourceInfo(expressionIdentifier.getMATLABFunctionBlock,'');
    DTConstraintsSet{1}={expressionIdentifier,mlfbExprConstraint};
end
