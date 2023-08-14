function[isMutable,variableSourceType,variableSource]=traceVar(this)










    if this.isVarName&&~this.hasVariableBeenTraced
        traceVarToWorkspace(this);
    end
    variableSourceType=this.variableSourceType;
    variableSource=this.variableSource;
    isMutable=isMutableNamedDT(this);
end


