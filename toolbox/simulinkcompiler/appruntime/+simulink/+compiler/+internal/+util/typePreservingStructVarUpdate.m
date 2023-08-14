function variable=typePreservingStructVarUpdate(variable,fullVariableName,newData)








































    import simulink.compiler.internal.util.variableNameParts;

    [~,varNameNested]=variableNameParts(fullVariableName);

    pathToValue="variable.Value."+join(varNameNested,".");
    oldValue=eval(join(pathToValue,""));
    castEvaledNewData=class(oldValue)+"("+string(newData)+")";
    newValue=eval(join(castEvaledNewData,""));%#ok<NASGU>
    eval(join(pathToValue+" = newValue;",""));
end
