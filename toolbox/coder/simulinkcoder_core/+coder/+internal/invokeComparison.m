function invokeComparison(artifact1Name,...
    artifact2Name,...
    evalString1,...
    evalString2,...
    cleanup1String,...
    cleanup2String)




    import comparisons.internal.var.makeVariableSource;
    import comparisons.internal.var.startComparison;

    v1=makeVariableSource(artifact1Name,evalString1,cleanup1String);
    v2=makeVariableSource(artifact2Name,evalString2,cleanup2String);

    startComparison(v1,v2);

end
