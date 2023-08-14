
function value=getModelParameterValue(variable,model,harness)
    modelToUse=stm.internal.util.resolveHarness(model,harness);
    args=stm.internal.Parameters.getFindVarsArgs(modelToUse);
    vars=stm.internal.MRT.share.MRTFindVar(modelToUse,...
    args{:},'Name',variable);

    paraList=stm.internal.MRT.share.getVariableStruct(vars,model,harness);
    value=paraList.RuntimeValue;
end
